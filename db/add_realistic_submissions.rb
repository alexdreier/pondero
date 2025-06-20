# Clear existing submissions and responses to start fresh
JournalSubmission.destroy_all
JournalEntry.destroy_all
Response.destroy_all
Comment.destroy_all

puts "🧹 Cleared existing submissions, responses, and comments"

# Get all users and journals
learners = User.where(role: 'learner')
published_journals = Journal.where(published: true)
instructors = User.where(role: 'instructor')

puts "📊 Found #{learners.count} learners and #{published_journals.count} published journals"

# Completion scenarios with realistic distribution
completion_scenarios = [
  { percentage: 100, status: 'submitted', quality: 'excellent' },  # 10%
  { percentage: 100, status: 'submitted', quality: 'good' },       # 15%
  { percentage: 100, status: 'submitted', quality: 'average' },    # 20%
  { percentage: 83, status: 'submitted', quality: 'good' },        # 15%
  { percentage: 67, status: 'in_progress', quality: 'average' },   # 15%
  { percentage: 50, status: 'in_progress', quality: 'average' },   # 10%
  { percentage: 33, status: 'in_progress', quality: 'poor' },      # 10%
  { percentage: 17, status: 'in_progress', quality: 'poor' },      # 5%
]

# Quality-based response content
response_templates = {
  'excellent' => {
    'free_text' => [
      "This week I gained profound insights into collaborative learning methodologies and their transformative impact on student engagement. Through systematic observation and analysis, I've identified key indicators of effective group dynamics that foster both individual growth and collective knowledge construction.",
      "My clinical experience involved complex patient scenarios that required advanced critical thinking and multidisciplinary collaboration. I successfully navigated challenging situations while demonstrating competency in assessment, intervention planning, and therapeutic communication with diverse patient populations.",
      "Today's lesson implementation of inquiry-based learning proved transformational for both student outcomes and my pedagogical development. The level of authentic engagement was remarkable, with students demonstrating genuine intellectual curiosity and taking ownership of their learning trajectory."
    ],
    'likert' => ['4', '5'],
    'multiple' => 2..3
  },
  'good' => {
    'free_text' => [
      "This week I learned about different collaborative learning strategies and how they can be effectively implemented in the classroom. I noticed increased student engagement when using peer discussion activities and group problem-solving approaches.",
      "My clinical rotation focused on patient assessment and medication administration. I practiced several new techniques and worked effectively with different healthcare team members while maintaining patient safety standards.",
      "I taught a lesson using hands-on manipulatives and visual aids. Most students participated actively and seemed to grasp the key concepts. The interactive approach helped students who typically struggle with abstract thinking."
    ],
    'likert' => ['3', '4', '5'],
    'multiple' => 1..2
  },
  'average' => {
    'free_text' => [
      "This week focused on group work and collaborative activities. Students worked together on projects and I observed increased engagement compared to individual work. Some groups were more effective than others.",
      "I practiced clinical skills including patient assessment and documentation procedures. The experience was valuable for understanding workflow and protocols. I received feedback from supervisors about areas for improvement.",
      "I taught a math lesson using interactive activities. Students participated and most seemed to understand the main concepts. The hands-on materials were helpful for student engagement."
    ],
    'likert' => ['2', '3', '4'],
    'multiple' => 1..1
  },
  'poor' => {
    'free_text' => [
      "This week we did group activities. Some students participated more than others. It was a learning experience.",
      "I worked with patients and practiced different procedures. The rotation provided exposure to clinical settings.",
      "I taught a lesson with some activities. Students seemed to understand most of the material presented."
    ],
    'likert' => ['1', '2', '3'],
    'multiple' => 1..1
  }
}

total_submissions = 0
total_responses = 0

learners.each do |student|
  published_journals.each do |journal|
    # 75% of students attempt each journal
    next unless [true, true, true, false].sample
    
    # Select completion scenario
    scenario = completion_scenarios.sample
    
    puts "Creating submission for #{student.first_name} #{student.last_name} - #{journal.title} (#{scenario[:percentage]}% complete, #{scenario[:quality]} quality)"
    
    # Create journal submission
    submission = journal.journal_submissions.create!(
      user: student,
      status: scenario[:status],
      completed_at: scenario[:status] == 'submitted' ? rand(1..21).days.ago : nil
    )
    total_submissions += 1
    
    # Create journal entry
    entry_date = scenario[:status] == 'submitted' ? submission.completed_at&.to_date : rand(1..7).days.ago.to_date
    journal_entry = journal.journal_entries.create!(
      user: student,
      title: "#{journal.title} - #{entry_date.strftime('%B %d, %Y')}",
      entry_date: entry_date,
      status: scenario[:status] == 'submitted' ? 'submitted' : 'draft',
      submitted_at: scenario[:status] == 'submitted' ? submission.completed_at : nil
    )
    
    # Get questions for this journal
    required_questions = journal.questions.where(required: true).to_a
    optional_questions = journal.questions.where(required: false).to_a
    
    # Calculate how many questions to answer
    required_to_answer = (required_questions.count * scenario[:percentage] / 100.0).round
    optional_to_answer = scenario[:quality] == 'poor' ? 0 : rand(0..optional_questions.count/2)
    
    # Answer required questions
    required_questions.sample(required_to_answer).each do |question|
      content = case question.question_type
      when 'free_text'
        response_templates[scenario[:quality]]['free_text'].sample
      when 'likert_scale', 'single_response'
        if question.options_array&.any?
          # For likert scales, use quality-based selection
          if question.question_type == 'likert_scale'
            response_templates[scenario[:quality]]['likert'].sample
          else
            question.options_array.sample
          end
        else
          # Handle non-option single responses
          case question.content.to_s.downcase
          when /date/
            entry_date.strftime("%B %d, %Y")
          when /grade|level/
            ["3rd Grade", "4th Grade", "5th Grade", "Middle School", "High School"].sample
          when /hours?/
            "#{rand(2..8)} hours"
          else
            "Sample response"
          end
        end
      when 'multiple_response'
        if question.options_array&.any?
          range = response_templates[scenario[:quality]]['multiple']
          num_selections = rand(range)
          question.options_array.sample([num_selections, question.options_array.length].min).join(', ')
        else
          "Multiple selections"
        end
      else
        "Response for #{question.question_type}"
      end
      
      response = Response.create!(
        user: student,
        question: question,
        journal_entry: journal_entry,
        content: content,
        status: scenario[:status] == 'submitted' ? 'submitted' : 'draft',
        submitted_at: scenario[:status] == 'submitted' ? submission.completed_at : nil
      )
      total_responses += 1
    end
    
    # Answer some optional questions for better students
    if optional_to_answer > 0 && optional_questions.any?
      optional_questions.sample(optional_to_answer).each do |question|
        content = case question.question_type
        when 'free_text'
          response_templates[scenario[:quality]]['free_text'].sample
        when 'multiple_response'
          if question.options_array&.any?
            range = response_templates[scenario[:quality]]['multiple']
            num_selections = rand(range)
            question.options_array.sample([num_selections, question.options_array.length].min).join(', ')
          else
            "Optional response"
          end
        else
          "Optional response for #{question.question_type}"
        end
        
        Response.create!(
          user: student,
          question: question,
          journal_entry: journal_entry,
          content: content,
          status: scenario[:status] == 'submitted' ? 'submitted' : 'draft',
          submitted_at: scenario[:status] == 'submitted' ? submission.completed_at : nil
        )
        total_responses += 1
      end
    end
    
    # Add instructor feedback for submitted work (40% chance)
    if submission.status == 'submitted' && [true, false, false].sample
      instructor_for_feedback = [journal.user, instructors.sample].sample
      
      feedback_by_quality = {
        'excellent' => [
          "Outstanding reflection! Your analysis demonstrates exceptional depth and critical thinking. The connections you've made between theory and practice are particularly impressive. Continue this excellent work!",
          "Exceptional work on this journal entry. Your detailed observations and thoughtful analysis reflect a high level of professional reflection. Your growth as a practitioner is evident."
        ],
        'good' => [
          "Great reflection! You've demonstrated solid understanding and made good connections to practice. Consider exploring some insights in greater depth to enhance your reflective practice.",
          "Strong work on this journal entry. You've shown good progress in developing reflective skills. Try to include more specific examples in future reflections."
        ],
        'average' => [
          "Good effort on this reflection. You've covered the main points and shown basic understanding. Try to provide more specific examples and deeper analysis.",
          "Thank you for your submission. You've addressed key questions but could benefit from more depth and critical analysis of your experiences."
        ],
        'poor' => [
          "Your submission shows effort but needs more development. Please review the prompts carefully and provide more comprehensive answers. Consider scheduling a meeting for guidance.",
          "This submission meets basic requirements but lacks expected depth. Please expand responses with specific examples and detailed analysis."
        ]
      }
      
      Comment.create!(
        user: instructor_for_feedback,
        journal_submission: submission,
        content: feedback_by_quality[scenario[:quality]].sample
      )
    end
  end
end

# Calculate and display final statistics
completion_stats = JournalSubmission.all.map(&:completion_percentage)
avg_completion = completion_stats.sum.to_f / completion_stats.length

puts "\n🎉 REALISTIC SUBMISSION DATA CREATED! 🎉"
puts "="*60
puts "📊 COMPREHENSIVE STATISTICS:"
puts "• #{total_submissions} Journal Submissions Created"
puts "• #{total_responses} Student Responses Created"
puts "• #{JournalEntry.count} Journal Entries Created"
puts "• #{Comment.count} Instructor Comments Added"
puts ""
puts "📈 COMPLETION BREAKDOWN:"
submission_stats = JournalSubmission.group(:status).count
puts "• #{submission_stats['submitted'] || 0} Completed Submissions"
puts "• #{submission_stats['in_progress'] || 0} In-Progress Submissions" 
puts "• #{avg_completion.round(1)}% Average Completion Rate"
puts ""
puts "📋 COMPLETION DISTRIBUTION:"
[100, 83, 67, 50, 33, 17, 0].each do |pct|
  count = completion_stats.count { |c| c >= pct && c < pct + 17 }
  puts "• #{pct}%-#{pct+16}%: #{count} submissions" if count > 0
end
puts ""
puts "🚀 READY FOR DEMO! Start server and view analytics dashboard"
puts "="*60
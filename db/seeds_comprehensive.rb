# Create themes first
default_theme = Theme.find_or_create_by!(name: "Default") do |theme|
  theme.description = "Default Pondero theme with blue accents"
  theme.colors_hash = {
    primary: "#3B82F6",
    secondary: "#6B7280", 
    accent: "#10B981",
    background: "#F9FAFB"
  }
  theme.fonts_hash = {
    heading: "Inter",
    body: "Inter"
  }
  theme.layout_options_hash = {
    sidebar_position: "left",
    compact_mode: false
  }
end

dark_theme = Theme.find_or_create_by!(name: "Dark Mode") do |theme|
  theme.description = "Dark theme for comfortable viewing"
  theme.colors_hash = {
    primary: "#60A5FA",
    secondary: "#9CA3AF", 
    accent: "#34D399",
    background: "#111827"
  }
  theme.fonts_hash = {
    heading: "Inter",
    body: "Inter"
  }
  theme.layout_options_hash = {
    sidebar_position: "left",
    compact_mode: false
  }
end

warm_theme = Theme.find_or_create_by!(name: "Warm") do |theme|
  theme.description = "Warm theme with orange and red tones"
  theme.colors_hash = {
    primary: "#F97316",
    secondary: "#78716C", 
    accent: "#EF4444",
    background: "#FEF7F3"
  }
  theme.fonts_hash = {
    heading: "Georgia",
    body: "Georgia"
  }
  theme.layout_options_hash = {
    sidebar_position: "left",
    compact_mode: true
  }
end

minimal_theme = Theme.find_or_create_by!(name: "Minimal") do |theme|
  theme.description = "Clean minimal theme with subtle accents"
  theme.colors_hash = {
    primary: "#374151",
    secondary: "#9CA3AF", 
    accent: "#6366F1",
    background: "#FFFFFF"
  }
  theme.fonts_hash = {
    heading: "Helvetica",
    body: "Helvetica"
  }
  theme.layout_options_hash = {
    sidebar_position: "left",
    compact_mode: true
  }
end

# Create users
admin = User.find_or_create_by!(email: "admin@pondero.demo") do |user|
  user.password = "demo123456"
  user.password_confirmation = "demo123456"
  user.first_name = "Sarah"
  user.last_name = "Administrator"
  user.role = "administrator"
end

instructor = User.find_or_create_by!(email: "instructor@pondero.demo") do |user|
  user.password = "demo123456"
  user.password_confirmation = "demo123456"
  user.first_name = "Dr. Jane"
  user.last_name = "Smith"
  user.role = "instructor"
end

instructor2 = User.find_or_create_by!(email: "instructor2@pondero.demo") do |user|
  user.password = "demo123456"
  user.password_confirmation = "demo123456"
  user.first_name = "Prof. Michael"
  user.last_name = "Johnson"
  user.role = "instructor"
end

instructor3 = User.find_or_create_by!(email: "instructor3@pondero.demo") do |user|
  user.password = "demo123456"
  user.password_confirmation = "demo123456"
  user.first_name = "Dr. Emily"
  user.last_name = "Rodriguez"
  user.role = "instructor"
end

instructor4 = User.find_or_create_by!(email: "instructor4@pondero.demo") do |user|
  user.password = "demo123456"
  user.password_confirmation = "demo123456"
  user.first_name = "Prof. David"
  user.last_name = "Chen"
  user.role = "instructor"
end

# Create realistic learners
learner_data = [
  ["Alex", "Student", "learner@pondero.demo"],
  ["Taylor", "Williams", "learner2@pondero.demo"],
  ["Jordan", "Davis", "learner3@pondero.demo"],
  ["Casey", "Brown", "learner4@pondero.demo"],
  ["Morgan", "Miller", "learner5@pondero.demo"],
  ["Riley", "Wilson", "learner6@pondero.demo"],
  ["Avery", "Moore", "learner7@pondero.demo"],
  ["Quinn", "Taylor", "learner8@pondero.demo"],
  ["Cameron", "Anderson", "learner9@pondero.demo"],
  ["Sage", "Thomas", "learner10@pondero.demo"],
  ["Rowan", "Jackson", "learner11@pondero.demo"],
  ["Phoenix", "White", "learner12@pondero.demo"],
  ["River", "Harris", "learner13@pondero.demo"],
  ["Skylar", "Martin", "learner14@pondero.demo"],
  ["Emery", "Thompson", "learner15@pondero.demo"],
  ["Dakota", "Garcia", "learner16@pondero.demo"],
  ["Reese", "Martinez", "learner17@pondero.demo"],
  ["Blake", "Robinson", "learner18@pondero.demo"],
  ["Finley", "Clark", "learner19@pondero.demo"],
  ["Hayden", "Rodriguez", "learner20@pondero.demo"]
]

learners = []
learner_data.each do |first_name, last_name, email|
  learner = User.find_or_create_by!(email: email) do |user|
    user.password = "demo123456"
    user.password_confirmation = "demo123456"
    user.first_name = first_name
    user.last_name = last_name
    user.role = "learner"
  end
  learners << learner
end

instructors = [instructor, instructor2, instructor3, instructor4]

# Create comprehensive journal templates
journal_templates = [
  {
    title: "Weekly Learning Reflection",
    description: "Structured weekly reflection to track learning progress and identify areas for improvement",
    user: instructor,
    theme: default_theme,
    questions: [
      { content: "What were the most important concepts you learned this week?", type: "free_text", required: true },
      { content: "Rate your understanding of this week's material", type: "likert_scale", required: true, options: ["1 - Poor", "2 - Fair", "3 - Good", "4 - Very Good", "5 - Excellent"] },
      { content: "Which learning activities were most helpful?", type: "multiple_response", required: false, options: ["Lectures", "Readings", "Discussions", "Practice Problems", "Group Work", "Lab Activities"] },
      { content: "What challenges did you encounter and how did you address them?", type: "free_text", required: true },
      { content: "What questions do you still have about the material?", type: "free_text", required: false },
      { content: "How confident do you feel about applying what you learned?", type: "likert_scale", required: true, options: ["1 - Not Confident", "2 - Slightly Confident", "3 - Moderately Confident", "4 - Very Confident", "5 - Extremely Confident"] }
    ]
  },
  {
    title: "Clinical Skills Assessment Journal",
    description: "Comprehensive reflection tool for healthcare students to document clinical experiences and skill development",
    user: instructor2,
    theme: warm_theme,
    questions: [
      { content: "Date and location of clinical experience", type: "single_response", required: true },
      { content: "Primary clinical skills practiced today", type: "multiple_response", required: true, options: ["Patient Assessment", "Medication Administration", "Wound Care", "Documentation", "Communication", "Emergency Response", "Equipment Use", "Sterile Technique"] },
      { content: "Describe a challenging patient interaction and how you handled it", type: "free_text", required: true },
      { content: "Rate your confidence in the skills practiced today", type: "likert_scale", required: true, options: ["1 - Needs Significant Improvement", "2 - Developing", "3 - Competent", "4 - Proficient", "5 - Expert"] },
      { content: "What feedback did you receive from supervisors or mentors?", type: "free_text", required: false },
      { content: "Areas for improvement and action plan", type: "free_text", required: true }
    ]
  },
  {
    title: "Student Teaching Reflection Journal",
    description: "Daily reflection tool for student teachers to document classroom experiences and pedagogical development",
    user: instructor3,
    theme: minimal_theme,
    questions: [
      { content: "Grade level and subject taught", type: "single_response", required: true },
      { content: "Lesson objectives and standards addressed", type: "free_text", required: true },
      { content: "Teaching strategies and methods used", type: "multiple_response", required: true, options: ["Direct Instruction", "Collaborative Learning", "Inquiry-Based", "Problem-Based Learning", "Technology Integration", "Differentiated Instruction"] },
      { content: "How well did students engage with the lesson?", type: "likert_scale", required: true, options: ["1 - Poor Engagement", "2 - Limited Engagement", "3 - Moderate Engagement", "4 - Good Engagement", "5 - Excellent Engagement"] },
      { content: "What evidence of student learning did you observe?", type: "free_text", required: true },
      { content: "What would you do differently if you taught this lesson again?", type: "free_text", required: true }
    ]
  }
]

# Create all journals and questions
all_journals = []
journal_templates.each_with_index do |template_data, index|
  journal = Journal.find_or_create_by!(title: template_data[:title], user: template_data[:user]) do |j|
    j.description = template_data[:description]
    j.theme = template_data[:theme]
    j.published = true
    j.position = index + 1
    j.status = "published"
    j.visibility = "public"
    j.available_from = 3.weeks.ago
    j.available_until = 2.weeks.from_now
  end
  
  # Add questions to each journal
  template_data[:questions].each_with_index do |q_data, q_index|
    question = journal.questions.find_or_create_by!(position: q_index + 1) do |question|
      question.content = q_data[:content]
      question.question_type = q_data[:type]
      question.required = q_data[:required]
      question.options_array = q_data[:options] if q_data[:options]
    end
  end
  
  all_journals << journal
end

# Create realistic journal submissions with varying completion levels
completion_scenarios = [
  { percentage: 100, status: 'submitted', quality: 'excellent' },
  { percentage: 100, status: 'submitted', quality: 'good' },
  { percentage: 100, status: 'submitted', quality: 'average' },
  { percentage: 83, status: 'submitted', quality: 'good' },
  { percentage: 75, status: 'in_progress', quality: 'average' },
  { percentage: 67, status: 'in_progress', quality: 'good' },
  { percentage: 50, status: 'in_progress', quality: 'average' },
  { percentage: 33, status: 'in_progress', quality: 'poor' },
  { percentage: 17, status: 'in_progress', quality: 'poor' },
  { percentage: 0, status: 'in_progress', quality: 'poor' }
]

# Quality-based response content
response_content_by_quality = {
  'excellent' => {
    'free_text' => [
      "This week I gained a profound understanding of collaborative learning methodologies and their impact on student engagement. The integration of peer-to-peer learning strategies has fundamentally shifted my perspective on knowledge construction. Through systematic observation and analysis, I've identified key indicators of effective group dynamics, including equitable participation, constructive feedback loops, and shared accountability structures. The most significant insight was recognizing how scaffolded collaboration can bridge individual learning differences while maintaining academic rigor.",
      "My clinical experience this week involved complex patient cases that required advanced critical thinking and multidisciplinary collaboration. I successfully navigated a particularly challenging situation involving a patient with multiple comorbidities, demonstrating competency in assessment, intervention planning, and effective communication with the healthcare team. The experience reinforced the importance of evidence-based practice and highlighted areas where I can continue to develop expertise, particularly in advanced pharmacological interventions.",
      "Today's lesson on inquiry-based learning proved to be transformational for both my students and my own pedagogical development. I implemented a problem-based approach that encouraged students to formulate their own questions and develop research strategies. The level of engagement was remarkable - students demonstrated genuine curiosity and took ownership of their learning process. Evidence of deep learning was apparent through their thoughtful questions, collaborative discussions, and the quality of their final presentations."
    ],
    'multiple_response' => proc { |options| options.sample(rand(2..3)).join(', ') }
  },
  'good' => {
    'free_text' => [
      "This week I learned about different teaching strategies and how they can be applied in the classroom. The collaborative learning approach was particularly interesting and I can see how it would benefit students. I tried implementing some peer discussion activities and noticed increased engagement from students who usually don't participate much. I think this approach helps students learn from each other and builds important communication skills.",
      "My clinical rotation focused on medication administration and patient communication. I practiced several new techniques for patient assessment and worked with different members of the healthcare team. The experience helped me understand the importance of clear documentation and effective handoff communication. I feel more confident in my ability to provide safe patient care and recognize when to seek guidance from supervisors.",
      "I taught a lesson on fractions using manipulatives and visual aids. Most students seemed engaged and participated actively in the hands-on activities. I observed that students who struggled with abstract concepts were better able to understand when they could physically manipulate objects. The lesson went well overall, though I think I could have provided more challenging extension activities for advanced learners."
    ],
    'multiple_response' => proc { |options| options.sample(rand(1..2)).join(', ') }
  },
  'average' => {
    'free_text' => [
      "This week was focused on group work and collaborative learning. Students worked together on projects and I noticed they were more engaged than usual. Some groups worked better than others. I learned that group activities can be effective but need good planning and clear instructions.",
      "I practiced clinical skills including patient assessment and documentation. The experience was valuable and helped me understand the workflow better. I received feedback from my supervisor about areas to improve. Overall it was a good learning experience.",
      "I taught a math lesson about addition. Students participated in activities and most seemed to understand the concepts. The lesson included hands-on materials which the students enjoyed. I think it went well but there are some things I would change next time."
    ],
    'multiple_response' => proc { |options| options.sample(1).join(', ') }
  },
  'poor' => {
    'free_text' => [
      "This week we did group work. It was okay. Some students participated more than others.",
      "I worked with patients and practiced different skills. It was a learning experience.",
      "I taught a lesson and used some activities. Students seemed to understand most of it."
    ],
    'multiple_response' => proc { |options| options.sample(1).join(', ') }
  }
}

learners.each do |student|
  all_journals.each do |journal|
    # 70% of students attempt each journal
    next unless [true, true, true, true, true, true, true, false, false, false].sample
    
    # Assign a completion scenario to this student-journal combination
    scenario = completion_scenarios.sample
    
    # Create journal submission
    submission = journal.journal_submissions.find_or_create_by!(user: student) do |sub|
      sub.status = scenario[:status]
      sub.completed_at = scenario[:status] == 'submitted' ? rand(1..21).days.ago : nil
    end
    
    # Create journal entry
    entry_date = scenario[:status] == 'submitted' ? submission.completed_at&.to_date : rand(1..7).days.ago.to_date
    journal_entry = journal.journal_entries.find_or_create_by!(user: student, entry_date: entry_date) do |entry|
      entry.title = "#{journal.title} - #{entry_date.strftime('%B %d, %Y')}"
      entry.status = scenario[:status] == 'submitted' ? 'submitted' : 'draft'
      entry.submitted_at = scenario[:status] == 'submitted' ? submission.completed_at : nil
    end
    
    # Calculate how many questions to answer based on completion percentage
    required_questions = journal.questions.where(required: true)
    optional_questions = journal.questions.where(required: false)
    
    required_to_answer = (required_questions.count * scenario[:percentage] / 100.0).round
    optional_to_answer = rand(0..optional_questions.count)
    
    # Answer required questions first
    required_questions.limit(required_to_answer).each do |question|
      response_content = case question.question_type
      when 'free_text'
        response_content_by_quality[scenario[:quality]]['free_text'].sample
      when 'likert_scale'
        case scenario[:quality]
        when 'excellent' then ['4', '5'].sample
        when 'good' then ['3', '4', '5'].sample
        when 'average' then ['2', '3', '4'].sample
        when 'poor' then ['1', '2', '3'].sample
        end
      when 'multiple_response'
        if question.options_array&.any?
          response_content_by_quality[scenario[:quality]]['multiple_response'].call(question.options_array)
        else
          "Multiple selections made"
        end
      when 'single_response'
        if question.options_array&.any?
          question.options_array.sample
        else
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
      else
        "Response for #{question.question_type} question"
      end

      Response.find_or_create_by!(user: student, question: question) do |response|
        response.content = response_content
        response.status = scenario[:status] == 'submitted' ? 'submitted' : 'draft'
        response.submitted_at = scenario[:status] == 'submitted' ? submission.completed_at : nil
        response.journal_entry = journal_entry
      end
    end
    
    # Answer some optional questions
    if scenario[:quality] != 'poor' && optional_to_answer > 0
      optional_questions.sample(optional_to_answer).each do |question|
        response_content = case question.question_type
        when 'free_text'
          response_content_by_quality[scenario[:quality]]['free_text'].sample
        when 'multiple_response'
          if question.options_array&.any?
            response_content_by_quality[scenario[:quality]]['multiple_response'].call(question.options_array)
          else
            "Multiple selections made"
          end
        else
          "Optional response"
        end

        Response.find_or_create_by!(user: student, question: question) do |response|
          response.content = response_content
          response.status = scenario[:status] == 'submitted' ? 'submitted' : 'draft'
          response.submitted_at = scenario[:status] == 'submitted' ? submission.completed_at : nil
          response.journal_entry = journal_entry
        end
      end
    end
    
    # Add instructor feedback for completed submissions
    if submission.status == 'submitted' && [true, false, false].sample # 33% get feedback
      instructor_for_feedback = [journal.user, instructors.sample].sample
      
      feedback_comments = case scenario[:quality]
      when 'excellent'
        [
          "Outstanding reflection! Your analysis demonstrates exceptional depth and critical thinking. The connections you've made between theory and practice are particularly impressive. Your insights about collaborative learning methodologies show sophisticated understanding of pedagogical principles. Continue this excellent work!",
          "Exceptional work on this journal entry. Your detailed observations and thoughtful analysis reflect a high level of professional reflection. The way you've integrated evidence-based practices with personal insights is commendable. Your growth as a practitioner is evident throughout this submission.",
          "This is exemplary reflective writing. Your systematic approach to analyzing your experiences and the depth of your insights demonstrate advanced critical thinking skills. The specific examples you've provided effectively illustrate your learning and development. Excellent job!"
        ]
      when 'good'
        [
          "Great reflection! You've demonstrated solid understanding of the key concepts and made good connections to practice. Your examples are relevant and show thoughtful consideration. Consider exploring some of your insights in greater depth to further enhance your reflective practice.",
          "Strong work on this journal entry. You've shown good progress in developing your reflective skills and professional understanding. Your observations are insightful and well-expressed. To strengthen future reflections, try to include more specific examples and deeper analysis.",
          "Well done! Your reflection shows good self-awareness and understanding of the material. You've made meaningful connections between your experiences and learning objectives. Continue to challenge yourself to think more critically about the implications of your observations."
        ]
      when 'average'
        [
          "Good effort on this reflection. You've covered the main points and shown basic understanding of the concepts. To improve, try to provide more specific examples and deeper analysis of your experiences. Consider how your observations connect to broader professional practices.",
          "Thank you for your submission. You've addressed the key questions and demonstrated understanding of the basic concepts. For future reflections, consider expanding on your insights and providing more detailed examples to support your observations.",
          "Adequate reflection that covers the required elements. Your responses show understanding but could benefit from more depth and critical analysis. Try to explore the 'why' behind your observations and connect them to professional development goals."
        ]
      else # poor
        [
          "Your submission shows some effort, but the responses need more development and detail. Please review the journal prompts carefully and provide more comprehensive answers. Consider scheduling a meeting to discuss strategies for effective reflective writing.",
          "This submission meets basic requirements but lacks the depth expected for reflective practice. Please expand on your responses with specific examples and more detailed analysis. I'm available to provide additional guidance if needed."
        ]
      end
      
      Comment.find_or_create_by!(user: instructor_for_feedback, journal_submission: submission) do |comment|
        comment.content = feedback_comments.sample
      end
    end
  end
end

puts "\n🎉 COMPREHENSIVE REALISTIC DEMO DATA CREATED! 🎉"
puts "\n" + "="*70
puts "PONDERO COMPREHENSIVE DEMO WITH REALISTIC COMPLETION DATA"
puts "="*70
puts "📊 DATA SUMMARY:"
puts "• #{User.count} Total Users (#{User.where(role: 'instructor').count} Instructors, #{User.where(role: 'learner').count} Learners, #{User.where(role: 'administrator').count} Admins)"
puts "• #{Journal.count} Total Journals (#{Journal.where(published: true).count} Published, #{Journal.where(published: false).count} Private)"
puts "• #{Question.count} Total Questions across all journals"
puts "• #{Response.count} Student Responses with realistic content"
puts "• #{JournalSubmission.count} Journal Submissions with varied completion levels"
puts "• #{JournalEntry.count} Journal Entries linking responses properly"
puts "• #{Comment.count} Instructor Comments/Feedback"
puts "• #{Theme.count} Themes Available"
puts ""
puts "📈 COMPLETION DATA:"
submissions_by_status = JournalSubmission.group(:status).count
puts "• #{submissions_by_status['submitted'] || 0} Completed Submissions"
puts "• #{submissions_by_status['in_progress'] || 0} In-Progress Submissions"
if JournalSubmission.any?
  avg_completion = JournalSubmission.all.map(&:completion_percentage).sum.to_f / JournalSubmission.count
  puts "• #{avg_completion.round(1)}% Average Completion Rate"
end
puts ""
puts "🔑 DEMO ACCOUNTS:"
puts "👨‍🏫 INSTRUCTOR: instructor@pondero.demo / demo123456"
puts "👨‍🎓 STUDENT: learner@pondero.demo / demo123456"
puts "👩‍💼 ADMIN: admin@pondero.demo / demo123456"
puts ""
puts "🚀 START DEMO: rails server → http://localhost:3000"
puts "="*70
# Create themes
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

# Create extensive demo users
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

# Create extensive journal templates and instructor journals
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
      { content: "Areas for improvement and action plan", type: "free_text", required: true },
      { content: "Professional growth insights from today's experience", type: "free_text", required: false }
    ]
  },
  {
    title: "Research Project Progress Log",
    description: "Systematic tracking of research methodology, findings, and reflections for academic projects",
    user: instructor3,
    theme: minimal_theme,
    questions: [
      { content: "Project phase", type: "single_response", required: true, options: ["Literature Review", "Methodology Design", "Data Collection", "Data Analysis", "Writing", "Revision"] },
      { content: "Hours worked on project this week", type: "single_response", required: true },
      { content: "Key accomplishments and milestones reached", type: "free_text", required: true },
      { content: "Research methodologies applied", type: "multiple_response", required: false, options: ["Qualitative Interviews", "Quantitative Surveys", "Literature Analysis", "Case Study", "Experimental Design", "Statistical Analysis", "Content Analysis"] },
      { content: "Challenges encountered and solutions implemented", type: "free_text", required: true },
      { content: "How does this week's work align with your research timeline?", type: "likert_scale", required: true, options: ["1 - Significantly Behind", "2 - Slightly Behind", "3 - On Track", "4 - Slightly Ahead", "5 - Significantly Ahead"] },
      { content: "Next steps and priorities for the upcoming week", type: "free_text", required: true },
      { content: "Insights or discoveries that might impact your research direction", type: "free_text", required: false }
    ]
  },
  {
    title: "Leadership Development Portfolio",
    description: "Reflective journal for tracking leadership experiences, skills development, and personal growth",
    user: instructor4,
    theme: dark_theme,
    questions: [
      { content: "Leadership situation or experience", type: "free_text", required: true },
      { content: "Leadership styles demonstrated", type: "multiple_response", required: true, options: ["Transformational", "Transactional", "Servant Leadership", "Authentic Leadership", "Situational Leadership", "Democratic", "Collaborative"] },
      { content: "Rate the effectiveness of your leadership approach", type: "likert_scale", required: true, options: ["1 - Not Effective", "2 - Somewhat Effective", "3 - Effective", "4 - Very Effective", "5 - Highly Effective"] },
      { content: "What impact did your leadership have on others?", type: "free_text", required: true },
      { content: "Communication strategies used", type: "multiple_response", required: false, options: ["Active Listening", "Clear Direction", "Feedback", "Motivation", "Conflict Resolution", "Negotiation", "Public Speaking"] },
      { content: "Reflect on what you learned about yourself as a leader", type: "free_text", required: true },
      { content: "Areas for leadership development", type: "free_text", required: true },
      { content: "How will you apply these insights to future leadership opportunities?", type: "free_text", required: false }
    ]
  },
  {
    title: "Student Teaching Reflection Journal",
    description: "Daily reflection tool for student teachers to document classroom experiences and pedagogical development",
    user: instructor,
    theme: default_theme,
    questions: [
      { content: "Grade level and subject taught", type: "single_response", required: true },
      { content: "Lesson objectives and standards addressed", type: "free_text", required: true },
      { content: "Teaching strategies and methods used", type: "multiple_response", required: true, options: ["Direct Instruction", "Collaborative Learning", "Inquiry-Based", "Problem-Based Learning", "Technology Integration", "Differentiated Instruction", "Assessment-Driven"] },
      { content: "How well did students engage with the lesson?", type: "likert_scale", required: true, options: ["1 - Poor Engagement", "2 - Limited Engagement", "3 - Moderate Engagement", "4 - Good Engagement", "5 - Excellent Engagement"] },
      { content: "What evidence of student learning did you observe?", type: "free_text", required: true },
      { content: "Classroom management techniques used", type: "multiple_response", required: false, options: ["Positive Reinforcement", "Clear Expectations", "Redirection", "Individual Conferences", "Group Management", "Environmental Modifications"] },
      { content: "What would you do differently if you taught this lesson again?", type: "free_text", required: true },
      { content: "Mentor teacher feedback and suggestions", type: "free_text", required: false },
      { content: "Personal reflection on growth as an educator", type: "free_text", required: false }
    ]
  },
  {
    title: "Innovation & Entrepreneurship Lab",
    description: "Weekly reflection on innovation projects, entrepreneurial thinking, and creative problem-solving",
    user: instructor2,
    theme: warm_theme,
    questions: [
      { content: "Innovation project or challenge worked on", type: "free_text", required: true },
      { content: "Creative problem-solving methods applied", type: "multiple_response", required: true, options: ["Design Thinking", "Brainstorming", "Mind Mapping", "SCAMPER", "Rapid Prototyping", "User Research", "Lean Startup"] },
      { content: "Rate the novelty of your solution approach", type: "likert_scale", required: true, options: ["1 - Conventional", "2 - Somewhat Novel", "3 - Moderately Novel", "4 - Highly Novel", "5 - Breakthrough"] },
      { content: "Collaborations and team dynamics", type: "free_text", required: false },
      { content: "User feedback or market validation received", type: "free_text", required: false },
      { content: "Obstacles overcome and lessons learned", type: "free_text", required: true },
      { content: "How has this experience changed your approach to innovation?", type: "free_text", required: true },
      { content: "Next iteration or pivot plans", type: "free_text", required: false }
    ]
  },
  {
    title: "Global Perspectives & Cultural Competency",
    description: "Reflection journal for developing intercultural understanding and global awareness",
    user: instructor3,
    theme: minimal_theme,
    questions: [
      { content: "Cultural experience or interaction", type: "free_text", required: true },
      { content: "Cultural dimensions explored", type: "multiple_response", required: true, options: ["Communication Styles", "Power Distance", "Individualism vs Collectivism", "Time Orientation", "Religious Practices", "Social Norms", "Business Practices"] },
      { content: "Rate your cultural sensitivity in this situation", type: "likert_scale", required: true, options: ["1 - Unaware", "2 - Somewhat Aware", "3 - Aware", "4 - Sensitive", "5 - Highly Competent"] },
      { content: "What assumptions or biases did you recognize in yourself?", type: "free_text", required: true },
      { content: "How did you adapt your behavior or communication?", type: "free_text", required: false },
      { content: "What did you learn about the other culture?", type: "free_text", required: true },
      { content: "How will this experience influence your future interactions?", type: "free_text", required: true },
      { content: "Global issues or perspectives that emerged", type: "free_text", required: false }
    ]
  },
  {
    title: "Community Service Learning Journal",
    description: "Reflective documentation of community service experiences and social impact learning",
    user: instructor4,
    theme: default_theme,
    questions: [
      { content: "Community organization and service project", type: "free_text", required: true },
      { content: "Hours of service completed", type: "single_response", required: true },
      { content: "Community needs addressed", type: "multiple_response", required: true, options: ["Education", "Healthcare", "Housing", "Food Security", "Environmental", "Youth Development", "Senior Services", "Economic Development"] },
      { content: "Rate the impact of your service on the community", type: "likert_scale", required: true, options: ["1 - Minimal Impact", "2 - Limited Impact", "3 - Moderate Impact", "4 - Significant Impact", "5 - Transformational Impact"] },
      { content: "Skills and knowledge applied in service", type: "multiple_response", required: false, options: ["Communication", "Organization", "Problem Solving", "Technical Skills", "Leadership", "Teamwork", "Cultural Competency"] },
      { content: "What did you learn about social issues and community challenges?", type: "free_text", required: true },
      { content: "How has this experience shaped your understanding of civic responsibility?", type: "free_text", required: true },
      { content: "Plans for continued community engagement", type: "free_text", required: false }
    ]
  }
]

# Create instructor's personal journals
instructor_journals = [
  {
    title: "My Teaching Philosophy Evolution",
    description: "Personal reflection on developing teaching practices and educational philosophy",
    user: instructor,
    theme: default_theme,
    published: false,
    questions: [
      { content: "What teaching moments stood out this week?", type: "free_text", required: true },
      { content: "How am I growing as an educator?", type: "free_text", required: true },
      { content: "Student feedback that impacted me", type: "free_text", required: false },
      { content: "Teaching strategies I want to explore", type: "free_text", required: false }
    ]
  },
  {
    title: "Research & Professional Development Log",
    description: "Tracking professional growth activities and research interests",
    user: instructor,
    theme: minimal_theme,
    published: false,
    questions: [
      { content: "Professional development activities this week", type: "free_text", required: true },
      { content: "New research or publications reviewed", type: "free_text", required: false },
      { content: "Networking and collaboration opportunities", type: "free_text", required: false },
      { content: "Skills I'm developing", type: "multiple_response", required: false, options: ["Research Methods", "Technology", "Leadership", "Communication", "Assessment", "Curriculum Design"] }
    ]
  },
  {
    title: "Coaching Impact Assessment",
    description: "Dr. Johnson's personal reflection on coaching effectiveness and student outcomes",
    user: instructor2,
    theme: warm_theme,
    published: false,
    questions: [
      { content: "Coaching sessions conducted this week", type: "single_response", required: true },
      { content: "Student progress observations", type: "free_text", required: true },
      { content: "Coaching techniques that worked well", type: "multiple_response", required: false, options: ["Active Listening", "Powerful Questions", "Goal Setting", "Action Planning", "Feedback", "Modeling"] },
      { content: "Areas for improving my coaching practice", type: "free_text", required: true }
    ]
  }
]

# Create all the journals
all_journals = []

# Create template journals (published)
journal_templates.each_with_index do |template_data, index|
  journal = Journal.find_or_create_by!(title: template_data[:title], user: template_data[:user]) do |j|
    j.description = template_data[:description]
    j.theme = template_data[:theme]
    j.published = true
    j.position = index + 1
    j.status = "published"
    j.visibility = "public_access"
    j.available_from = 2.weeks.ago
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

# Create instructor personal journals (private)
instructor_journals.each_with_index do |journal_data, index|
  journal = Journal.find_or_create_by!(title: journal_data[:title], user: journal_data[:user]) do |j|
    j.description = journal_data[:description]
    j.theme = journal_data[:theme]
    j.published = journal_data[:published]
    j.position = index + 100  # Use different position range to avoid conflicts
    j.status = journal_data[:published] ? "published" : "draft"
    j.visibility = "private_access"
    j.available_from = 1.week.ago
    j.available_until = 1.month.from_now
  end
  
  # Add questions
  journal_data[:questions].each_with_index do |q_data, q_index|
    question = journal.questions.find_or_create_by!(position: q_index + 1) do |question|
      question.content = q_data[:content]
      question.question_type = q_data[:type]
      question.required = q_data[:required]
      question.options_array = q_data[:options] if q_data[:options]
    end
  end
  
  all_journals << journal
end

# Create extensive journal submissions and responses
published_journals = all_journals.select(&:published)

learners.each do |student|
  # Each student completes 60-80% of available journals
  journals_to_complete = published_journals.sample((published_journals.length * 0.6).to_i + rand(0...(published_journals.length * 0.2).to_i))
  
  journals_to_complete.each do |journal|
    # Create submission
    submission_status = ['submitted', 'submitted', 'submitted', 'in_progress'].sample # 75% submitted
    submission = journal.journal_submissions.find_or_create_by!(user: student) do |sub|
      sub.status = submission_status
      sub.completed_at = submission_status == 'submitted' ? rand(1..21).days.ago : nil
    end

    # Create realistic responses
    journal.questions.each do |question|
      response_content = case question.question_type
      when 'free_text'
        realistic_responses = [
          "This week I deepened my understanding of #{['collaborative learning', 'critical thinking', 'problem-solving methodologies', 'evidence-based practice', 'reflective practice', 'professional communication'].sample}. The most significant insight was how #{['theory connects to real-world applications', 'different perspectives enhance understanding', 'systematic approaches improve outcomes', 'feedback accelerates learning', 'practice builds confidence'].sample}.",
          
          "I encountered challenges with #{['time management', 'complex concepts', 'technical skills', 'group dynamics', 'information overload'].sample}, but I addressed this by #{['breaking tasks into smaller steps', 'seeking clarification from peers and instructors', 'practicing regularly', 'using organizational tools', 'connecting new information to prior knowledge'].sample}. This approach helped me #{['gain confidence', 'improve performance', 'develop better strategies', 'overcome obstacles'].sample}.",
          
          "The #{['hands-on experience', 'group discussions', 'case study analysis', 'practical applications', 'peer feedback'].sample} was particularly valuable because it #{['made abstract concepts concrete', 'provided multiple perspectives', 'allowed for immediate application', 'built collaborative skills', 'enhanced critical thinking'].sample}. I plan to #{['continue this approach', 'apply these insights in future work', 'share this strategy with others', 'build on this foundation'].sample}.",
          
          "Reflecting on my #{['professional development', 'skill acquisition', 'learning process', 'growth mindset', 'goal achievement'].sample}, I recognize that #{['consistent practice is essential', 'feedback is invaluable', 'self-reflection drives improvement', 'collaboration enhances learning', 'challenges promote growth'].sample}. Moving forward, I will focus on #{['maintaining momentum', 'seeking new challenges', 'supporting others', 'continuous improvement', 'applying what I\'ve learned'].sample}."
        ]
        realistic_responses.sample
        
      when 'likert_scale'
        # Weighted toward positive responses
        weighted_options = ['2', '3', '3', '4', '4', '4', '5', '5']
        weighted_options.sample
        
      when 'multiple_response'
        if question.options_array&.any?
          num_selections = [1, 1, 2, 2, 3].sample # Mostly 1-2 selections
          question.options_array.sample(num_selections).join(', ')
        else
          "Multiple selections made"
        end
        
      when 'single_response'
        if question.options_array&.any?
          question.options_array.sample
        else
          case question.content.to_s.downcase
          when /hours?/
            "#{rand(1..15)} hours"
          when /date/
            rand(1..7).days.ago.strftime("%B %d, %Y")
          when /grade|level/
            ["Freshman", "Sophomore", "Junior", "Senior", "Graduate"].sample
          else
            "Sample response"
          end
        end
        
      else
        "Thoughtful response for #{question.question_type} question"
      end

      Response.find_or_create_by!(user: student, question: question) do |response|
        response.content = response_content
        response.status = submission_status == 'submitted' ? 'submitted' : 'draft'
        response.submitted_at = submission.completed_at
      end
    end

    # Add instructor feedback for 40% of submitted assignments
    if submission.status == 'submitted' && [true, false, false].sample
      instructor_for_feedback = [journal.user, instructors.sample].sample
      
      feedback_comments = [
        "Excellent reflection! Your insights about #{['collaborative learning', 'professional development', 'skill application', 'critical thinking'].sample} demonstrate deep understanding. I particularly appreciate how you connected theory to practice. Your #{['self-awareness', 'analytical approach', 'growth mindset', 'commitment to improvement'].sample} is evident throughout your responses.",
        
        "Strong work on this reflection. You've shown good progress in #{['understanding key concepts', 'applying learning strategies', 'developing professional skills', 'building self-awareness'].sample}. Your description of how you overcame challenges shows resilience and problem-solving skills. Consider exploring #{['additional resources', 'peer collaboration', 'advanced techniques', 'broader applications'].sample} to further enhance your learning.",
        
        "I can see significant growth in your #{['reflective practice', 'critical analysis', 'professional development', 'learning approach'].sample}. Your honest assessment of challenges and thoughtful strategies for improvement demonstrate maturity. The connections you made between #{['theory and practice', 'different concepts', 'personal and professional growth'].sample} are particularly insightful. Keep up the excellent work!",
        
        "Thank you for this thorough and thoughtful reflection. Your #{['detailed analysis', 'honest self-assessment', 'strategic thinking', 'commitment to growth'].sample} is commendable. I encourage you to #{['continue this level of reflection', 'share your insights with peers', 'apply these strategies in other contexts', 'build on these strengths'].sample}. Your progress is evident and inspiring.",
        
        "Your reflection shows great depth and self-awareness. The way you've analyzed your #{['learning process', 'skill development', 'professional growth', 'challenge-solving approach'].sample} provides valuable insights. I particularly noted your #{['strategic approach to obstacles', 'integration of feedback', 'proactive learning mindset', 'collaborative spirit'].sample}. This level of reflection will serve you well in your future endeavors."
      ]
      
      Comment.find_or_create_by!(user: instructor_for_feedback, journal_submission: submission) do |comment|
        comment.content = feedback_comments.sample
      end
    end
  end
end

puts "\n🎉 COMPREHENSIVE DEMO DATA CREATED SUCCESSFULLY! 🎉"
puts "\n" + "="*60
puts "PONDERO COMPREHENSIVE DEMO ENVIRONMENT"
puts "="*60
puts "📊 DATA SUMMARY:"
puts "• #{User.count} Total Users (#{User.where(role: 'instructor').count} Instructors, #{User.where(role: 'learner').count} Learners, #{User.where(role: 'administrator').count} Admins)"
puts "• #{Journal.count} Total Journals (#{Journal.where(published: true).count} Published, #{Journal.where(published: false).count} Private)"
puts "• #{Question.count} Total Questions across all journals"
puts "• #{Response.count} Student Responses submitted"
puts "• #{JournalSubmission.count} Journal Submissions"
puts "• #{Comment.count} Instructor Comments/Feedback"
puts "• #{Theme.count} Themes Available"
puts ""
puts "🔑 PRIMARY DEMO ACCOUNTS:"
puts "="*30
puts "👨‍🏫 INSTRUCTOR (Dr. Jane Smith):"
puts "   📧 Email: instructor@pondero.demo"
puts "   🔒 Password: demo123456"
puts "   📚 Features: Create journals, analytics, student feedback"
puts ""
puts "👨‍🎓 STUDENT (Alex Student):"
puts "   📧 Email: learner@pondero.demo"
puts "   🔒 Password: demo123456"
puts "   📝 Features: Complete journals, view progress, export PDFs"
puts ""
puts "👩‍💼 ADMIN (Sarah Administrator):"
puts "   📧 Email: admin@pondero.demo"
puts "   🔒 Password: demo123456"
puts "   ⚙️ Features: Full system access, user management, analytics"
puts ""
puts "📚 JOURNAL TEMPLATES AVAILABLE:"
puts "• Weekly Learning Reflection (#{Journal.find_by(title: "Weekly Learning Reflection")&.questions&.count} questions)"
puts "• Clinical Skills Assessment Journal (#{Journal.find_by(title: "Clinical Skills Assessment Journal")&.questions&.count} questions)"
puts "• Research Project Progress Log (#{Journal.find_by(title: "Research Project Progress Log")&.questions&.count} questions)"
puts "• Leadership Development Portfolio (#{Journal.find_by(title: "Leadership Development Portfolio")&.questions&.count} questions)"
puts "• Student Teaching Reflection Journal (#{Journal.find_by(title: "Student Teaching Reflection Journal")&.questions&.count} questions)"
puts "• Innovation & Entrepreneurship Lab (#{Journal.find_by(title: "Innovation & Entrepreneurship Lab")&.questions&.count} questions)"
puts "• Global Perspectives & Cultural Competency (#{Journal.find_by(title: "Global Perspectives & Cultural Competency")&.questions&.count} questions)"
puts "• Community Service Learning Journal (#{Journal.find_by(title: "Community Service Learning Journal")&.questions&.count} questions)"
puts ""
puts "🎨 THEMES:"
puts "• Default (Blue) • Dark Mode • Warm (Orange) • Minimal (Clean)"
puts ""
puts "🚀 START DEMO:"
puts "   rails server"
puts "   Visit: http://localhost:3000"
puts "="*60
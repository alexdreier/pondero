#!/usr/bin/env ruby

puts "🧪 Testing Auto-Save System Setup"
puts "=" * 40

# Test basic form structure
demo_student = User.find_by(email: 'learner@pondero.demo')
journal = Journal.find_by(title: 'Weekly Learning Reflection')
question = journal.questions.first

puts "📋 Test Setup:"
puts "  Student: #{demo_student.email}"
puts "  Journal: #{journal.title}"
puts "  Question: #{question.content.to_s.first(50)}..."
puts "  Question ID: #{question.id}"

# Check existing response
existing_response = demo_student.responses.find_by(question: question)
puts "\n📝 Existing Response:"
if existing_response
  puts "  Response ID: #{existing_response.id}"
  puts "  Status: #{existing_response.status}"
  puts "  Content length: #{existing_response.content.to_s.length}"
else
  puts "  No existing response found"
end

# Test manual response creation (simulating auto-save)
puts "\n🔧 Testing Manual Response Creation:"
test_content = "This is a test response created at #{Time.current}"

if existing_response
  # Update existing
  existing_response.update(content: test_content)
  puts "  Updated existing response"
  puts "  New content: #{existing_response.content.to_s.first(50)}..."
else
  # Create new
  new_response = Response.create(
    user: demo_student,
    question: question,
    content: test_content,
    status: 'draft'
  )
  
  if new_response.persisted?
    puts "  ✅ Created new response: #{new_response.id}"
    puts "  Content: #{new_response.content.to_s.first(50)}..."
  else
    puts "  ❌ Failed to create response: #{new_response.errors.full_messages}"
  end
end

# Check completion calculation
submission = journal.journal_submissions.find_or_create_by(user: demo_student)
puts "\n📊 Completion Check:"
puts "  All required answered: #{submission.all_required_answered?}"
puts "  Completion percentage: #{submission.completion_percentage}%"
puts "  Total responses: #{demo_student.responses.joins(:question).where(questions: { journal: journal }).count}"

puts "\n✅ Manual response creation test completed"
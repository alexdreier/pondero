#!/usr/bin/env ruby

puts "🔧 TESTING AUTO-SAVE FOR SPECIFIC QUESTIONS"
puts "=" * 50

# Test if we can manually create responses for Q3-Q6
demo_student = User.find_by(email: 'learner@pondero.demo')
journal = Journal.find_by(title: 'Weekly Learning Reflection')

# Q3: multiple_response
q3 = journal.questions.find_by(question_type: 'multiple_response')
puts "\n🧪 Testing Q3 (multiple_response) Response Creation:"
puts "  Question ID: #{q3.id}"

begin
  test_response_q3 = demo_student.responses.create!(
    question: q3,
    content: "Readings,Videos"  # Simulating multiple selections
  )
  puts "  ✅ SUCCESS: Created response ID #{test_response_q3.id}"
  puts "  Content: #{test_response_q3.content}"
rescue => e
  puts "  ❌ FAILED: #{e.message}"
end

# Q4: free_text (the second required free_text question)
q4 = journal.questions.where(question_type: 'free_text', required: true).order(:position).second
puts "\n🧪 Testing Q4 (free_text) Response Creation:"
puts "  Question ID: #{q4.id}"

begin
  test_response_q4 = demo_student.responses.create!(
    question: q4,
    content: "This is a test response for question 4"
  )
  puts "  ✅ SUCCESS: Created response ID #{test_response_q4.id}"
  puts "  Content: #{test_response_q4.content}"
rescue => e
  puts "  ❌ FAILED: #{e.message}"
end

# Q6: likert_scale (the second required likert_scale question)
q6 = journal.questions.where(question_type: 'likert_scale', required: true).order(:position).second
puts "\n🧪 Testing Q6 (likert_scale) Response Creation:"
puts "  Question ID: #{q6.id}"

begin
  test_response_q6 = demo_student.responses.create!(
    question: q6,
    content: "3 - Moderately Confident"
  )
  puts "  ✅ SUCCESS: Created response ID #{test_response_q6.id}"
  puts "  Content: #{test_response_q6.content}"
rescue => e
  puts "  ❌ FAILED: #{e.message}"
end

# Check completion status after adding responses
puts "\n📊 COMPLETION STATUS AFTER TEST RESPONSES:"
submission = journal.journal_submissions.find_by(user: demo_student)
puts "  Total Responses: #{demo_student.responses.joins(:question).where(questions: { journal: journal }).count}"
puts "  All Required Answered: #{submission.all_required_answered?}"
puts "  Completion %: #{submission.completion_percentage}"

puts "\n" + "=" * 50
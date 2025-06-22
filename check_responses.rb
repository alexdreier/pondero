#!/usr/bin/env ruby

puts "🔍 SYSTEMATIC DEBUGGING: Journal Completion Status"
puts "=" * 60

# Find demo student and journal
demo_student = User.find_by(email: 'learner@pondero.demo')
journal = Journal.find_by(title: 'Weekly Learning Reflection')

puts "📋 Basic Info:"
puts "  Student: #{demo_student.email}"
puts "  Journal: #{journal.title}"
puts "  Total Questions: #{journal.questions.count}"
puts "  Required Questions: #{journal.questions.where(required: true).count}"

puts "\n📝 Current Responses:"
responses = demo_student.responses.joins(:question).where(questions: { journal: journal })
puts "  Total Responses: #{responses.count}"

journal.questions.ordered.each_with_index do |question, index|
  response = responses.find { |r| r.question_id == question.id }
  status = response ? "✅ ANSWERED" : "❌ MISSING"
  content_preview = response&.content.to_s.strip.first(50) || "No content"
  
  puts "  Q#{index + 1} (#{question.required? ? 'REQUIRED' : 'optional'}): #{status}"
  puts "      Content: #{content_preview}#{'...' if content_preview.length == 50}"
  puts "      Response ID: #{response&.id || 'N/A'}"
end

# Check journal submission
submission = journal.journal_submissions.find_by(user: demo_student)
puts "\n📊 Journal Submission Status:"
if submission
  puts "  Submission ID: #{submission.id}"
  puts "  Status: #{submission.status}"
  puts "  Completion %: #{submission.completion_percentage}"
  puts "  All Required Answered: #{submission.all_required_answered?}"
  puts "  Created: #{submission.created_at}"
  puts "  Updated: #{submission.updated_at}"
else
  puts "  ❌ No journal submission found - creating one..."
  submission = journal.journal_submissions.find_or_create_by(user: demo_student)
  puts "  ✅ Created submission ID: #{submission.id}"
  puts "  Completion %: #{submission.completion_percentage}"
  puts "  All Required Answered: #{submission.all_required_answered?}"
end

puts "\n🔧 SYSTEMATIC ACTION NEEDED:"
if submission.all_required_answered?
  puts "  ✅ All required questions are answered"
  puts "  🎯 ISSUE: Frontend not showing submit button - need to fix UI update"
else
  missing_required = journal.questions.where(required: true).select do |q|
    !responses.any? { |r| r.question_id == q.id && r.content.present? }
  end
  puts "  ❌ Missing required responses:"
  missing_required.each do |q|
    puts "    - Question #{journal.questions.ordered.index(q) + 1}: #{q.content.to_s.first(50)}..."
  end
end

puts "\n" + "=" * 60
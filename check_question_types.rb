#!/usr/bin/env ruby

puts "🔍 CHECKING QUESTION TYPES FOR AUTO-SAVE"
puts "=" * 50

journal = Journal.find_by(title: 'Weekly Learning Reflection')

journal.questions.ordered.each_with_index do |question, index|
  puts "Q#{index + 1}: #{question.question_type}"
  puts "  Required: #{question.required?}"
  puts "  Content: #{question.content.to_s.first(60)}..."
  puts
end
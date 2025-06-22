#!/usr/bin/env ruby

puts "🔍 DEBUGGING AUTO-SAVE FORM ISSUES"
puts "=" * 50

# Find demo student and journal
demo_student = User.find_by(email: 'learner@pondero.demo')
journal = Journal.find_by(title: 'Weekly Learning Reflection')

puts "📋 Basic Info:"
puts "  Student: #{demo_student.email}"
puts "  Journal: #{journal.title}"

puts "\n🔍 EXAMINING QUESTIONS AND FORMS:"
journal.questions.ordered.each_with_index do |question, index|
  puts "\nQ#{index + 1}: #{question.question_type} (##{question.id})"
  puts "  Required: #{question.required?}"
  
  # Check if there's an existing response
  response = demo_student.responses.find_by(question: question)
  puts "  Current Response: #{response ? "ID #{response.id}" : "None"}"
  
  # Check form URL that would be generated
  if response&.persisted?
    form_url = "/responses/#{response.id}"
    form_method = "patch"
  else
    form_url = "/journals/#{question.journal.id}/questions/#{question.id}/responses"
    form_method = "post"
  end
  
  puts "  Form URL: #{form_method.upcase} #{form_url}"
  
  # Check route exists
  begin
    case form_method
    when "post"
      if Rails.application.routes.recognize_path(form_url, method: :post)
        puts "  Route Status: ✅ Valid POST route"
      end
    when "patch"
      if Rails.application.routes.recognize_path(form_url, method: :patch)
        puts "  Route Status: ✅ Valid PATCH route"
      end
    end
  rescue ActionController::RoutingError => e
    puts "  Route Status: ❌ INVALID ROUTE - #{e.message}"
  end
end

puts "\n" + "=" * 50
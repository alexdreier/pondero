#!/usr/bin/env ruby

# Create demo feedback conversations
demo_student = User.find_by(email: 'learner@pondero.demo')
instructor = User.find_by(email: 'instructor@pondero.demo')
response = demo_student.responses.find { |r| r.supports_feedback? }

puts "Creating feedback conversations for response #{response.id}"
puts "Response content: #{response.content.to_s.first(100)}..."

# Clear any existing feedback
ResponseFeedback.where(response: response).destroy_all

# First instructor feedback
feedback1 = ResponseFeedback.create!(
  response: response,
  user: instructor,
  content: "Great reflection, Alex! I love how you're connecting research methodologies to real-world problems. Your awareness of the statistical concepts you're still working through shows excellent self-assessment. Can you give me a specific example of a qualitative analysis technique you've found particularly useful?",
  created_at: 1.day.ago,
  read_by_student: true
)

puts "Created instructor feedback: #{feedback1.id}"

# Student reply
feedback2 = ResponseFeedback.create!(
  response: response,
  user: demo_student,
  parent: feedback1,
  content: "Thank you for the encouragement, Dr. Smith! One technique that really clicked for me was thematic analysis. In our last assignment, I was able to identify recurring patterns in interview data about student motivation. It helped me see how different students express similar underlying concerns in very different ways.",
  created_at: 20.hours.ago,
  read_by_student: true
)

puts "Created student reply: #{feedback2.id}"

# Follow-up instructor feedback
feedback3 = ResponseFeedback.create!(
  response: response,
  user: instructor,
  parent: feedback2,
  content: "Excellent example! Thematic analysis is indeed powerful for uncovering those hidden patterns. Your insight about students expressing similar concerns differently is very perceptive - that's exactly the kind of deeper understanding that separates good researchers from great ones. Keep building on that analytical thinking!",
  created_at: 18.hours.ago,
  read_by_student: false
)

puts "Created instructor follow-up: #{feedback3.id}"

puts "Demo feedback conversations created successfully!"
puts "Total feedback count: #{response.reload.feedback_count}"
puts "Unread count: #{response.unread_feedback_count}"
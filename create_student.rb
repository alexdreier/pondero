#!/usr/bin/env ruby

# Load Rails environment
require_relative 'config/environment'

# Create test student
student = User.create!(
  email: 'student.test@example.com',
  password: 'password123', 
  password_confirmation: 'password123',
  first_name: 'Alex',
  last_name: 'Student', 
  role: 'learner'
)

puts "✅ Created test student: #{student.email}"
puts "   Name: #{student.display_name}"
puts "   Role: #{student.role}"
puts "   ID: #{student.id}"
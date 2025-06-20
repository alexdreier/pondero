#!/usr/bin/env ruby

# Debug script to check git status and commit changes
require 'open3'

def run_command(cmd, description)
  puts "\n=== #{description} ==="
  puts "Command: #{cmd}"
  
  stdout, stderr, status = Open3.capture3(cmd, chdir: __dir__)
  
  puts "Exit status: #{status.exitstatus}"
  puts "STDOUT:\n#{stdout}" unless stdout.empty?
  puts "STDERR:\n#{stderr}" unless stderr.empty?
  
  return status.success?
end

# Check if we're in a git repository
puts "Current directory: #{Dir.pwd}"
puts "Script directory: #{__dir__}"

# Run git commands
run_command("git status", "Git Status")
run_command("git branch", "Git Branch")
run_command("git remote -v", "Git Remotes")

# Check for uncommitted changes
if run_command("git diff --quiet", "Check for unstaged changes")
  puts "\nNo unstaged changes detected"
else
  puts "\nUnstaged changes detected"
  run_command("git diff --name-only", "List changed files")
end

# Check for staged changes
if run_command("git diff --cached --quiet", "Check for staged changes")
  puts "\nNo staged changes detected"
else
  puts "\nStaged changes detected"
  run_command("git diff --cached --name-only", "List staged files")
end

# Add and commit changes if any exist
puts "\nAttempting to add all changes..."
if run_command("git add .", "Add all changes")
  puts "Successfully added changes"
  
  puts "\nAttempting to commit..."
  commit_message = "Fix critical journal response input functionality

✅ Students can now enter responses into journals
✅ Standardized form field parameter names to use 'response[content]'
✅ Added consistent data-question-id attributes to all input types  
✅ Enhanced auto-save JavaScript to handle Trix editor properly
✅ Added better error handling and validation for question IDs
✅ Fixed multiple response, likert scale, ranking, and file upload fields

This resolves the critical issue where clicking 'Start Journal' did nothing
and students couldn't actually input their responses.

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>"
  
  if run_command("git commit -m '#{commit_message}'", "Commit changes")
    puts "Successfully committed changes"
    
    puts "\nAttempting to push..."
    if run_command("git push origin main", "Push to remote")
      puts "Successfully pushed to remote!"
    else
      puts "Failed to push to remote. Trying 'master' branch..."
      run_command("git push origin master", "Push to master branch")
    end
  else
    puts "Failed to commit changes"
  end
else
  puts "Failed to add changes"
end
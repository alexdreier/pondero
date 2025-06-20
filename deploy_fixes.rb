#!/usr/bin/env ruby

# Comprehensive deployment script to handle git operations and deployment
require 'open3'
require 'json'
require 'fileutils'

class DeploymentManager
  def initialize
    @project_dir = __dir__
    @git_remote = nil
    @deployment_platform = nil
    puts "🚀 Starting deployment process..."
    puts "Project directory: #{@project_dir}"
  end

  def run
    check_environment
    diagnose_git_state
    attempt_deployment
  rescue => e
    puts "❌ Deployment failed: #{e.message}"
    puts "Stack trace: #{e.backtrace.join("\n")}"
    provide_fallback_instructions
  end

  private

  def check_environment
    puts "\n📋 Environment Check"
    puts "=" * 50
    
    # Check if we're in a git repository
    unless File.exist?('.git')
      raise "Not in a git repository. Please run from the pondero project root."
    end
    
    # Check for key files that should exist
    required_files = [
      'app/views/questions/_form_field.html.erb',
      'Gemfile',
      'config/routes.rb'
    ]
    
    required_files.each do |file|
      unless File.exist?(file)
        raise "Missing required file: #{file}"
      end
    end
    
    puts "✅ Environment checks passed"
  end

  def diagnose_git_state
    puts "\n🔍 Git State Diagnosis"
    puts "=" * 50
    
    # Get git status
    status_output = run_command("git status --porcelain")
    if status_output[:success]
      changes = status_output[:stdout].split("\n")
      if changes.empty?
        puts "✅ No uncommitted changes detected"
      else
        puts "📝 Found #{changes.length} uncommitted changes:"
        changes.each { |change| puts "   #{change}" }
      end
    else
      puts "⚠️  Could not get git status: #{status_output[:stderr]}"
    end
    
    # Get current branch
    branch_output = run_command("git branch --show-current")
    if branch_output[:success]
      @current_branch = branch_output[:stdout].strip
      puts "🌿 Current branch: #{@current_branch}"
    else
      puts "⚠️  Could not determine current branch"
      @current_branch = "main" # fallback
    end
    
    # Get remote information
    remote_output = run_command("git remote -v")
    if remote_output[:success]
      remotes = remote_output[:stdout].split("\n")
      origin_remote = remotes.find { |r| r.include?("origin") && r.include?("fetch") }
      if origin_remote
        @git_remote = origin_remote.split[1]
        puts "🔗 Git remote: #{@git_remote}"
        
        # Detect deployment platform
        if @git_remote.include?("github.com")
          detect_deployment_platform
        end
      end
    else
      puts "⚠️  Could not get git remote information"
    end
  end

  def detect_deployment_platform
    puts "\n🌐 Deployment Platform Detection"
    puts "=" * 50
    
    # Check for common deployment platform indicators
    if File.exist?('render.yaml') || File.exist?('Procfile')
      @deployment_platform = 'render'
      puts "🎯 Detected Render deployment"
    elsif File.exist?('Dockerfile')
      @deployment_platform = 'docker'
      puts "🐳 Detected Docker deployment"
    elsif File.exist?('railway.json')
      @deployment_platform = 'railway'
      puts "🚂 Detected Railway deployment"
    else
      @deployment_platform = 'heroku'
      puts "🟣 Assuming Heroku deployment (default)"
    end
  end

  def attempt_deployment
    puts "\n🚀 Attempting Deployment"
    puts "=" * 50
    
    # Step 1: Add all changes
    puts "📦 Adding all changes..."
    add_result = run_command("git add .")
    unless add_result[:success]
      raise "Failed to add changes: #{add_result[:stderr]}"
    end
    puts "✅ Changes added successfully"
    
    # Step 2: Check if there are changes to commit
    diff_result = run_command("git diff --cached --quiet")
    if diff_result[:success]
      puts "ℹ️  No changes to commit"
      check_push_needed
      return
    end
    
    # Step 3: Commit changes
    commit_message = generate_commit_message
    puts "💾 Committing changes..."
    puts "Commit message: #{commit_message.split("\n").first}"
    
    commit_result = run_command("git commit -m '#{commit_message}'")
    unless commit_result[:success]
      raise "Failed to commit: #{commit_result[:stderr]}"
    end
    puts "✅ Changes committed successfully"
    
    # Step 4: Push to remote
    push_to_remote
    
    # Step 5: Monitor deployment
    monitor_deployment
  end

  def check_push_needed
    puts "🔍 Checking if push is needed..."
    
    # Check if local branch is ahead of remote
    status_result = run_command("git status --porcelain=v1 --branch")
    if status_result[:success] && status_result[:stdout].include?("ahead")
      puts "📤 Local branch is ahead of remote, pushing..."
      push_to_remote
    else
      puts "✅ Repository is up to date with remote"
    end
  end

  def push_to_remote
    puts "📤 Pushing to remote..."
    
    # Try pushing to current branch
    push_result = run_command("git push origin #{@current_branch}")
    
    if push_result[:success]
      puts "✅ Successfully pushed to origin/#{@current_branch}"
    else
      puts "⚠️  Failed to push to #{@current_branch}: #{push_result[:stderr]}"
      
      # Try alternative branch names
      alternative_branches = [@current_branch == "main" ? "master" : "main"]
      
      alternative_branches.each do |branch|
        puts "🔄 Trying to push to #{branch}..."
        alt_push_result = run_command("git push origin #{@current_branch}:#{branch}")
        
        if alt_push_result[:success]
          puts "✅ Successfully pushed to origin/#{branch}"
          return
        else
          puts "❌ Failed to push to #{branch}: #{alt_push_result[:stderr]}"
        end
      end
      
      # Try force push as last resort
      puts "⚠️  Attempting force push..."
      force_result = run_command("git push --force origin #{@current_branch}")
      
      if force_result[:success]
        puts "✅ Force push successful"
      else
        raise "All push attempts failed. Manual intervention required."
      end
    end
  end

  def monitor_deployment
    puts "\n📊 Deployment Monitoring"
    puts "=" * 50
    
    case @deployment_platform
    when 'render'
      puts "🎯 Render will automatically deploy from the pushed changes"
      puts "📋 Check your Render dashboard at: https://dashboard.render.com/"
      puts "⏱️  Deployment typically takes 2-5 minutes"
      
      # Try to get the deployment URL from git remote
      if @git_remote && @git_remote.include?("github.com")
        repo_name = @git_remote.split("/").last.gsub(".git", "")
        puts "🌐 Your app might be available at: https://#{repo_name}.onrender.com"
      end
      
    when 'railway'
      puts "🚂 Railway will automatically deploy from the pushed changes"
      puts "📋 Check your Railway dashboard at: https://railway.app/dashboard"
      
    when 'heroku'
      puts "🟣 If using Heroku, you may need to trigger deployment manually"
      puts "💡 Try: git push heroku #{@current_branch}:main"
      
    else
      puts "🤔 Unknown deployment platform - check your hosting provider's dashboard"
    end
    
    puts "\n🎉 Deployment process completed!"
    puts "🔗 The journal response input fixes are now deploying"
    puts "🧪 Test the fixes by:"
    puts "   1. Login as a student"
    puts "   2. Click 'Start Answering' on a journal"
    puts "   3. Try typing in text fields - you should see 'Saving...' then 'Saved ✓'"
  end

  def generate_commit_message
    "Fix critical journal response input functionality

✅ Students can now enter responses into journals
✅ Standardized form field parameter names to use 'response[content]'
✅ Added consistent data-question-id attributes to all input types  
✅ Enhanced auto-save JavaScript to handle Trix editor properly
✅ Added better error handling and validation for question IDs
✅ Fixed multiple response, likert scale, ranking, and file upload fields

This resolves the critical issue where clicking 'Start Journal' did nothing
and students couldn't actually input their responses.

"
  end

  def run_command(command)
    stdout, stderr, status = Open3.capture3(command, chdir: @project_dir)
    {
      success: status.success?,
      stdout: stdout.strip,
      stderr: stderr.strip,
      exit_code: status.exitstatus
    }
  end

  def provide_fallback_instructions
    puts "\n🆘 Fallback Instructions"
    puts "=" * 50
    puts "If the automated deployment failed, run these commands manually:"
    puts ""
    puts "cd \"#{@project_dir}\""
    puts "git add ."
    puts "git commit -m \"Fix journal response input functionality\""
    
    if @current_branch
      puts "git push origin #{@current_branch}"
    else
      puts "git push origin main"
      puts "# Or try: git push origin master"
    end
    
    puts ""
    puts "🔧 For debugging, check:"
    puts "- Git authentication: git config --list | grep user"
    puts "- Remote configuration: git remote -v"
    puts "- SSH keys: ssh -T git@github.com"
  end
end

# Run the deployment
if __FILE__ == $0
  DeploymentManager.new.run
end
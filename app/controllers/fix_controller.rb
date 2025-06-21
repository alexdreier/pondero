class FixController < ApplicationController
  def journals
    return render plain: "Access denied" unless current_user&.role == 'administrator'
    
    # Test the specific journal and user that's failing
    learner = User.find_by(email: 'learner@pondero.demo')
    journal = Journal.find(1)
    
    result = "DETAILED ACCESSIBILITY TEST:\n"
    result += "Journal ID: #{journal.id}\n"
    result += "Journal Title: #{journal.title}\n"
    result += "Raw access_level from DB: '#{journal.read_attribute(:access_level)}'\n"
    result += "access_level method: '#{journal.access_level}'\n"
    result += "Raw visibility from DB: '#{journal.read_attribute(:visibility)}'\n"
    result += "visibility method: '#{journal.visibility}'\n"
    result += "published?: #{journal.published?}\n"
    result += "\n"
    result += "User: #{learner.email}\n"
    result += "User role: #{learner.role}\n"
    result += "User == journal.user: #{learner == journal.user}\n"
    result += "User.administrator?: #{learner.role == 'administrator'}\n"
    result += "\n"
    result += "STEP BY STEP:\n"
    result += "1. visible_to?(learner): #{journal.visible_to?(learner)}\n"
    
    # Manual check of accessible_to logic
    if !journal.visible_to?(learner)
      result += "2. FAILED at visible_to? check\n"
    elsif learner == journal.user || learner.role == 'administrator'
      result += "2. PASSED - user is owner or admin\n"
    else
      result += "2. Checking access_level case statement...\n"
      case journal.access_level
      when 'open'
        result += "3. access_level is 'open' - should return TRUE\n"
      when 'read_only'
        result += "3. access_level is 'read_only' - should return TRUE\n"
      when 'restricted'
        result += "3. access_level is 'restricted' - returns FALSE\n"
      else
        result += "3. access_level is '#{journal.access_level}' - unknown, returns FALSE\n"
      end
    end
    
    result += "\nFINAL accessible_to? result: #{journal.accessible_to?(learner)}\n"
    
    render plain: result
  end
  
  def test_journal_access
    # Simulate a learner accessing journal 1
    learner = User.find_by(email: 'learner@pondero.demo')
    journal = Journal.find(1)
    
    # Temporarily log in as learner for this test
    sign_in(learner)
    
    # Now test the exact same logic as the journals controller
    result = "SIMULATING JOURNAL ACCESS AS LEARNER:\n\n"
    
    # Test current_user
    result += "current_user: #{current_user&.email}\n"
    result += "current_user.learner?: #{current_user&.learner?}\n"
    result += "\n"
    
    # Test the accessibility check
    result += "journal.accessible_to?(current_user): #{journal.accessible_to?(current_user)}\n"
    
    # Test what happens in the journals controller show action
    if journal.accessible_to?(current_user)
      result += "SUCCESS: Should proceed to journal show page\n"
      result += "Journal can_respond?: #{journal.can_respond?(current_user)}\n"
    else
      result += "FAILURE: Would redirect to journals_path\n"
    end
    
    render plain: result
  end
end
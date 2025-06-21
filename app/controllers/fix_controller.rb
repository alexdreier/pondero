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
end
class FixController < ApplicationController
  def journals
    return render plain: "Access denied" unless current_user&.role == 'administrator'
    
    # First, let's see what we have in the database
    all_journals = Journal.all.map do |journal|
      "ID #{journal.id}: #{journal.title} - published: #{journal.published?}, access_level: #{journal.access_level}, visibility: #{journal.visibility}"
    end
    
    journals_updated = 0
    Journal.where(published: true, access_level: 'restricted').find_each do |journal|
      journal.update!(access_level: 'open')
      journals_updated += 1
    end
    
    result = "JOURNAL DIAGNOSTIC:\n"
    result += all_journals.join("\n")
    result += "\n\nUPDATE RESULT:\n"
    result += "Updated #{journals_updated} journals from 'restricted' to 'open' access_level."
    
    render plain: result
  end
end
class FixController < ApplicationController
  def journals
    return render plain: "Access denied" unless current_user&.role == 'administrator'
    
    journals_updated = 0
    Journal.where(published: true, access_level: 'restricted').find_each do |journal|
      journal.update!(access_level: 'open')
      journals_updated += 1
    end
    
    render plain: "Updated #{journals_updated} journals from 'restricted' to 'open' access_level. Start Journal buttons should now work."
  end
end
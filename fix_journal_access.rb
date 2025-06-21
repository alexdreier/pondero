# Fix journal access levels to allow learner access
journals_updated = 0
Journal.where(published: true, access_level: 'restricted').find_each do |journal|
  journal.update!(access_level: 'open')
  puts "Updated journal #{journal.id}: #{journal.title}"
  journals_updated += 1
end

puts "Updated #{journals_updated} journals from 'restricted' to 'open' access_level"
puts "Learners should now be able to access published journals"
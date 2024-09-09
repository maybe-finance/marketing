# Load all seed files in alphabetical order
Dir[Rails.root.join("db", "seeds", "*.rb")].sort.each do |seed_file|
  load seed_file
end

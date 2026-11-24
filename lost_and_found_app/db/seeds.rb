# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
puts "Seeding database..."

facilities_data = [
  {name: "University Library", location:"Main Campus"},
  {name: "Chung Chi College Elisabeth Luce Moore Library", location:"Chung Chi College"},
  {name: "New Asia College Ch’ien Mu Library", location:"New Asia College"},
  {name: "United College Wu Chung Library", location:"United College"},
  {name: "University Sport Centre", location:"Next to Sir Philip Haddon-Cave Sports Field"},
  {name: "Charles Leung Gymnasium, New Asia College", location:"New Asia College"},
  {name: "Thomas H.C. Cheung Gymnasium, United College", location:"United College"},
  {name: "Shaw College Indoor Multi-purpose Sports Hall", location:"Shaw College"}
]

facilities_data.each do |facility|
  Facility.find_or_create_by!(name: facility[:name]) do |f|
    f.location = facility[:location]
  end
end

puts "Created #{Facility.count} facilities"

staff_data = [
  { email: "staff.ulib@example.com", 
    name: "ULib Staff", 
    facility: "University Library"},

  { email: "staff.cclib@example.com", 
    name: "CC Lib Staff", 
    facility: "Chung Chi College Elisabeth Luce Moore Library"},

  { email: "staff.nalib@example.com", 
    name: "NA Lib Staff", 
    facility: "New Asia College Ch’ien Mu Library" },

  { email: "staff.uclib@example.com", 
    name: "UC Lib Staff", 
    facility: "United College Wu Chung Library" },

  { email: "staff.usc@example.com", 
    name: "Sport Centre Staff", 
    facility: "University Sport Centre" },

  { email: "staff.nagym@example.com", 
    name: "NA Gym Staff", 
    facility: "Charles Leung Gymnasium, New Asia College" },

  { email: "staff.ucgym@example.com", 
    name: "UC Gym Staff", 
    facility: "Thomas H.C. Cheung Gymnasium, United College" },

  { email: "staff.shaw@example.com", 
    name: "Shaw Staff", 
    facility: "Shaw College Indoor Multi-purpose Sports Hall" }
]

staff_data.each do |data|
  facility = Facility.find_by!(name: data[:facility])
  user = User.find_or_initialize_by(email: data[:email])
  user.name = data[:name]
  user.role = :staff              
  user.facility = facility      
  user.password = "password"   
  user.save!
end

puts "Created #{User.staff.count} staff"

general_data = [
  {email: "user1@example.com", name: "General User 1"},
  {email: "user2@example.com", name: "General User 2"},
  {email: "user3@example.com", name: "General User 3"}
]

general_data.each do |data|
  general = User.find_or_initialize_by(email: data[:email])
  general.name = data[:name]
  general.role = :general
  general.facility_id = nil
  general.password = "password"
  general.save!
end

puts "Created #{User.general.count} general users"

items_data = [
  { facility: "University Library", 
    title: "Blue Hoodie", description: "Hoodie",
    category: :clothing, status: :available,
    date_found: "2026-01-10 14:30" },

  { facility: "University Library", 
    title: "Blue Jacket", description: "Jacket",
    category: :clothing, status: :available,
    date_found: "2026-01-15 15:30" },

  { facility: "University Library", 
    title: "HKID Card", description: "ID Card",
    category: :ID_card, status: :claim_pending,
    date_found: "2026-01-04 17:45" },

  { facility: "University Library", 
    title: "Black Water Bottle", description: "Bottle",
    category: :water_bottle, status: :claim_pending,
    date_found: "2026-01-09 16:15" },

  { facility: "University Library", 
    title: "Black Power Bank", description: "Power Bank",
    category: :electronic_device, status: :claimed,
    date_found: "2026-01-19 16:30" },
  
  { facility: "Chung Chi College Elisabeth Luce Moore Library",
    title: "Stainless Water Bottle", description: "Bottle",
    category: :water_bottle, status: :available,
    date_found: "2026-01-12 11:00" },

  { facility: "New Asia College Ch’ien Mu Library",
    title: "Black USB Drive", description: "USB",
    category: :electronic_device, status: :claim_pending,
    date_found: "2026-01-15 16:45" },

  { facility: "United College Wu Chung Library",
    title: "Student ID Card", description: "ID Card",
    category: :ID_card, status: :claimed,
    date_found: "2026-01-08 09:20" },

  { facility: "University Sport Centre",
    title: "Sports Towel", description: "Towel",
    category: :others, status: :available,
    date_found: "2026-01-18 18:10" },

  { facility: "Charles Leung Gymnasium, New Asia College",
    title: "Wireless headphones", description: "Headphones",
    category: :electronic_device, status: :claim_pending,
    date_found: "2026-01-20 17:00" },

  { facility: "Thomas H.C. Cheung Gymnasium, United College",
    title: "Black Jacket", description: "Jacket",
    category: :clothing, status: :claimed,
    date_found: "2026-01-11 13:15" },

  { facility: "Shaw College Indoor Multi-purpose Sports Hall",
    title: "Basketball", description: "Basketball",
    category: :others, status: :available,
    date_found: "2026-01-22 19:30" }
]

items_data.each do |data|
  facility = Facility.find_by!(name: data[:facility])
  item = Item.find_or_initialize_by(facility: facility, title: data[:title])
  item.description = data[:description]
  item.category    = data[:category]
  item.status      = data[:status]
  item.date_found  = Time.zone.parse(data[:date_found])
  item.save!(validate: false)
end

puts "Created #{Item.count} items"
puts "Statuses: available=#{Item.available.count}, claim_pending=#{Item.claim_pending.count}, claimed=#{Item.claimed.count}"
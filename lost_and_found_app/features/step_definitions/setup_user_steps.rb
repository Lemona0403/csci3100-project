Given (/^facility "(.*)" exists$/) do |name|
  Facility.find_or_create_by!(name: name) do |f|
    f.location = "Campus"
  end
end

Given (/^staff "(.*)" belongs to "(.*)"$/) do |email, facility_name|
  facility = Facility.find_by!(name: facility_name)
  user = User.find_or_initialize_by(email: email)
  user.name = "Staff #{email}"
  user.role = :staff
  user.facility = facility
  user.password = "ABCabc123!@#"
  user.save!
end

Given (/^general user "(.*)" exists$/) do |email|
  user = User.find_or_initialize_by(email: email)
  user.name = "User #{email}"
  user.role = :general
  user.facility_id = nil
  user.password = "ABCabc123!@#"
  user.save!
end

users = [
  ['super' , 'admin', 'SuperAdmin', "super_admin@blog.com"]
]

users.each do |first_name, last_name, username, email|
  user = User.find_or_initialize_by(email: email)
  user.first_name = first_name
  user.last_name = last_name
  user.username = username
  user.email = email
  user.password = "Test!**34"
  user.password_confirmation = "Test!**34"
  user.role = "super_admin"
  user.save
end

puts "=========== Completed user insert =============="
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

if Rails.env.development? && AdminUser.count == 0
  AdminUser.create!(email: 'admin@tickets.com', password: 'password', password_confirmation: 'password')
end

unless CsvFileStore.count != 0
  CsvFileStore.create(url: SUPPORT_TICKETS_CSV_PATH)
end
# db/seeds.rb
# Run with: rails db:seed

puts "Seeding database..."

# Create sample users
user1 = User.find_or_create_by!(email: "alice@example.com") do |u|
  u.username = "alice"
  u.password = "password123"
  u.password_confirmation = "password123"
end

user2 = User.find_or_create_by!(email: "bob@example.com") do |u|
  u.username = "bob"
  u.password = "password123"
  u.password_confirmation = "password123"
end

puts "Created users: alice, bob"

# Create sample videos
videos = [
  {
    youtube_url: "https://www.youtube.com/watch?v=dQw4w9WgXcQ",
    youtube_id: "dQw4w9WgXcQ",
    title: "Rick Astley - Never Gonna Give You Up",
    thumbnail_url: "https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg",
    description: "The classic.",
    shared_at: 2.days.ago
  },
  {
    youtube_url: "https://www.youtube.com/watch?v=9bZkp7q19f0",
    youtube_id: "9bZkp7q19f0",
    title: "PSY - GANGNAM STYLE",
    thumbnail_url: "https://img.youtube.com/vi/9bZkp7q19f0/hqdefault.jpg",
    description: "Oppan Gangnam Style!",
    shared_at: 1.day.ago
  }
]

videos.each_with_index do |attrs, i|
  owner = i.even? ? user1 : user2
  Video.find_or_create_by!(youtube_id: attrs[:youtube_id]) do |v|
    v.assign_attributes(attrs)
    v.user = owner
  end
end

puts "Created #{Video.count} sample videos"
puts "Seeding complete!"

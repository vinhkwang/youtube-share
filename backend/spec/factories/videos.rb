FactoryBot.define do
  factory :video do
    association :user
    sequence(:youtube_id) { |n| "dQw4w9WgXcQ#{n}" }
    youtube_url { "https://www.youtube.com/watch?v=#{youtube_id}" }
    title { "Test Video #{youtube_id}" }
    thumbnail_url { "https://img.youtube.com/vi/#{youtube_id}/hqdefault.jpg" }
    description { "A test video description" }
    shared_at { Time.current }
  end
end

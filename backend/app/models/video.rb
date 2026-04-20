class Video < ApplicationRecord
  belongs_to :user

  validates :youtube_id,  presence: true
  validates :youtube_url, presence: true
  validates :title,       presence: true
  validates :shared_at,   presence: true

  scope :newest_first, -> { order(shared_at: :desc) }

  before_create { self.shared_at ||= Time.current }

  def as_public_json
    {
      id:            id,
      youtube_id:    youtube_id,
      youtube_url:   youtube_url,
      title:         title,
      thumbnail_url: thumbnail_url,
      description:   description,
      shared_at:     shared_at,
      shared_by:     user.username,
      user: {
        id:       user.id,
        username: user.username
      }
    }
  end
end

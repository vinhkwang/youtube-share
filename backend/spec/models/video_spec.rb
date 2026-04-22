require 'rails_helper'

RSpec.describe Video, type: :model do
  describe "validations" do
    it { is_expected.to validate_presence_of(:youtube_id) }
    it { is_expected.to validate_presence_of(:youtube_url) }
    it { is_expected.to validate_presence_of(:title) }
  end

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "scopes" do
    it ".newest_first orders by shared_at descending" do
      user = create(:user)
      old_video = create(:video, user: user, shared_at: 2.days.ago)
      new_video = create(:video, user: user, shared_at: 1.hour.ago)

      expect(Video.newest_first).to eq([new_video, old_video])
    end
  end

  describe "#as_public_json" do
    it "includes shared_by username" do
      video = create(:video)
      json  = video.as_public_json
      expect(json[:shared_by]).to eq(video.user.username)
      expect(json[:title]).to eq(video.title)
      expect(json[:youtube_id]).to eq(video.youtube_id)
    end
  end
end

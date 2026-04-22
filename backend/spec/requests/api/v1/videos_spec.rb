require 'rails_helper'

RSpec.describe "Api::V1::Videos", type: :request do
  let!(:user) { create(:user) }
  let!(:videos) { create_list(:video, 3, user: user) }

  describe "GET /api/v1/videos" do
    it "returns paginated videos without auth" do
      get "/api/v1/videos"
      expect(response).to have_http_status(:ok)
      json = response.parsed_body
      expect(json["videos"].length).to eq(3)
      expect(json["meta"]["total_count"]).to eq(3)
      expect(json["meta"]["current_page"]).to eq(1)
    end

    it "returns videos in newest_first order" do
      get "/api/v1/videos"
      titles = response.parsed_body["videos"].map { |v| v["title"] }
      expected = videos.sort_by(&:shared_at).reverse.map(&:title)
      expect(titles).to eq(expected)
    end

    it "paginates results" do
      create_list(:video, 8, user: user)
      get "/api/v1/videos?page=2"
      json = response.parsed_body
      expect(json["videos"].length).to be <= 10
      expect(json["meta"]["current_page"]).to eq(2)
    end
  end

  describe "GET /api/v1/videos/:id" do
    it "returns the video" do
      video = videos.first
      get "/api/v1/videos/#{video.id}"
      expect(response).to have_http_status(:ok)
      expect(response.parsed_body["video"]["id"]).to eq(video.id)
    end

    it "returns 404 for missing video" do
      get "/api/v1/videos/999999"
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "POST /api/v1/videos" do
    let(:youtube_url) { "https://www.youtube.com/watch?v=dQw4w9WgXcQ" }

    before do
      allow(YoutubeMetadataFetcher).to receive(:fetch).and_return(
        { title: "Rick Astley - Never Gonna Give You Up", thumbnail_url: "https://img.youtube.com/vi/dQw4w9WgXcQ/hqdefault.jpg" }
      )
      allow(ActionCable.server).to receive(:broadcast)
    end

    it "requires authentication" do
      post "/api/v1/videos", params: { youtube_url: youtube_url }
      expect(response).to have_http_status(:unauthorized)
    end

    it "creates a video and broadcasts notification" do
      post "/api/v1/videos", params: { youtube_url: youtube_url }, headers: auth_headers(user)
      expect(response).to have_http_status(:created)
      json = response.parsed_body
      expect(json["video"]["youtube_id"]).to eq("dQw4w9WgXcQ")
      expect(json["video"]["title"]).to eq("Rick Astley - Never Gonna Give You Up")
      expect(ActionCable.server).to have_received(:broadcast).with("notifications", anything)
    end

    it "returns 400 for an invalid YouTube URL" do
      post "/api/v1/videos", params: { youtube_url: "https://vimeo.com/12345" }, headers: auth_headers(user)
      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body["error"]).to match(/Invalid YouTube URL/i)
    end
  end
end

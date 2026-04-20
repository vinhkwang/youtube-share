module YoutubeMetadataFetcher
  OEMBED_URL    = "https://www.youtube.com/oembed"
  THUMBNAIL_URL = "https://img.youtube.com/vi/%s/hqdefault.jpg"

  def self.fetch(video_id)
    watch_url = "https://www.youtube.com/watch?v=#{video_id}"
    response  = HTTParty.get(
      OEMBED_URL,
      query:   { url: watch_url, format: "json" },
      timeout: 5
    )

    if response.success?
      body = response.parsed_response
      {
        title:         body["title"].presence || "Untitled",
        thumbnail_url: body["thumbnail_url"].presence || fallback_thumbnail(video_id)
      }
    else
      { title: "Untitled", thumbnail_url: fallback_thumbnail(video_id) }
    end
  rescue HTTParty::Error, Net::OpenTimeout, Net::ReadTimeout, SocketError => e
    Rails.logger.warn("YoutubeMetadataFetcher error for #{video_id}: #{e.message}")
    { title: "Untitled", thumbnail_url: fallback_thumbnail(video_id) }
  end

  def self.fallback_thumbnail(video_id)
    format(THUMBNAIL_URL, video_id)
  end
  private_class_method :fallback_thumbnail
end

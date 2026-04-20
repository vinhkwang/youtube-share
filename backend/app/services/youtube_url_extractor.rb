module YoutubeUrlExtractor
  PATTERN = /(?:youtube\.com\/watch\?v=|youtu\.be\/|youtube\.com\/embed\/)([^&\n?#]+)/

  def self.extract(url)
    return nil if url.blank?
    match = url.to_s.match(PATTERN)
    match&.captures&.first
  end

  def self.valid?(url)
    extract(url).present?
  end
end

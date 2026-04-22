require 'rails_helper'

RSpec.describe YoutubeUrlExtractor do
  describe ".extract" do
    it "extracts ID from a watch URL" do
      id = described_class.extract("https://www.youtube.com/watch?v=dQw4w9WgXcQ")
      expect(id).to eq("dQw4w9WgXcQ")
    end

    it "extracts ID from a short URL" do
      id = described_class.extract("https://youtu.be/dQw4w9WgXcQ")
      expect(id).to eq("dQw4w9WgXcQ")
    end

    it "extracts ID from an embed URL" do
      id = described_class.extract("https://www.youtube.com/embed/dQw4w9WgXcQ")
      expect(id).to eq("dQw4w9WgXcQ")
    end

    it "extracts ID from a watch URL with extra params" do
      id = described_class.extract("https://www.youtube.com/watch?v=dQw4w9WgXcQ&t=42s&list=PL123")
      expect(id).to eq("dQw4w9WgXcQ")
    end

    it "returns nil for an invalid URL" do
      expect(described_class.extract("https://vimeo.com/123456")).to be_nil
    end

    it "returns nil for a blank string" do
      expect(described_class.extract("")).to be_nil
    end
  end

  describe ".valid?" do
    it "returns true for a valid YouTube URL" do
      expect(described_class.valid?("https://youtu.be/dQw4w9WgXcQ")).to be true
    end

    it "returns false for an invalid URL" do
      expect(described_class.valid?("https://example.com")).to be false
    end
  end
end

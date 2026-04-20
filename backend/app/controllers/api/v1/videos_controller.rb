module Api
  module V1
    class VideosController < ApplicationController
      before_action :authenticate_user!, only: [:create]

      PAGE_SIZE = 10

      def index
        page    = [params.fetch(:page, 1).to_i, 1].max
        offset  = (page - 1) * PAGE_SIZE

        videos = Video
                   .newest_first
                   .includes(:user)
                   .limit(PAGE_SIZE)
                   .offset(offset)

        total = Video.count

        render json: {
          videos: videos.map(&:as_public_json),
          meta: {
            current_page: page,
            per_page:     PAGE_SIZE,
            total_count:  total,
            total_pages:  (total.to_f / PAGE_SIZE).ceil
          }
        }, status: :ok
      end

      def show
        video = Video.includes(:user).find(params[:id])
        render json: { video: video.as_public_json }, status: :ok
      rescue ActiveRecord::RecordNotFound
        render_error("Video not found.", :not_found)
      end

      def create
        youtube_url = params[:youtube_url].to_s.strip

        video_id = YoutubeUrlExtractor.extract(youtube_url)
        unless video_id
          return render_error("Invalid YouTube URL. Supported formats: watch?v=, youtu.be/, embed/", :bad_request)
        end

        metadata = YoutubeMetadataFetcher.fetch(video_id)

        video = current_user.videos.build(
          youtube_id:    video_id,
          youtube_url:   youtube_url,
          title:         metadata[:title],
          thumbnail_url: metadata[:thumbnail_url],
          shared_at:     Time.current
        )

        if video.save
          broadcast_new_video(video)

          render json: { video: video.as_public_json }, status: :created
        else
          render_errors(video.errors.full_messages, :unprocessable_entity)
        end
      end

      private

      def broadcast_new_video(video)
        ActionCable.server.broadcast(
          "notifications",
          {
            type:      "new_video",
            message:   "#{video.user.username} shared: #{video.title}",
            video:     video.as_public_json,
            shared_by: video.user.username
          }
        )
      rescue => e
        Rails.logger.error("ActionCable broadcast failed: #{e.message}")
      end
    end
  end
end

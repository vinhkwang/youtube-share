class NotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "notifications"
    logger.info "NotificationsChannel: client subscribed (user=#{current_user&.username || 'guest'})"
  end

  def unsubscribed
    stop_all_streams
    logger.info "NotificationsChannel: client unsubscribed (user=#{current_user&.username || 'guest'})"
  end
end

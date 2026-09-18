# frozen_string_literal: true

# Turns away requests from banned users and banned IP addresses.
module BlockBannedRequests
  extend ActiveSupport::Concern

  included do
    before_action :block_if_banned
  end

  private

  def block_if_banned
    if banned_ip? || banned_user?
      render plain: "Access denied", status: :forbidden
    end
  end

  def banned_ip?
    Ban.active.by_ip(request.remote_ip).exists?
  end

  def banned_user?
    current_user&.banned?
  end
end

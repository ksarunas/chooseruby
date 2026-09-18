# frozen_string_literal: true

# Receives Content Security Policy violation reports from browsers.
class CspReportsController < ActionController::Base
  skip_before_action :verify_authenticity_token

  def create
    Rails.logger.warn("CSP VIOLATION: #{request.raw_post}")
    head :no_content
  end
end

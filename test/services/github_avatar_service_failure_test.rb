# frozen_string_literal: true

require "test_helper"

class GithubAvatarServiceFailureTest < ActiveSupport::TestCase
  class ExplodingGithubAvatarService < GithubAvatarService
    private

    def extract_username
      raise StandardError, "boom"
    end
  end

  test "returns nil and logs a warning when username extraction raises" do
    log_output = StringIO.new
    capture_logger = ActiveSupport::Logger.new(log_output)
    Rails.logger.broadcast_to(capture_logger)

    begin
      assert_nil ExplodingGithubAvatarService.call("https://github.com/matz")
    ensure
      Rails.logger.stop_broadcasting_to(capture_logger)
    end

    assert_includes log_output.string, "GitHub avatar fetch failed for https://github.com/matz: boom"
  end
end

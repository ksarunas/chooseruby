# frozen_string_literal: true

require "test_helper"

class CspReportsControllerTest < ActionDispatch::IntegrationTest
  test "POST create logs the violation and responds with no content" do
    report = { "csp-report" => { "blocked-uri" => "https://evil.example" } }.to_json
    log_output = StringIO.new
    capture_logger = ActiveSupport::Logger.new(log_output)
    Rails.logger.broadcast_to(capture_logger)

    begin
      post "/csp-violation-report", params: report, headers: { "CONTENT_TYPE" => "application/csp-report" }
    ensure
      Rails.logger.stop_broadcasting_to(capture_logger)
    end

    assert_response :no_content
    assert_includes log_output.string, "CSP VIOLATION: #{report}"
  end
end

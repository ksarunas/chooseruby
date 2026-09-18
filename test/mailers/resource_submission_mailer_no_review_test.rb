# frozen_string_literal: true

require "test_helper"

class ResourceSubmissionMailerNoReviewTest < ActionMailer::TestCase
  test "rejection_notification works when the entry has no rejection review" do
    entry = Entry.create!(
      title: "Unreviewed Tool",
      url: "https://example.com/unreviewed",
      description: "A tool",
      submitter_email: "developer@example.com",
      status: :rejected,
      entryable: Tool.create!(tool_type: "CLI")
    )

    email = ResourceSubmissionMailer.rejection_notification(entry)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ "developer@example.com" ], email.to
    assert_equal "Update on your ChooseRuby submission: Unreviewed Tool", email.subject
    assert_match "Unreviewed Tool", email.html_part.body.to_s
    assert_match "Unreviewed Tool", email.text_part.body.to_s
  end
end

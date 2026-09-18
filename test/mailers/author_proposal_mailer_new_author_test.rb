# frozen_string_literal: true

require "test_helper"

# Covers proposals that suggest a brand new author (no author_id yet)
class AuthorProposalMailerNewAuthorTest < ActionMailer::TestCase
  test "submission_confirmation works for a new author proposal" do
    proposal = AuthorProposal.create!(
      author_name: "Brand New Author",
      bio_text: "Writes about Ruby",
      submitter_email: "proposer@example.com"
    )

    email = AuthorProposalMailer.submission_confirmation(proposal)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ "proposer@example.com" ], email.to
    assert_equal "Author Proposal Received - ID ##{proposal.id}", email.subject
    assert_match "Brand New Author", email.html_part.body.to_s
    assert_match "Brand New Author", email.text_part.body.to_s
  end

  test "rejection_notification works for a new author proposal" do
    proposal = AuthorProposal.create!(
      author_name: "Brand New Author",
      bio_text: "Writes about Ruby",
      submitter_email: "proposer@example.com",
      status: :rejected,
      admin_comment: "We could not verify this author"
    )

    email = AuthorProposalMailer.rejection_notification(proposal)

    assert_emails 1 do
      email.deliver_now
    end

    assert_equal [ "proposer@example.com" ], email.to
    assert_equal "Author Proposal Feedback - ID ##{proposal.id}", email.subject
    assert_match "We could not verify this author", email.html_part.body.to_s
    assert_match "We could not verify this author", email.text_part.body.to_s
  end
end

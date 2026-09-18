# frozen_string_literal: true

require "test_helper"

class Avo::Actions::ApproveAuthorProposalErrorHandlingTest < ActiveSupport::TestCase
  test "approve action reports failures without aborting the batch" do
    author = Author.create!(name: "Matz", status: :approved)
    failing = AuthorProposal.create!(author: author, bio_text: "Bio one", submitter_email: "one@example.com")
    succeeding = AuthorProposal.create!(author: author, bio_text: "Bio two", submitter_email: "two@example.com")

    action = Avo::Actions::ApproveAuthorProposal.new(record: failing, resource: nil, user: nil, view: :index)

    failing.define_singleton_method(:approve!) { raise ActiveRecord::RecordInvalid.new(author) }
    action.handle(records: [ failing, succeeding ], fields: {}, current_user: nil, resource: nil)

    message = action.response[:messages].first
    assert_equal :error, message[:type]
    assert_match "1 approved, 1 failed: Proposal ##{failing.id}:", message[:body]
    assert_equal "approved", succeeding.reload.status
  end

  test "approve action is visible on the index view without a record" do
    action = Avo::Actions::ApproveAuthorProposal.new(record: nil, resource: nil, user: nil, view: :index)

    assert_predicate action, :visible?
  end

  test "approve action is hidden on the show view without a record" do
    action = Avo::Actions::ApproveAuthorProposal.new(record: nil, resource: nil, user: nil, view: :show)

    assert_not action.visible?
  end
end

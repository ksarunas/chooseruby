# frozen_string_literal: true

require "test_helper"

class Avo::Actions::RejectAuthorProposalErrorHandlingTest < ActiveSupport::TestCase
  test "reject action defines a required admin_comment textarea field" do
    action = Avo::Actions::RejectAuthorProposal.new(record: nil, resource: nil, user: nil, view: :index)
    action.fields

    field = action.get_field_definitions.find { |definition| definition.id == :admin_comment }
    assert_not_nil field
    assert field.required
  end

  test "reject action refuses to run without an admin comment" do
    author = Author.create!(name: "Matz", status: :approved)
    proposal = AuthorProposal.create!(author: author, bio_text: "Bio", submitter_email: "one@example.com")

    action = Avo::Actions::RejectAuthorProposal.new(record: proposal, resource: nil, user: nil, view: :index)
    action.handle(records: [ proposal ], fields: { admin_comment: "  " }, current_user: nil, resource: nil)

    message = action.response[:messages].first
    assert_equal :error, message[:type]
    assert_equal "Admin comment is required when rejecting proposals", message[:body]
    assert_equal "pending", proposal.reload.status
  end

  test "reject action reports failures without aborting the batch" do
    author = Author.create!(name: "Matz", status: :approved)
    failing = AuthorProposal.create!(author: author, bio_text: "Bio one", submitter_email: "one@example.com")
    succeeding = AuthorProposal.create!(author: author, bio_text: "Bio two", submitter_email: "two@example.com")

    action = Avo::Actions::RejectAuthorProposal.new(record: failing, resource: nil, user: nil, view: :index)

    failing.define_singleton_method(:reject!) { |**| raise ArgumentError, "boom" }
    action.handle(records: [ failing, succeeding ], fields: { admin_comment: "Not enough detail" }, current_user: nil, resource: nil)

    message = action.response[:messages].first
    assert_equal :error, message[:type]
    assert_equal "1 rejected, 1 failed: Proposal ##{failing.id}: boom", message[:body]
    assert_equal "rejected", succeeding.reload.status
  end

  test "reject action is visible on the index view without a record" do
    action = Avo::Actions::RejectAuthorProposal.new(record: nil, resource: nil, user: nil, view: :index)

    assert action.visible?
  end

  test "reject action is hidden on the show view without a record" do
    action = Avo::Actions::RejectAuthorProposal.new(record: nil, resource: nil, user: nil, view: :show)

    assert_not action.visible?
  end
end

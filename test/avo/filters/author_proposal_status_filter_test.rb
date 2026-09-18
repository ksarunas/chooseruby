# frozen_string_literal: true

require "test_helper"

class Avo::Filters::AuthorProposalStatusFilterTest < ActiveSupport::TestCase
  setup { @filter = Avo::Filters::AuthorProposalStatusFilter.new }

  test "filters proposals by status regardless of case" do
    assert_equal [ author_proposals(:pending_comprehensive).id ],
      @filter.apply(nil, AuthorProposal.where(submitter_email: %w[comprehensive@example.com approved@example.com]), "Pending").ids
    assert_equal [ author_proposals(:approved_with_author).id ],
      @filter.apply(nil, AuthorProposal.where(submitter_email: %w[comprehensive@example.com approved@example.com]), "approved").ids
    assert_equal [ author_proposals(:rejected_with_feedback).id ],
      @filter.apply(nil, AuthorProposal.where(submitter_email: %w[comprehensive@example.com rejected@example.com]), "rejected").ids
  end

  test "returns the query untouched for unknown values" do
    query = AuthorProposal.all

    assert_same query, @filter.apply(nil, query, nil)
    assert_same query, @filter.apply(nil, query, "archived")
  end

  test "offers the three statuses and defaults to pending" do
    assert_equal({ "Pending" => "pending", "Approved" => "approved", "Rejected" => "rejected" }, @filter.options)
    assert_equal "pending", @filter.default
  end
end

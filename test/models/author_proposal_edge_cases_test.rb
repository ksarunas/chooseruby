# frozen_string_literal: true

require "test_helper"

class AuthorProposalEdgeCasesTest < ActiveSupport::TestCase
  setup do
    @author = Author.create!(name: "Edge Case Author", slug: "edge-case-author")
  end

  test "reject! raises when admin_comment is blank" do
    proposal = AuthorProposal.create!(author: @author, bio_text: "Bio", submitter_email: "test@example.com")

    error = assert_raises(ArgumentError) { proposal.reject!(admin_comment: "  ") }

    assert_equal "admin_comment is required for rejection", error.message
    assert proposal.reload.pending?
  end

  test "validation rejects unknown link fields and skips blank urls" do
    proposal = AuthorProposal.new(
      author: @author,
      link_updates: { "bogus_url" => "https://example.com", "twitter_url" => "" },
      submitter_email: "test@example.com"
    )

    assert_not proposal.valid?
    assert_equal [ "bogus_url is not a valid link field" ], proposal.errors[:link_updates]
  end

  test "approve! skips blank link values" do
    @author.update!(twitter_url: "https://twitter.com/existing")
    proposal = AuthorProposal.create!(
      author: @author,
      link_updates: { "github_url" => "https://github.com/edge", "twitter_url" => "" },
      submitter_email: "test@example.com"
    )

    proposal.approve!

    @author.reload
    assert_equal "https://github.com/edge", @author.github_url
    assert_equal "https://twitter.com/existing", @author.twitter_url
  end

  test "approve! raises when link_updates contain a field the author does not have" do
    proposal = AuthorProposal.create!(
      author: @author,
      link_updates: { "github_url" => "https://github.com/edge" },
      submitter_email: "test@example.com"
    )
    proposal.link_updates = { "not_a_field" => "https://example.com" }

    error = assert_raises(ArgumentError) { proposal.approve! }

    assert_equal "Invalid link field: not_a_field", error.message
    assert proposal.reload.pending?
  end

  test "approve! does not duplicate an existing entry association" do
    entry = Entry.create!(title: "Matched", url: "https://example.com/matched", status: :approved, published: true)
    EntriesAuthor.create!(author: @author, entry: entry)
    proposal = AuthorProposal.create!(
      author: @author,
      resource_url: "https://www.example.com/matched/",
      submitter_email: "test@example.com"
    )
    assert_equal entry.id, proposal.matched_entry_id

    assert_no_difference -> { EntriesAuthor.count } do
      proposal.approve!
    end
    assert proposal.reload.approved?
  end
end

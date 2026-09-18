# frozen_string_literal: true

require "test_helper"
require "ostruct"
require "avo/support/admin_session"

class Avo::AuthorProposalsControllerTest < ActionDispatch::IntegrationTest
  include AvoAdminSession

  setup { sign_in_as_admin }

  test "index lists proposals" do
    proposal = author_proposals(:pending_comprehensive)

    get "/avo/resources/author_proposals"

    assert_response :success
    assert_includes response.body, proposal.submitter_email
  end

  test "search query matches proposals by submitter email" do
    context = OpenStruct.new(params: { q: "comprehensive@" }, query: AuthorProposal.all)

    results = context.instance_exec(&Avo::Resources::AuthorProposal.search[:query])

    assert_equal [ author_proposals(:pending_comprehensive) ], results.to_a
  end

  test "show summarizes a proposal that only updates links" do
    author = Author.create!(name: "Linked Author", status: :approved)
    proposal = AuthorProposal.create!(author: author, submitter_email: "editor@example.com", link_updates: { "website_url" => "https://example.com" })

    get "/avo/resources/author_proposals/#{proposal.id}"

    assert_response :success
    assert_includes response.body, "Link Updates:"
    assert_not_includes response.body, "Bio:"
  end

  test "new and edit are not authorized" do
    get "/avo/resources/author_proposals/new"
    assert_response :redirect

    get "/avo/resources/author_proposals/#{author_proposals(:pending_comprehensive).id}/edit"
    assert_response :redirect
  end

  test "create, update and destroy are not authorized" do
    proposal = author_proposals(:pending_comprehensive)

    assert_no_difference -> { AuthorProposal.count } do
      post "/avo/resources/author_proposals", params: { author_proposal: { submitter_email: "new@example.com" } }
      assert_response :redirect

      patch "/avo/resources/author_proposals/#{proposal.id}", params: { author_proposal: { submitter_email: "changed@example.com" } }
      assert_response :redirect

      delete "/avo/resources/author_proposals/#{proposal.id}"
      assert_response :redirect
    end
    assert_equal "comprehensive@example.com", proposal.reload.submitter_email
  end

  test "show summarizes a new author proposal with unmatched resource, links, bio and description" do
    proposal = author_proposals(:pending_comprehensive)

    get "/avo/resources/author_proposals/#{proposal.id}"

    assert_response :success
    assert_select "[data-field-id='author_name']"
    assert_includes response.body, "New Author"
    assert_includes response.body, "Creating new author:"
    assert_includes response.body, "Resource: Unmatched URL - http://example.com/resource"
    assert_includes response.body, "github_url: (blank) → https://github.com/testuser"
    assert_includes response.body, "Current: (blank)"
    assert_includes response.body, "Proposed: Updated bio text for comprehensive testing"
    assert_includes response.body, "Proposed: Updated description text"
  end

  test "show summarizes an existing author proposal with matched entry and current values" do
    author = Author.create!(name: "Existing Author", status: :approved, bio: "Existing bio", github_url: "https://github.com/existing")
    entry = Entry.create!(
      title: "Matched Entry",
      description: "Entry description",
      url: "https://example.com/matched",
      entryable: Blog.create!(name: "Matched Blog"),
      status: :approved
    )
    proposal = AuthorProposal.create!(
      author: author,
      submitter_email: "editor@example.com",
      resource_url: "https://example.com/matched",
      matched_entry: entry,
      link_updates: { "github_url" => "https://github.com/renamed", "website_url" => "https://example.com" },
      bio_text: "A fresh bio"
    )

    get "/avo/resources/author_proposals/#{proposal.id}"

    assert_response :success
    assert_select "[data-field-id='author_name']", count: 0
    assert_includes response.body, "Edit Existing Author"
    assert_includes response.body, "Editing author: Existing Author"
    assert_includes response.body, "Resource: Matched entry ##{entry.id} - Matched Entry"
    assert_includes response.body, "github_url: https://github.com/existing → https://github.com/renamed"
    assert_includes response.body, "website_url: (blank) → https://example.com"
    assert_includes response.body, "Current: Existing bio"
  end

  test "show reports a blank current bio for an author without one" do
    author = Author.create!(name: "Quiet Author", status: :approved)
    proposal = AuthorProposal.create!(author: author, submitter_email: "editor@example.com", bio_text: "First bio")

    get "/avo/resources/author_proposals/#{proposal.id}"

    assert_response :success
    assert_includes response.body, "Current: (blank)"
    assert_includes response.body, "Proposed: First bio"
  end
end

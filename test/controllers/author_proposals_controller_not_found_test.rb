# frozen_string_literal: true

require "test_helper"

class AuthorProposalsControllerNotFoundTest < ActionDispatch::IntegrationTest
  test "GET new returns 404 for an unknown author" do
    get propose_author_edit_path(author_id: 999_999)

    assert_response :not_found
  end

  test "GET new returns 404 for an author that is not approved" do
    author = Author.create!(name: "Pending Author", status: :pending)

    get propose_author_edit_path(author_id: author.id)

    assert_response :not_found
  end

  test "GET success returns 404 for an unknown proposal" do
    get author_proposal_success_path(id: 999_999)

    assert_response :not_found
  end

  test "POST create re-renders the new author form when a new author proposal is invalid" do
    assert_no_difference "AuthorProposal.count" do
      post author_proposals_path, params: {
        author_proposal: {
          author_name: "Brand New Author",
          submitter_name: "Jane"
          # Missing submitter_email (required)
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select "input[name=?]", "author_proposal[author_name]"
  end
end

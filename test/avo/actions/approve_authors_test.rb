# frozen_string_literal: true

require "test_helper"

class Avo::Actions::ApproveAuthorsTest < ActiveSupport::TestCase
  test "approve action marks every selected author as approved" do
    first = Author.create!(name: "Pending One", status: :pending)
    second = Author.create!(name: "Pending Two", status: :pending)

    action = Avo::Actions::ApproveAuthors.new(record: first, resource: nil, user: nil, view: :index)
    action.handle(records: [ first, second ], fields: {}, current_user: nil, resource: nil)

    assert_equal "approved", first.reload.status
    assert_equal "approved", second.reload.status
    assert_equal "2 authors approved successfully!", action.response[:messages].first[:body]
  end
end

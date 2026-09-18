# frozen_string_literal: true

require "test_helper"

class Avo::Actions::UnpublishEntriesTest < ActiveSupport::TestCase
  test "unpublish action sets published to false on selected entries" do
    entry = Entry.create!(title: "Live Entry", url: "https://example.com/live", status: :approved, published: true)

    action = Avo::Actions::UnpublishEntries.new(record: entry, resource: nil, user: nil, view: :index)
    action.handle(records: [ entry ], fields: {}, current_user: nil, resource: nil)

    assert_not entry.reload.published
    assert_equal "1 resource unpublished successfully!", action.response[:messages].first[:body]
  end
end

# frozen_string_literal: true

require "test_helper"

class Avo::Actions::PublishEntriesTest < ActiveSupport::TestCase
  test "publish action sets published to true on selected entries" do
    entry = Entry.create!(title: "Hidden Entry", url: "https://example.com/hidden", status: :approved, published: false)

    action = Avo::Actions::PublishEntries.new(record: entry, resource: nil, user: nil, view: :index)
    action.handle(records: [ entry ], fields: {}, current_user: nil, resource: nil)

    assert entry.reload.published
    assert_equal "1 resource published successfully!", action.response[:messages].first[:body]
  end
end

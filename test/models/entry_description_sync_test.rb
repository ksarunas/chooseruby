# frozen_string_literal: true

require "test_helper"

class EntryDescriptionSyncTest < ActiveSupport::TestCase
  test "updating an unrelated field on an entry without a description does not resync FTS" do
    entry = Entry.create!(title: "No Description", url: "https://example.com/no-description", status: :approved)
    entry.reload
    assert_nil entry.rich_text_description

    # Plant a sentinel in the FTS row: a resync would overwrite it with the real title
    ActiveRecord::Base.connection.execute(
      "UPDATE entries_fts SET title = 'SENTINEL' WHERE entry_id = #{entry.id}"
    )

    entry.update!(experience_level: :advanced)

    fts_title = ActiveRecord::Base.connection.select_value("SELECT title FROM entries_fts WHERE entry_id = #{entry.id}")
    assert_equal "SENTINEL", fts_title
  end
end

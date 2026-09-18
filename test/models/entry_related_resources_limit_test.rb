# frozen_string_literal: true

require "test_helper"

class EntryRelatedResourcesLimitTest < ActiveSupport::TestCase
  setup do
    @category1 = categories(:testing)
    @category2 = categories(:authentication)
    @category3 = categories(:background_jobs)

    @main_entry = Entry.create!(title: "Main", url: "https://example.com/main", published: true, status: :approved)
    @main_entry.categories << [ @category1, @category2, @category3 ]

    @by_category = { @category1 => [], @category2 => [], @category3 => [] }
    @by_category.each do |category, entries|
      2.times do |i|
        entry = Entry.create!(
          title: "#{category.name} #{i}",
          url: "https://example.com/#{category.slug}-#{i}",
          published: true,
          status: :approved
        )
        entry.categories << category
        entries << entry
      end
    end
  end

  test "stops collecting once the limit is filled before reaching the last category" do
    related = @main_entry.related_resources(limit: 4)

    assert_equal 4, related.length
    assert_empty related & @by_category[@category3], "Third category should not be consulted once the limit is met"
  end
end

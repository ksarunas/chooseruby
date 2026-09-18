# frozen_string_literal: true

require "test_helper"

class Avo::Filters::EntryFiltersTest < ActiveSupport::TestCase
  setup do
    @approved = create_entry(title: "Approved", status: :approved, published: true,
      experience_level: :beginner, tags: [ "ruby", "rails" ], entryable: Blog.create!(name: "Blog"))
    @pending = create_entry(title: "Pending", status: :pending, published: false,
      experience_level: :advanced, submitter_email: "pending@example.com", entryable: Video.create!(name: "Video"))
    @rejected = create_entry(title: "Rejected", status: :rejected, published: false,
      submitter_email: "rejected@example.com", entryable: Video.create!(name: "Video"))
  end

  test "status filter narrows by status regardless of case" do
    filter = Avo::Filters::EntryStatusFilter.new

    assert_equal [ @pending ], filter.apply(nil, Entry.all, "Pending").to_a
    assert_equal [ @approved ], filter.apply(nil, Entry.all, "approved").to_a
    assert_equal [ @rejected ], filter.apply(nil, Entry.all, "rejected").to_a
    query = Entry.all
    assert_same query, filter.apply(nil, query, "draft")
    assert_equal({ "Pending" => "pending", "Approved" => "approved", "Rejected" => "rejected" }, filter.options)
  end

  test "published filter honours boolean hashes and string values" do
    filter = Avo::Filters::EntryPublishedFilter.new

    assert_equal [ @approved ], filter.apply(nil, Entry.all, { "true" => true }).to_a
    assert_equal [ @pending, @rejected ], filter.apply(nil, Entry.all, { false => true }).order(:id).to_a
    assert_equal 3, filter.apply(nil, Entry.all, { "true" => true, "false" => true }).count
    assert_equal [ @approved ], filter.apply(nil, Entry.all, "true").to_a
    assert_equal [ @pending, @rejected ], filter.apply(nil, Entry.all, "false").order(:id).to_a

    query = Entry.all
    assert_same query, filter.apply(nil, query, nil)
    assert_equal({ "true" => "Published", "false" => "Unpublished" }, filter.options)
  end

  test "experience level filter narrows by level" do
    filter = Avo::Filters::EntryExperienceLevelFilter.new

    assert_equal [ @pending ], filter.apply(nil, Entry.all, "advanced").to_a
    query = Entry.all
    assert_same query, filter.apply(nil, query, "")
    assert_equal %w[all_levels beginner intermediate advanced], filter.options.values
  end

  test "type filter narrows by entryable type" do
    filter = Avo::Filters::EntryTypeFilter.new

    assert_equal [ @approved ], filter.apply(nil, Entry.all, "Blog").to_a
    query = Entry.all
    assert_same query, filter.apply(nil, query, nil)
    assert_equal 19, filter.options.size
    assert_equal "DevelopmentEnvironment", filter.options["Development Environment"]
  end

  test "category filter narrows by category id" do
    filter = Avo::Filters::EntryCategoryFilter.new
    category = categories(:testing)
    @approved.categories << category

    assert_equal [ @approved ], filter.apply(nil, Entry.all, category.id).to_a
    query = Entry.all
    assert_same query, filter.apply(nil, query, nil)
    assert_equal category.id, filter.options["Testing"]
  end

  test "tags filter narrows by tag and lists titleized tags" do
    filter = Avo::Filters::EntryTagsFilter.new

    assert_equal [ @approved ], filter.apply(nil, Entry.all, "rails").to_a
    query = Entry.all
    assert_same query, filter.apply(nil, query, "")
    assert_equal({ "Rails" => "rails", "Ruby" => "ruby" }, filter.options)
  end

  private

  def create_entry(**attributes)
    Entry.create!(description: "Entry description", url: "https://example.com/#{SecureRandom.hex(4)}", **attributes)
  end
end

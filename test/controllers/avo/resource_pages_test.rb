# frozen_string_literal: true

require "test_helper"
require "avo/support/admin_session"

# Renders the index/new/show/edit pages of every Avo resource so that each
# resource's field, filter and action definitions are exercised end to end.
class Avo::ResourcePagesTest < ActionDispatch::IntegrationTest
  include AvoAdminSession

  NAME_ONLY_RESOURCES = %w[
    blogs channels development_environments directories documentations
    frameworks job_boards newsletters products testing_resources videos
  ].freeze

  RECORD_BUILDERS = {
    "articles" => -> { Article.create!(platform: "Dev.to") },
    "authors" => -> { Author.create!(name: "Avo Author", status: :approved) },
    "books" => -> { Book.create!(publication_year: 2024) },
    "categories" => -> { categories(:testing) },
    "categories_entries" => -> { CategoriesEntry.create!(category: categories(:testing), entry: create_entry) },
    "communities" => -> { Community.create!(platform: "Discord", join_url: "https://example.com/join") },
    "courses" => -> { Course.create! },
    "entries" => -> { create_entry },
    "entry_reviews" => -> { EntryReview.create!(entry: create_entry, status: :approved) },
    "podcasts" => -> { Podcast.create! },
    "ruby_gems" => -> { RubyGem.create!(gem_name: "avo-pages-gem") },
    "tools" => -> { Tool.create! },
    "tutorials" => -> { Tutorial.create! },
    "users" => -> { users(:admin) }
  }.merge(NAME_ONLY_RESOURCES.to_h { |name| [ name, -> { name.classify.constantize.create!(name: "Avo #{name}") } ] }).freeze

  setup { sign_in_as_admin }

  RECORD_BUILDERS.each do |resource_name, builder|
    test "#{resource_name} index, new, show and edit pages render" do
      record = instance_exec(&builder)

      get "/avo/resources/#{resource_name}"
      assert_response :success

      get "/avo/resources/#{resource_name}/new"
      assert_response :success

      get "/avo/resources/#{resource_name}/#{record.id}"
      assert_response :success

      get "/avo/resources/#{resource_name}/#{record.id}/edit"
      assert_response :success
    end
  end

  NAME_ONLY_RESOURCES.each do |resource_name|
    test "#{resource_name} can be created with a name" do
      model = resource_name.classify.constantize

      assert_difference -> { model.count }, 1 do
        post "/avo/resources/#{resource_name}", params: { resource_name.singularize => { name: "Created #{resource_name}" } }
      end
      assert_response :redirect
    end
  end

  test "entry association frames render categories, authors and reviews" do
    entry = create_entry(tags: [ "ruby" ])
    EntryReview.create!(entry: entry, status: :approved)

    %w[categories authors entry_reviews].each do |association|
      get "/avo/resources/entries/#{entry.id}/#{association}", params: { view: :show, turbo_frame: "has_many_field_show_#{association}" }
      assert_response :success
    end
  end

  test "author and category association frames render" do
    author = Author.create!(name: "Avo Author", status: :approved)
    get "/avo/resources/authors/#{author.id}/entries", params: { view: :show, turbo_frame: "has_many_field_show_entries" }
    assert_response :success

    get "/avo/resources/categories/#{categories(:testing).id}/entries", params: { view: :show, turbo_frame: "has_many_field_show_entries" }
    assert_response :success
  end

  test "entries index applies encoded filters" do
    published = create_entry(title: "Published Entry", published: true)
    unpublished = create_entry(title: "Unpublished Entry", published: false)

    filters = Avo::Filters::BaseFilter.encode_filters(
      "Avo::Filters::EntryPublishedFilter" => { "true" => true },
      "Avo::Filters::EntryTypeFilter" => "Blog"
    )
    get "/avo/resources/entries", params: { encoded_filters: filters }

    assert_response :success
    assert_includes response.body, published.title
    assert_not_includes response.body, unpublished.title
  end

  private

  def create_entry(title: "Avo Entry", **attributes)
    Entry.create!(
      title: title,
      description: "Entry description",
      url: "https://example.com/#{SecureRandom.hex(4)}",
      entryable: Blog.create!(name: "Entry Blog"),
      status: :approved,
      **attributes
    )
  end
end

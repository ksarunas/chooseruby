# frozen_string_literal: true

require "test_helper"
require_relative "../../../support/singleton_stubs"

module Imports
  module Rubyandrailsinfo
    class YamlImporterTest < ActiveSupport::TestCase
      include SingletonStubs

      YAML_FILES = %w[
        tags authors books courses newsletters podcasts communities youtubes screencasts lessons authorings taggings
      ].freeze

      TIMESTAMPS = { "created_at" => "2022-06-19 09:25:40", "updated_at" => "2022-08-15 14:48:44" }.freeze

      setup { @dir = Dir.mktmpdir }
      teardown { FileUtils.remove_entry(@dir) }

      # Categories

      test "imports categories idempotently by slug" do
        tags = [ { "id" => "1", "title" => "Imported Testing", "slug" => "imported-testing" }.merge(TIMESTAMPS) ]

        output = run_import("tags" => tags)
        run_import("tags" => tags)

        category = Category.find_by!(slug: "imported-testing")
        assert_equal "Imported Testing", category.name
        assert_equal Time.parse(TIMESTAMPS["created_at"]), category.created_at
        assert_equal 1, Category.where(slug: "imported-testing").count
        assert_includes output, "✓ Imported 1 categories (0 errors)"
      end

      test "reports categories that fail validation" do
        output = run_import("tags" => [ { "id" => "1", "title" => "X", "slug" => "x-tag" } ])

        assert_includes output, "✗ Error importing category 1"
        assert_includes output, "✓ Imported 0 categories (1 errors)"
        assert_includes output, "Categories: 0 success\n  Errors: 1"
      end

      # Authors

      test "imports approved authors with their urls" do
        author_yaml = {
          "id" => "1", "name" => "Imported Author", "slug" => "imported-author",
          "twitter_url" => "https://twitter.com/imported", "github_url" => "https://github.com/imported",
          "website_url" => "https://imported.example"
        }.merge(TIMESTAMPS)

        output = run_import("authors" => [ author_yaml ])

        author = Author.find_by!(slug: "imported-author")
        assert author.approved?
        assert_equal "https://twitter.com/imported", author.twitter_url
        assert_equal "https://github.com/imported", author.github_url
        assert_equal "https://imported.example", author.website_url
        assert_equal Time.parse(TIMESTAMPS["updated_at"]), author.updated_at
        assert_includes output, "✓ Imported 1 authors (0 errors)"
      end

      test "reports authors that fail validation" do
        output = run_import("authors" => [ { "id" => "1", "name" => "X", "slug" => "x-author" } ])

        assert_includes output, "✗ Error importing author 1"
        assert_includes output, "✓ Imported 0 authors (1 errors)"
      end

      # Books

      test "imports books by isbn with entry, purchase url and featured timestamp" do
        book_yaml = {
          "id" => "1", "isbn" => "9781680502503", "year" => "2020", "page" => "300",
          "amazon_url" => "https://amazon.com/imported-book", "website_url" => "https://book.example",
          "featured" => "t",
          "entry" => { "title" => "Imported Book", "content" => "About it", "slug" => "imported-book",
                       "website_url" => "https://book.example" }
        }.merge(TIMESTAMPS)

        output = run_import("books" => [ book_yaml ])

        book = Book.find_by!(isbn: "9781680502503")
        assert_equal 2020, book.publication_year
        assert_equal 300, book.page_count
        assert_equal "https://amazon.com/imported-book", book.purchase_url
        assert book.both?
        entry = book.entry
        assert_equal "Imported Book", entry.title
        assert_equal "About it", entry.description.to_plain_text
        assert_equal "https://book.example", entry.url
        assert entry.approved?
        assert entry.published?
        assert entry.intermediate?
        assert_equal Time.parse(TIMESTAMPS["created_at"]), entry.featured_at
        assert_includes output, "✓ Imported 1 books (0 errors, 0 skipped)"
      end

      test "books without isbn are created once and reused through their entry slug" do
        book_yaml = {
          "id" => "2", "isbn" => "", "featured" => "f",
          "entry" => { "title" => "Second Book", "slug" => "second-book" }
        }

        run_import("books" => [ book_yaml ])
        run_import("books" => [ book_yaml ])

        entries = Entry.where(slug: "second-book", entryable_type: "Book")
        assert_equal 1, entries.count
        entry = entries.first
        assert_nil entry.featured_at
        assert_equal "https://example.com/second-book", entry.url
        assert_nil entry.entryable.publication_year
        assert_nil entry.entryable.page_count
      end

      test "skips books without an entry title and reports invalid books" do
        books = [
          { "id" => "3" },
          { "id" => "4", "entry" => { "title" => "" } },
          { "id" => "5", "isbn" => "9781680502503", "year" => "1000", "entry" => { "title" => "Ancient Book", "slug" => "ancient-book" } }
        ]

        output = run_import("books" => books)

        assert_includes output, "✗ Error importing book 5"
        assert_includes output, "✓ Imported 0 books (1 errors, 2 skipped)"
        assert_includes output, "Books: 0 success\n  Errors: 1\n  Skipped: 2"
      end

      # Courses

      test "imports courses with their free flag" do
        course_yaml = { "id" => "1", "free" => "true",
                        "entry" => { "title" => "Imported Course", "slug" => "imported-course", "website_url" => "https://course.example" } }

        output = run_import("courses" => [ course_yaml, { "id" => "2" }, { "id" => "3", "entry" => { "title" => "X" } } ])

        entry = Entry.find_by!(slug: "imported-course")
        assert entry.entryable.is_free
        assert_equal "https://course.example", entry.url
        assert_includes output, "✗ Error importing course 3"
        assert_includes output, "✓ Imported 1 courses (1 errors, 1 skipped)"
      end

      # Newsletters

      test "imports newsletters named after their entry" do
        newsletter_yaml = { "id" => "1", "entry" => { "title" => "Imported Newsletter", "slug" => "imported-newsletter" } }

        output = run_import("newsletters" => [ newsletter_yaml, { "id" => "2" }, { "id" => "3", "entry" => { "title" => "X" } } ])

        entry = Entry.find_by!(slug: "imported-newsletter")
        assert_equal "Imported Newsletter", entry.entryable.name
        assert_includes output, "✗ Error importing newsletter 3"
        assert_includes output, "✓ Imported 1 newsletters (1 errors, 1 skipped)"
      end

      # Podcasts

      test "imports podcasts" do
        podcast_yaml = { "id" => "1", "entry" => { "title" => "Imported Podcast", "slug" => "imported-podcast" } }.merge(TIMESTAMPS)

        output = run_import("podcasts" => [ podcast_yaml, { "id" => "2" }, { "id" => "3", "entry" => { "title" => "X" } } ])

        entry = Entry.find_by!(slug: "imported-podcast")
        assert_kind_of Podcast, entry.entryable
        assert_equal Time.parse(TIMESTAMPS["created_at"]), entry.entryable.created_at
        assert_includes output, "✗ Error importing podcast 3"
        assert_includes output, "✓ Imported 1 podcasts (1 errors, 1 skipped)"
      end

      # Communities

      test "imports communities using the website url or a placeholder as join url" do
        communities = [
          { "id" => "1", "entry" => { "title" => "Linked Community", "slug" => "linked-community", "website_url" => "https://community.example" } },
          { "id" => "2", "entry" => { "title" => "Unlinked Community", "slug" => "unlinked-community" } },
          { "id" => "3" },
          { "id" => "4", "entry" => { "title" => "X" } }
        ]

        output = run_import("communities" => communities)

        linked = Entry.find_by!(slug: "linked-community").entryable
        unlinked = Entry.find_by!(slug: "unlinked-community").entryable
        assert_equal "https://community.example", linked.join_url
        assert_equal "https://example.com/unlinked-community", unlinked.join_url
        assert_equal "Other", linked.platform
        assert_not linked.is_official
        assert_includes output, "✗ Error importing community 4"
        assert_includes output, "✓ Imported 2 communities (1 errors, 1 skipped)"
      end

      # Youtubes and screencasts

      test "imports youtubes as videos" do
        youtube_yaml = { "id" => "1", "entry" => { "title" => "Imported Channel", "slug" => "imported-channel" } }

        output = run_import("youtubes" => [ youtube_yaml, { "id" => "2" }, { "id" => "3", "entry" => { "title" => "X" } } ])

        entry = Entry.find_by!(slug: "imported-channel")
        assert_kind_of Video, entry.entryable
        assert_equal "Imported Channel", entry.entryable.name
        assert_includes output, "✗ Error importing youtube 3"
        assert_includes output, "✓ Imported 1 youtubes (1 errors, 1 skipped)"
      end

      test "imports screencasts as videos" do
        screencast_yaml = { "id" => "1", "entry" => { "title" => "Imported Screencast", "slug" => "imported-screencast" } }

        output = run_import("screencasts" => [ screencast_yaml, { "id" => "2" }, { "id" => "3", "entry" => { "title" => "X" } } ])

        entry = Entry.find_by!(slug: "imported-screencast")
        assert_kind_of Video, entry.entryable
        assert_includes output, "✗ Error importing screencast 3"
        assert_includes output, "✓ Imported 1 screencasts (1 errors, 1 skipped)"
      end

      # Lessons

      test "imports lessons resolving youtube ids, full urls and website urls" do
        lessons = [
          { "id" => "1", "entry" => { "title" => "Lesson One", "slug" => "lesson-one", "url" => "MwbmKqdDsyI" } },
          { "id" => "2", "entry" => { "title" => "Lesson Two", "slug" => "lesson-two", "url" => "https://vimeo.com/2" } },
          { "id" => "3", "entry" => { "title" => "Lesson Three", "slug" => "lesson-three", "website_url" => "https://lesson.example/3" } },
          { "id" => "4" },
          { "id" => "5", "entry" => { "title" => "X" } }
        ]

        output = run_import("lessons" => lessons)

        assert_equal "https://www.youtube.com/watch?v=MwbmKqdDsyI", Entry.find_by!(slug: "lesson-one").url
        assert_equal "https://vimeo.com/2", Entry.find_by!(slug: "lesson-two").url
        assert_equal "https://lesson.example/3", Entry.find_by!(slug: "lesson-three").url
        assert Entry.find_by!(slug: "lesson-one").all_levels?
        assert_includes output, "✗ Error importing lesson 5"
        assert_includes output, "✓ Imported 3 lessons (1 errors, 1 skipped)"
      end

      # Authorings

      test "links imported authors to imported entries and skips unknown references" do
        authorings = [
          { "id" => "1", "author_id" => "1", "authorabble_type" => "Podcast", "authorabble_id" => "1" },
          { "id" => "2", "author_id" => "99", "authorabble_type" => "Podcast", "authorabble_id" => "1" },
          { "id" => "3", "author_id" => "1", "authorabble_type" => "Podcast", "authorabble_id" => "99" }
        ]

        output = run_import("authors" => [ author_fixture ], "podcasts" => [ podcast_fixture ], "authorings" => authorings)

        entry = Entry.find_by!(slug: "imported-podcast")
        assert_equal [ "Imported Author" ], entry.authors.map(&:name)
        assert_includes output, "✓ Imported 1 authorings (0 errors, 2 skipped)"
        assert_includes output, "ID Mappings: {categories: 0, authors: 1, entries: 1}"
      end

      test "reports authorings that fail to persist" do
        authorings = [ { "id" => "1", "author_id" => "1", "authorabble_type" => "Podcast", "authorabble_id" => "1" } ]
        failing = ->(*) { raise ActiveRecord::ActiveRecordError, "boom" }

        output = stub_singleton(EntriesAuthor, :find_or_create_by!, failing) do
          run_import("authors" => [ author_fixture ], "podcasts" => [ podcast_fixture ], "authorings" => authorings)
        end

        assert_includes output, "✗ Error importing authoring: boom"
        assert_includes output, "✓ Imported 0 authorings (1 errors, 0 skipped)"
      end

      # Taggings

      test "categorises imported entries marking the first category as primary" do
        tags = [
          { "id" => "1", "title" => "Imported Primary", "slug" => "imported-primary" },
          { "id" => "2", "title" => "Imported Secondary", "slug" => "imported-secondary" }
        ]
        taggings = [
          { "id" => "1", "tag_id" => "1", "taggable_type" => "Podcast", "taggable_id" => "1" },
          { "id" => "2", "tag_id" => "2", "taggable_type" => "Podcast", "taggable_id" => "1" },
          { "id" => "3", "tag_id" => "99", "taggable_type" => "Podcast", "taggable_id" => "1" },
          { "id" => "4", "tag_id" => "1", "taggable_type" => "Podcast", "taggable_id" => "99" }
        ]

        output = run_import("tags" => tags, "podcasts" => [ podcast_fixture ], "taggings" => taggings)

        entry = Entry.find_by!(slug: "imported-podcast")
        primary = entry.categories_entries.find_by!(is_primary: true)
        assert_equal "imported-primary", primary.category.slug
        assert_equal [ "imported-secondary" ], entry.categories_entries.where(is_primary: false).map { |ce| ce.category.slug }
        assert_includes output, "✓ Imported 2 taggings (0 errors, 2 skipped)"
      end

      test "reports taggings that fail to persist" do
        tags = [ { "id" => "1", "title" => "Imported Primary", "slug" => "imported-primary" } ]
        taggings = [ { "id" => "1", "tag_id" => "1", "taggable_type" => "Podcast", "taggable_id" => "1" } ]
        failing = ->(*) { raise ActiveRecord::ActiveRecordError, "boom" }

        output = stub_singleton(CategoriesEntry, :find_or_create_by!, failing) do
          run_import("tags" => tags, "podcasts" => [ podcast_fixture ], "taggings" => taggings)
        end

        assert_includes output, "✗ Error importing tagging: boom"
        assert_includes output, "✓ Imported 0 taggings (1 errors, 0 skipped)"
      end

      # Parsing helpers

      test "unparseable timestamps are ignored" do
        podcast = podcast_fixture.merge("created_at" => "not a date", "updated_at" => "")

        run_import("podcasts" => [ podcast ])

        entry = Entry.find_by!(slug: "imported-podcast")
        assert_in_delta Time.current, entry.entryable.created_at, 5
        assert_in_delta Time.current, entry.created_at, 5
      end

      test "free flags accept postgres and literal booleans only" do
        courses = [
          { "id" => "1", "free" => "t", "entry" => { "title" => "Free Course", "slug" => "free-course" } },
          { "id" => "2", "free" => "f", "entry" => { "title" => "Paid Course", "slug" => "paid-course" } },
          { "id" => "3", "entry" => { "title" => "Unknown Course", "slug" => "unknown-course" } }
        ]

        run_import("courses" => courses)

        assert Entry.find_by!(slug: "free-course").entryable.is_free
        assert_not Entry.find_by!(slug: "paid-course").entryable.is_free
        assert_not Entry.find_by!(slug: "unknown-course").entryable.is_free
      end

      test "empty yaml files import nothing" do
        output = run_import({})

        assert_includes output, "Import Summary"
        assert_includes output, "ID Mappings: {categories: 0, authors: 0, entries: 0}"
      end

      private

      def run_import(files)
        YAML_FILES.each do |name|
          File.write(File.join(@dir, "#{name}.yml"), files.fetch(name, []).to_yaml)
        end

        output, = capture_io { YamlImporter.new(yaml_dir: @dir).import_all }
        output
      end

      def author_fixture
        { "id" => "1", "name" => "Imported Author", "slug" => "imported-author" }
      end

      def podcast_fixture
        { "id" => "1", "entry" => { "title" => "Imported Podcast", "slug" => "imported-podcast" } }
      end
    end
  end
end

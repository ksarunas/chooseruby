# frozen_string_literal: true

require "test_helper"

module Imports
  module Rubyandrailsinfo
    class SqlToYamlConverterTest < ActiveSupport::TestCase
      SQL_DUMP = <<~SQL
        COPY "public"."tags" ("id", "title", "slug") FROM stdin;
        1\tTesting\ttesting
        \\.

        COPY "public"."authors" ("id", "name", "slug", "website_url") FROM stdin;
        1\tMatz\tmatz\t\\N
        \\.

        COPY "public"."books" ("id", "isbn", "year", "page", "amazon_url", "website_url", "free", "featured", "title", "content", "slug", "created_at", "updated_at") FROM stdin;
        1\t\\N\t2020\t300\thttps://amazon.com/book\thttps://book.example\tf\tt\tThe Book\tAbout the book\tthe-book\t2022-01-01 00:00:00\t2022-01-02 00:00:00
        \\.

        COPY "public"."courses" ("id", "free", "title", "slug", "website_url", "created_at", "updated_at") FROM stdin;
        1\tt\tThe Course\tthe-course\thttps://course.example\t2022-01-01 00:00:00\t2022-01-02 00:00:00
        \\.

        COPY "public"."newsletters" ("id", "title", "slug", "website_url", "created_at", "updated_at") FROM stdin;
        1\tThe Newsletter\tthe-newsletter\thttps://newsletter.example\t2022-01-01 00:00:00\t2022-01-02 00:00:00
        \\.

        COPY "public"."podcasts" ("id", "title", "slug", "website_url", "created_at", "updated_at") FROM stdin;
        1\tThe Podcast\tthe-podcast\thttps://podcast.example\t2022-01-01 00:00:00\t2022-01-02 00:00:00
        \\.

        COPY "public"."communities" ("id", "platform_type", "members", "title", "slug", "website_url", "created_at", "updated_at") FROM stdin;
        1\tslack\t100\tThe Community\tthe-community\thttps://community.example\t2022-01-01 00:00:00\t2022-01-02 00:00:00
        \\.

        COPY "public"."youtubes" ("id", "title", "slug", "website_url", "created_at", "updated_at") FROM stdin;
        1\tThe Channel\tthe-channel\thttps://youtube.com/channel\t2022-01-01 00:00:00\t2022-01-02 00:00:00
        \\.

        COPY "public"."screencasts" ("id", "title", "slug", "website_url", "created_at", "updated_at") FROM stdin;
        1\tThe Screencast\tthe-screencast\thttps://screencast.example\t2022-01-01 00:00:00\t2022-01-02 00:00:00
        \\.

        COPY "public"."lessons" ("id", "youtube_id", "title", "slug", "url", "created_at", "updated_at") FROM stdin;
        1\t1\tThe Lesson\tthe-lesson\tMwbmKqdDsyI\t2022-01-01 00:00:00\t2022-01-02 00:00:00
        \\.

        COPY "public"."authorings" ("id", "author_id", "authorabble_type", "authorabble_id") FROM stdin;
        1\t1\tBook\t1
        \\.

        COPY "public"."taggings" ("id", "tag_id", "taggable_type", "taggable_id") FROM stdin;
        1\t1\tBook\t1
        \\.
      SQL

      YAML_FILES = %w[
        tags authors books courses newsletters podcasts communities youtubes screencasts lessons authorings taggings
      ].freeze

      setup do
        @dir = Dir.mktmpdir
        @sql_file = File.join(@dir, "latest.sql")
        File.write(@sql_file, SQL_DUMP)
        @output_dir = File.join(@dir, "yaml")
        @converter = SqlToYamlConverter.new(sql_file: @sql_file, output_dir: @output_dir)
      end

      teardown { FileUtils.remove_entry(@dir) }

      test "writes one YAML file per table into the output directory" do
        output, = capture_io { @converter.convert_all }

        assert_equal YAML_FILES.map { |name| "#{name}.yml" }.sort, Dir.children(@output_dir).sort
        assert_includes output, "✓ Converted tags: 1 records → tags.yml"
        assert_includes output, "All conversions complete! YAML files created in #{@output_dir}"
      end

      test "simple tables drop null columns" do
        capture_io { @converter.convert_all }

        assert_equal [ { "id" => "1", "title" => "Testing", "slug" => "testing" } ], read_yaml("tags")
        assert_equal [ { "id" => "1", "name" => "Matz", "slug" => "matz" } ], read_yaml("authors")
        assert_equal [ { "id" => "1", "author_id" => "1", "authorabble_type" => "Book", "authorabble_id" => "1" } ],
                     read_yaml("authorings")
      end

      test "books keep their own fields and nest the entry fields" do
        capture_io { @converter.convert_all }

        assert_equal [ {
          "id" => "1", "year" => "2020", "page" => "300",
          "amazon_url" => "https://amazon.com/book", "website_url" => "https://book.example",
          "free" => "f", "featured" => "t",
          "created_at" => "2022-01-01 00:00:00", "updated_at" => "2022-01-02 00:00:00",
          "entry" => {
            "title" => "The Book", "content" => "About the book", "slug" => "the-book",
            "website_url" => "https://book.example"
          }
        } ], read_yaml("books")
      end

      test "each entity table selects its own fields" do
        capture_io { @converter.convert_all }

        assert_equal %w[id free created_at updated_at entry], read_yaml("courses").first.keys
        assert_equal %w[id created_at updated_at entry], read_yaml("newsletters").first.keys
        assert_equal %w[id created_at updated_at entry], read_yaml("podcasts").first.keys
        assert_equal %w[id platform_type members created_at updated_at entry], read_yaml("communities").first.keys
        assert_equal %w[id created_at updated_at entry], read_yaml("youtubes").first.keys
        assert_equal %w[id created_at updated_at entry], read_yaml("screencasts").first.keys
        assert_equal %w[id youtube_id created_at updated_at entry], read_yaml("lessons").first.keys
      end

      test "lessons nest the video url while other entities nest the website url" do
        capture_io { @converter.convert_all }

        assert_equal({ "title" => "The Lesson", "slug" => "the-lesson", "url" => "MwbmKqdDsyI" },
                     read_yaml("lessons").first["entry"])
        assert_equal({ "title" => "The Channel", "slug" => "the-channel", "website_url" => "https://youtube.com/channel" },
                     read_yaml("youtubes").first["entry"])
      end

      private

      def read_yaml(name)
        YAML.load_file(File.join(@output_dir, "#{name}.yml"))
      end
    end
  end
end

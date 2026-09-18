# frozen_string_literal: true

require "test_helper"

class AuthorSocialLinksTest < ActiveSupport::TestCase
  ALL_LINKS = {
    github_url: "https://github.com/matz",
    gitlab_url: "https://gitlab.com/matz",
    twitter_url: "https://twitter.com/matz",
    bluesky_url: "https://bsky.app/profile/matz",
    linkedin_url: "https://linkedin.com/in/matz",
    website_url: "https://matz.example.com",
    blog_url: "https://blog.matz.example.com",
    youtube_url: "https://youtube.com/@matz",
    twitch_url: "https://twitch.tv/matz",
    ruby_social_url: "https://ruby.social/@matz"
  }.freeze

  test "social_links returns every present link in display order" do
    author = Author.new(name: "Matz", **ALL_LINKS)

    links = author.social_links

    assert_equal ALL_LINKS.values, links.map { |link| link[:url] }
    assert_equal %w[GitHub GitLab X\ (Twitter) Bluesky LinkedIn Website Blog YouTube Twitch Ruby.social], links.map { |link| link[:name] }
    links.each { |link| assert_match(/\A[Mm]/, link[:icon_path]) }
  end

  test "social_links skips blank links" do
    author = Author.new(name: "Matz", github_url: "https://github.com/matz", website_url: "")

    links = author.social_links

    assert_equal [ "GitHub" ], links.map { |link| link[:name] }
  end

  test "social_links returns an empty array when the author has no links" do
    assert_empty Author.new(name: "Matz").social_links
  end
end

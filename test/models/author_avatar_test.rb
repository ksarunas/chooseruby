# frozen_string_literal: true

require "test_helper"

class AuthorAvatarTest < ActiveSupport::TestCase
  test "keeps the existing avatar when github_url is cleared" do
    author = Author.create!(name: "Avatar Keeper", github_url: "https://github.com/matz")
    assert_equal "https://github.com/matz.png", author.reload.avatar_url

    author.update!(github_url: nil)

    assert_equal "https://github.com/matz.png", author.reload.avatar_url
  end

  test "does not set an avatar when github_url has no extractable username" do
    author = Author.create!(name: "Repo Linker", github_url: "https://github.com/rails/rails")

    assert_nil author.reload.avatar_url
  end
end

# frozen_string_literal: true

# The front page, which previews the most recent entry of each type.
class HomeController < ApplicationController
  # How many entries each type previews on the front page.
  PREVIEW_LIMIT = 4
  HIGHLIGHT_LIMIT = 8
  CHANNEL_LIMIT = 3
  POPULAR_QUERY_LIMIT = 5

  def index
    @entry_stats = { resources: Entry.published.approved.count, categories: Category.count, authors: Author.count }
    @recent_entries = Entry.recently_curated_by_type(limit: PREVIEW_LIMIT)

    assign_highlights
    assign_collections
  end

  private

  def assign_highlights
    categories = Category.order(:display_order, :name)

    @featured_entries = Entry.for_homepage
    @highlight_categories = categories.limit(HIGHLIGHT_LIMIT)
    @community_channels = Community.order(member_count: :desc).limit(CHANNEL_LIMIT)
    @popular_queries = categories.limit(POPULAR_QUERY_LIMIT).pluck(:name)
  end

  def assign_collections
    @curated_collections = curated_collections_data
    @experience_tracks = experience_tracks_data
  end
end

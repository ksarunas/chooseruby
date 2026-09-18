# frozen_string_literal: true

# Builds the type specific record that sits behind an entry, from the fields the
# submission form sent.
#
# Each resource type accepts its own fields on top of the ones every entry has,
# and anything the form did not offer for that type is ignored.
class Entry::EntryableBuilder
  FIELDS = {
    "RubyGem" => %i[gem_name github_url documentation_url rubygems_url current_version downloads_count],
    "Book" => %i[isbn publisher publication_year page_count format purchase_url],
    "Course" => %i[platform instructor duration_hours currency is_free enrollment_url],
    "Tutorial" => %i[reading_time_minutes publication_date author_name platform],
    "Article" => %i[reading_time_minutes publication_date author_name platform],
    "Tool" => %i[tool_type github_url documentation_url license is_open_source],
    "Podcast" => %i[host episode_count frequency rss_feed_url spotify_url apple_podcasts_url],
    "Community" => %i[platform join_url member_count is_official]
  }.freeze

  # Types submitted with a price in dollars, which is stored in cents.
  PRICED_TYPES = %w[Course].freeze

  def initialize(resource_type, submitted)
    @resource_type = resource_type
    @submitted = submitted
  end

  def build
    fields = FIELDS.fetch(@resource_type) { raise ArgumentError, "Unknown resource type: #{@resource_type}" }

    @resource_type.constantize.new(attributes_for(fields))
  end

  private

  def attributes_for(fields)
    attributes = @submitted.slice(*fields)
    price = @submitted[:price]
    attributes[:price_cents] = (price.to_d * 100).to_i if price.present? && PRICED_TYPES.include?(@resource_type)

    attributes
  end
end

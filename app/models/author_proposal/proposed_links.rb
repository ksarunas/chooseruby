# frozen_string_literal: true

# The link changes a proposal asks for, checked against the fields an author
# actually publishes.
class AuthorProposal::ProposedLinks
  FIELDS = %w[
    github_url gitlab_url website_url bluesky_url ruby_social_url
    twitter_url linkedin_url youtube_url twitch_url blog_url
  ].freeze

  HTTP_URL = URI::DEFAULT_PARSER.make_regexp(%w[http https])

  # The form submits a value for every link field; keep only the filled ones.
  def self.from_form(submitted)
    submitted.to_h.reject { |_field, url| url.blank? }.presence
  end

  def initialize(link_updates)
    @link_updates = link_updates.to_h
  end

  # Yields every field and URL that should be written to the author, refusing
  # anything that is not a link an author publishes.
  def each
    @link_updates.each do |field_name, url|
      next if url.blank?
      raise ArgumentError, "Invalid link field: #{field_name}" unless FIELDS.include?(field_name)

      yield(field_name, url)
    end
  end

  # One message per link that cannot be written, for the proposal to report.
  def errors
    @link_updates.filter_map do |field_name, url|
      next if url.blank?
      next "#{field_name} is not a valid link field" unless FIELDS.include?(field_name)
      next if HTTP_URL.match?(url)

      "#{field_name} must be a valid URL starting with http:// or https://"
    end
  end
end

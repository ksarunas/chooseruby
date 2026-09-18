# frozen_string_literal: true

# A URL submitted with a proposal, reduced to a canonical form so that two
# spellings of the same address are recognised as the same resource.
#
#   ResourceUrl.new(" HTTPS://WWW.Example.com/ ").to_s # => "http://example.com"
class ResourceUrl
  def initialize(url)
    @url = url
  end

  def to_s
    @url.strip.downcase
      .sub(%r{\Ahttps://}, "http://")
      .sub(%r{\Ahttp://www\.}, "http://")
      .sub(%r{/\z}, "")
  end

  # The entry already in the directory that points at this same address.
  def matching_entry
    Entry.find_by(
      "REPLACE(REPLACE(LOWER(TRIM(url)), 'https://', 'http://'), 'www.', '') = ?",
      to_s
    )
  end
end

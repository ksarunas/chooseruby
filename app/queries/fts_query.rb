# frozen_string_literal: true

# A user supplied search string rendered as an SQLite FTS5 MATCH expression.
#
# Quoted phrases are preserved so they keep matching exactly. Every other word
# is stripped of the FTS5 operators that would otherwise be parsed as syntax,
# then given a wildcard suffix so partial words still match.
#
#   FtsQuery.new("matz").to_s                       # => "matz*"
#   FtsQuery.new("david hansson").to_s              # => "david* hansson*"
#   FtsQuery.new('david "heinemeier hansson"').to_s # => 'david* "heinemeier hansson"'
class FtsQuery
  # Characters FTS5 reads as operators rather than as part of a word.
  OPERATORS = /[()\-]/
  # Entry titles are also tokenised on apostrophes, so entry search drops those too.
  OPERATORS_WITH_APOSTROPHE = /[()\-']/

  PHRASE = /"[^"]*"/
  PLACEHOLDER_PREFIX = "__PHRASE_"
  TRAILING_WILDCARDS = /\*+$/

  def initialize(query_string, operators: OPERATORS)
    @query_string = query_string
    @operators = operators
  end

  def to_s
    phrases = @query_string.scan(PHRASE)

    phrases.each_with_index.reduce(matchable_words.join(" ")) do |result, (phrase, index)|
      result.gsub("#{PLACEHOLDER_PREFIX}#{index}__", phrase)
    end
  end

  private

  # Quoted phrases stand in as placeholders so that wildcards are only appended
  # to the words outside them.
  def without_phrases
    index = -1
    @query_string.gsub(PHRASE) { "#{PLACEHOLDER_PREFIX}#{index += 1}__" }
  end

  def matchable_words
    without_phrases
      .split(/\s+/)
      .filter_map { |word| word.start_with?(PLACEHOLDER_PREFIX) ? word : wildcarded(word) }
  end

  def wildcarded(word)
    cleaned = word.gsub(@operators, "").gsub(TRAILING_WILDCARDS, "")
    "#{cleaned}*" if cleaned.present?
  end
end

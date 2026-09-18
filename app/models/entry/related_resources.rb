# frozen_string_literal: true

# Picks the entries to suggest alongside the one being read.
#
# Suggestions come from the entry's own categories. They are spread across the
# first few categories so that one category cannot fill the whole list, then
# topped up from any of them if there is still room.
class Entry::RelatedResources
  # How many categories the suggestions are spread across.
  SPREAD = 3

  def initialize(entry, limit: 6)
    @entry = entry
    @limit = limit
    @collected = []
    @seen_ids = [ entry.id ]
  end

  def call
    return [] if category_ids.empty?

    category_ids.first(SPREAD).each { |category_id| gather(category_id, per_category) }
    gather(category_ids, remaining)

    @collected.first(limit)
  end

  private

  attr_reader :entry, :limit

  def category_ids
    @category_ids ||= entry.categories.pluck(:id)
  end

  # An even share of the list for each category we draw from.
  def per_category
    (limit.to_f / [ category_ids.length, SPREAD ].min).ceil
  end

  def remaining
    limit - @collected.length
  end

  # Adds up to `wanted` unseen suggestions from the given category or categories.
  def gather(categories, wanted)
    room = [ wanted, remaining ].min
    return if room <= 0

    found = suggestions_in(categories, room)
    @collected.concat(found)
    @seen_ids.concat(found.map(&:id))
  end

  def suggestions_in(categories, room)
    Entry.visible.with_card_includes
      .joins(:categories_entries)
      .where(categories_entries: { category_id: categories })
      .where.not(id: @seen_ids)
      .distinct
      .recently_curated
      .limit(room)
      .to_a
  end
end

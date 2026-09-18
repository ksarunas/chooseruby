# frozen_string_literal: true

# What to read next after an entry.
#
# Offers other work by the same authors, and entries on the same topics, topped
# up with others of the same type when the shared topics alone yield too few.
class Entry::Suggestions
  def initialize(entry, limit: 5)
    @entry = entry
    @limit = limit
  end

  def by_same_authors
    return Entry.none if entry.authors.blank?

    Entry.visible.with_card_includes
      .joins(:entries_authors)
      .where(entries_authors: { author_id: entry.author_ids })
      .where.not(id: entry.id)
      .distinct
      .recently_curated
      .limit(limit)
  end

  def related
    return [] if entry.categories.empty?

    found = entry.related_resources(limit: limit)
    shortfall = limit - found.size
    return found if shortfall <= 0

    (found + same_type(shortfall, besides: found)).first(limit)
  end

  private

  attr_reader :entry, :limit

  def same_type(wanted, besides:)
    Entry.visible.with_card_includes
      .where(entryable_type: entry.entryable_type)
      .where.not(id: [ entry.id, *besides.map(&:id) ])
      .recently_curated
      .limit(wanted)
      .to_a
  end
end

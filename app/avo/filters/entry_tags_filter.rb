# frozen_string_literal: true

# Narrows the resource list down to the entries carrying one tag.
class Avo::Filters::EntryTagsFilter < Avo::Filters::SelectFilter
  self.name = "Tags"

  def apply(_request, query, value)
    return query if value.blank?

    sanitized_value = ActiveRecord::Base.sanitize_sql_like(value)
    query.where(match_condition, "%#{sanitized_value}%")
  end

  def options
    column = tag_column

    Entry.where.not(column => nil).pluck(column).flatten.compact.uniq.sort.to_h { |tag| [ tag.titleize, tag ] }
  end

  private

  # Tags are stored as one denormalised column, so a partial match is the only
  # way to look one up.
  def match_condition
    "tags LIKE ?"
  end

  def tag_column
    :tags
  end
end

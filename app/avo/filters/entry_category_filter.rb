# frozen_string_literal: true

# Narrows the resource list down to the entries filed under one category.
class Avo::Filters::EntryCategoryFilter < Avo::Filters::SelectFilter
  self.name = "Category"

  def apply(_request, query, value)
    return query if value.blank?

    join = association
    query.joins(join).where(join => { id: value })
  end

  def options
    column = label_column

    Category.order(column).pluck(column, :id).to_h
  end

  private

  # Entries reach their categories through this association.
  def association
    :categories
  end

  # The category column shown to the admin in the dropdown.
  def label_column
    :name
  end
end

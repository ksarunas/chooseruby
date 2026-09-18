# frozen_string_literal: true

# Narrows the author list down to a single approval status.
class Avo::Filters::AuthorStatusFilter < Avo::Filters::SelectFilter
  self.name = "Status"

  def apply(_request, query, value)
    status = value.to_s
    return query unless options.value?(status)

    query.where(attribute => status)
  end

  def options
    {
      "Approved" => "approved",
      "Pending" => "pending"
    }
  end

  private

  def attribute
    :status
  end
end

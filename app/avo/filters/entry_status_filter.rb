# frozen_string_literal: true

# Narrows the resource list down to a single curation status.
class Avo::Filters::EntryStatusFilter < Avo::Filters::SelectFilter
  self.name = "Status"

  def apply(_request, query, value)
    status = value.to_s.downcase
    return query unless options.value?(status)

    query.where(attribute => status)
  end

  def options
    {
      "Pending" => "pending",
      "Approved" => "approved",
      "Rejected" => "rejected"
    }
  end

  private

  def attribute
    :status
  end
end

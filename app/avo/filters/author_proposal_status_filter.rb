# frozen_string_literal: true

# Narrows the author proposal list down to a single review status.
class Avo::Filters::AuthorProposalStatusFilter < Avo::Filters::SelectFilter
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

  def default
    "pending"
  end

  private

  def attribute
    :status
  end
end

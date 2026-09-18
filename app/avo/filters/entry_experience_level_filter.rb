# frozen_string_literal: true

# Narrows the resource list down to the audience a resource is written for.
class Avo::Filters::EntryExperienceLevelFilter < Avo::Filters::SelectFilter
  self.name = "Experience Level"

  def apply(_request, query, value)
    return query if value.blank?

    query.where(attribute => value)
  end

  def options
    {
      "All Levels" => "all_levels",
      "Beginner" => "beginner",
      "Intermediate" => "intermediate",
      "Advanced" => "advanced"
    }
  end

  private

  def attribute
    :experience_level
  end
end

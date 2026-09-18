# frozen_string_literal: true

# Narrows the resource list down to one kind of entryable, such as a book or
# a podcast.
class Avo::Filters::EntryTypeFilter < Avo::Filters::SelectFilter
  self.name = "Resource Type"

  def apply(_request, query, value)
    return query if value.blank?

    query.where(attribute => value)
  end

  def options
    {
      "Article" => "Article",
      "Blog" => "Blog",
      "Book" => "Book",
      "Channel" => "Channel",
      "Community" => "Community",
      "Course" => "Course",
      "Development Environment" => "DevelopmentEnvironment",
      "Directory" => "Directory",
      "Documentation" => "Documentation",
      "Framework" => "Framework",
      "Job Board" => "JobBoard",
      "Newsletter" => "Newsletter",
      "Podcast" => "Podcast",
      "Product" => "Product",
      "Ruby Gem" => "RubyGem",
      "Testing Resource" => "TestingResource",
      "Tool" => "Tool",
      "Tutorial" => "Tutorial",
      "Video" => "Video"
    }
  end

  private

  def attribute
    :entryable_type
  end
end

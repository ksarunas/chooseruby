# frozen_string_literal: true

# Narrows the resource list down to published or unpublished entries.
class Avo::Filters::EntryPublishedFilter < Avo::Filters::BooleanFilter
  self.name = "Published"

  # Understands the two shapes Avo hands a boolean filter - a hash of ticked
  # boxes, or a plain string - and narrows a query to the state that was
  # asked for. Ticking both boxes, or none, narrows nothing.
  class Selection
    def initialize(value, attribute)
      @value = value
      @attribute = attribute
    end

    def narrow(query)
      return query unless single?

      query.where(@attribute => ticked.first == "true")
    end

    private

    def single?
      ticked.one?
    end

    def ticked
      keys.select { |key| boxes[key] }
    end

    def keys
      %w[true false]
    end

    def boxes
      @value.is_a?(Hash) ? @value.stringify_keys : { @value.to_s => true }
    end
  end

  def apply(_request, query, value)
    Selection.new(value, attribute).narrow(query)
  end

  def options
    { "true" => "Published", "false" => "Unpublished" }
  end

  private

  def attribute
    :published
  end
end

# frozen_string_literal: true

require "test_helper"

class Avo::Actions::RejectEntriesFieldsTest < ActiveSupport::TestCase
  test "reject action defines an optional comment textarea field" do
    action = Avo::Actions::RejectEntries.new(record: nil, resource: nil, user: nil, view: :index)
    action.fields

    field = action.get_field_definitions.find { |definition| definition.id == :comment }
    assert_not_nil field
    assert_not field.required
  end
end

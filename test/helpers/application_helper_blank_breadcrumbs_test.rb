# frozen_string_literal: true

require "test_helper"

class ApplicationHelperBlankBreadcrumbsTest < ActionView::TestCase
  tests ApplicationHelper

  test "breadcrumbs renders nothing for an empty list" do
    assert_equal "", breadcrumbs([])
  end

  test "breadcrumbs renders nothing for nil" do
    assert_equal "", breadcrumbs(nil)
  end
end

# frozen_string_literal: true

# The Ruby communities listed in the directory.
class CommunitiesController < ApplicationController
  def index
    @communities = Community.order(is_official: :desc, member_count: :desc, platform: :asc)
  end
end

# frozen_string_literal: true

require "test_helper"

class AuthorizationConcernTestController < ApplicationController
  before_action :ensure_can_administer

  def index
    render plain: can_administer?.to_s
  end
end

class AuthorizationConcernTest < ActionController::TestCase
  tests AuthorizationConcernTestController

  setup do
    @routes = ActionDispatch::Routing::RouteSet.new
    @routes.draw do
      root "home#index"
      get "index", to: "authorization_concern_test#index"
    end
  end

  test "redirects anonymous visitors to the root path" do
    get :index

    assert_redirected_to root_path
    assert_equal "You are not authorized to access this page", flash[:alert]
  end

  test "redirects signed in users who cannot administer" do
    editor_session = Session.create!(user: users(:editor))
    cookies.signed[:session_token] = editor_session.token

    get :index

    assert_redirected_to root_path
    assert_equal "You are not authorized to access this page", flash[:alert]
  end

  test "lets administrators through" do
    cookies.signed[:session_token] = sessions(:admin_session).token

    get :index

    assert_response :success
    assert_equal "true", response.body
  end
end

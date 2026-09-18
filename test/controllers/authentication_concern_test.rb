# frozen_string_literal: true

require "test_helper"

class AuthenticationConcernTestController < ApplicationController
  before_action :require_authentication

  def index
    render plain: current_user.email_address
  end
end

class AuthenticationConcernRequireAuthenticationTest < ActionController::TestCase
  tests AuthenticationConcernTestController

  setup do
    @routes = ActionDispatch::Routing::RouteSet.new
    @routes.draw do
      root "home#index"
      resource :session, only: %i[new create destroy]
      get "index", to: "authentication_concern_test#index"
    end
  end

  test "redirects anonymous visitors to the sign in page" do
    get :index

    assert_redirected_to new_session_path
    assert_equal "Please sign in to continue", flash[:alert]
  end

  test "lets signed in users through and exposes current_user" do
    cookies.signed[:session_token] = sessions(:admin_session).token

    get :index

    assert_response :success
    assert_equal users(:admin).email_address, response.body
  end
end

class AuthenticationConcernSessionLookupTest < ActionDispatch::IntegrationTest
  test "a signed in visitor touches the session on each request" do
    sign_in_as_admin
    session = Session.last
    session.update_columns(last_active_at: 2.days.ago)

    get root_path

    assert_response :success
    assert_operator session.reload.last_active_at, :>, 1.minute.ago
  end

  test "a cookie for a deleted session is ignored" do
    sign_in_as_admin
    Session.last.destroy

    get root_path

    assert_response :success
  end

  test "an expired session is not revived" do
    sign_in_as_admin
    session = Session.last
    expired_at = 31.days.ago
    session.update_columns(last_active_at: expired_at)

    get root_path

    assert_response :success
    assert_in_delta expired_at, session.reload.last_active_at, 1.second
  end

  test "signing out without an active session still clears the cookie" do
    delete session_url

    assert_redirected_to root_path
    assert_predicate cookies[:session_token], :blank?
  end

  private

  def sign_in_as_admin
    post session_url, params: { email_address: "admin@test.com", password: "password" }
  end
end

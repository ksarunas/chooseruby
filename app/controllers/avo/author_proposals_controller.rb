# frozen_string_literal: true

class Avo::AuthorProposalsController < Avo::ResourcesController
  # This controller handles the Avo admin interface for AuthorProposal resources.
  # Proposals are created via public forms and reviewed through the approve/reject
  # actions, so the admin may only list and inspect them.
  BLOCKED_ACTIONS = %i[create new edit update destroy].freeze

  def authorize_action(class_to_authorize, action = nil)
    raise Avo::NotAuthorizedError if BLOCKED_ACTIONS.include?((action || action_name).to_sym)

    super
  end
end

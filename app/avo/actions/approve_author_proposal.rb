# frozen_string_literal: true

# Accepts author profile proposals in bulk and reports the ones that could not
# be applied instead of aborting the whole batch.
class Avo::Actions::ApproveAuthorProposal < Avo::BaseAction
  self.name = "Approve Proposal"
  self.message = "Are you sure you want to approve the selected proposal(s)?"
  self.confirm_button_label = "Approve"
  self.cancel_button_label = "Cancel"
  self.no_confirmation = false

  def handle(records:, **_args)
    failures = records.filter_map { |proposal| approval_failure(proposal) }

    report(records.count - failures.count, failures)
  end

  # Only show this action for pending proposals
  def visible?
    return true if view == :index && !record

    record&.pending?
  end

  private

  def noun
    "proposal"
  end

  def approval_failure(proposal)
    proposal.approve!
    nil
  rescue StandardError => error
    failure_message(proposal, error)
  end

  def failure_message(proposal, error)
    "#{noun.capitalize} ##{proposal.id}: #{error.message}"
  end

  def report(success_count, failures)
    if failures.any?
      error "#{success_count} approved, #{failures.count} failed: #{failures.join('; ')}"
    else
      succeed "#{success_count} #{noun.pluralize(success_count)} approved successfully!"
    end
  end
end

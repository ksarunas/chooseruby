# frozen_string_literal: true

# Turns down author profile proposals in bulk, insisting on written feedback
# and reporting the ones that could not be applied.
class Avo::Actions::RejectAuthorProposal < Avo::BaseAction
  self.name = "Reject Proposal"
  self.message = "Are you sure you want to reject the selected proposal(s)?"
  self.confirm_button_label = "Reject"
  self.cancel_button_label = "Cancel"
  self.no_confirmation = false

  def fields
    field :admin_comment, as: :textarea,
          help: "Required: Explain why this proposal is being rejected",
          placeholder: "Provide feedback for the submitter...",
          required: true
  end

  def handle(records:, fields:, **_args)
    admin_comment = fields[:admin_comment]
    return error "Admin comment is required when rejecting proposals" if admin_comment.blank?

    reject_all(records, admin_comment)
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

  def reject_all(records, admin_comment)
    failures = records.filter_map { |proposal| rejection_failure(proposal, admin_comment) }

    report(records.count - failures.count, failures)
  end

  def rejection_failure(proposal, admin_comment)
    proposal.reject!(admin_comment: admin_comment)
    nil
  rescue StandardError => error
    failure_message(proposal, error)
  end

  def failure_message(proposal, error)
    "#{noun.capitalize} ##{proposal.id}: #{error.message}"
  end

  def report(success_count, failures)
    if failures.any?
      error "#{success_count} rejected, #{failures.count} failed: #{failures.join('; ')}"
    else
      succeed "#{success_count} #{noun.pluralize(success_count)} rejected successfully!"
    end
  end
end

# frozen_string_literal: true

# Grants approved status to every selected author in one go.
class Avo::Actions::ApproveAuthors < Avo::BaseAction
  self.name = "Approve Authors"
  self.message = "Are you sure you want to approve the selected authors?"
  self.confirm_button_label = "Approve"
  self.cancel_button_label = "Cancel"
  self.no_confirmation = false

  def handle(records:, **_args)
    records.each { |author| author.update(status: :approved) }
    count = records.count

    succeed "#{count} #{noun.pluralize(count)} approved successfully!"
  end

  private

  def noun
    "author"
  end
end

# frozen_string_literal: true

# Hides every selected resource from the public directory.
class Avo::Actions::UnpublishEntries < Avo::BaseAction
  self.name = "Unpublish Resources"
  self.message = "Are you sure you want to unpublish the selected resources?"
  self.confirm_button_label = "Unpublish"
  self.cancel_button_label = "Cancel"
  self.no_confirmation = false

  def handle(records:, **_args)
    records.each { |entry| entry.update(published: false) }
    count = records.count

    succeed "#{count} #{noun.pluralize(count)} unpublished successfully!"
  end

  private

  def noun
    "resource"
  end
end

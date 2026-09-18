# frozen_string_literal: true

# View helpers for rendering entries.
module EntriesHelper
  # Formats experience level options with humanized labels.
  #
  # @param selected [String, nil] level to preselect
  # @return [String] HTML options for select
  def experience_level_options_for_select(selected = nil)
    options = Entry.selectable_experience_levels.map { |level| [ level.humanize, level ] }
    options_for_select(options, selected)
  end
end

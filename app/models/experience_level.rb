# frozen_string_literal: true

# The difficulty an entry is pitched at, identified by the name stored on the
# entry. Knows how that level should be presented to a reader.
#
#   ExperienceLevel["beginner"].badge_color # => "bg-emerald-500"
class ExperienceLevel
  BADGE_COLORS = {
    "beginner" => "bg-emerald-500",
    "intermediate" => "bg-amber-500",
    "advanced" => "bg-rose-500"
  }.freeze

  # Used for all_levels and for anything we do not recognise.
  DEFAULT_BADGE_COLOR = "bg-slate-500"

  def self.[](name)
    new(name)
  end

  def initialize(name)
    @name = name
  end

  # The Tailwind background colour of the dot shown next to an entry.
  def badge_color
    BADGE_COLORS.fetch(@name, DEFAULT_BADGE_COLOR)
  end
end

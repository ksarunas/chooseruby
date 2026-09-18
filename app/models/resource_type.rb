# frozen_string_literal: true

# A kind of resource in the directory, such as gems or books, identified by the
# slug that appears in directory URLs.
#
# Knows how it should be introduced to a reader: its display name, its emoji,
# the subtitle of its browse page and the message inviting a submission.
#
#   ResourceType["gems"].name  # => "Ruby Gems"
#   ResourceType["gems"].emoji # => "\u{1F48E}"
class ResourceType
  METADATA = {
    "gems" => {
      name: "Ruby Gems",
      emoji: "💎",
      description: "curated gems for your Ruby projects"
    },
    "books" => {
      name: "Books",
      emoji: "📚",
      description: "curated books to master Ruby and Rails"
    },
    "courses" => {
      name: "Courses",
      emoji: "🎓",
      description: "curated courses to learn Ruby and Rails"
    },
    "tutorials" => {
      name: "Tutorials",
      emoji: "📝",
      description: "curated tutorials for hands-on learning"
    },
    "articles" => {
      name: "Articles",
      emoji: "📰",
      description: "curated articles on Ruby and Rails"
    },
    "tools" => {
      name: "Tools",
      emoji: "🛠️",
      description: "curated tools for Ruby development"
    },
    "podcasts" => {
      name: "Podcasts",
      emoji: "🎙️",
      description: "curated podcasts about Ruby and Rails"
    },
    "communities" => {
      name: "Communities",
      emoji: "👥",
      description: "curated communities to connect with Rubyists"
    },
    "newsletters" => {
      name: "Newsletters",
      emoji: "📧",
      description: "curated newsletters for Ruby developers"
    },
    "blogs" => {
      name: "Blogs",
      emoji: "📝",
      description: "curated blogs for Ruby developers"
    },
    "videos" => {
      name: "Videos",
      emoji: "🎥",
      description: "curated videos for Ruby developers"
    },
    "channels" => {
      name: "Channels",
      emoji: "📺",
      description: "curated channels for Ruby developers"
    },
    "documentations" => {
      name: "Documentation",
      emoji: "📚",
      description: "curated documentation for Ruby developers"
    },
    "testing-resources" => {
      name: "Testing Resources",
      emoji: "🧪",
      description: "curated testing resources for Ruby developers"
    },
    "development-environments" => {
      name: "Development Environments",
      emoji: "💻",
      description: "curated development environments for Ruby developers"
    },
    "job-boards" => {
      name: "Job Boards",
      emoji: "💼",
      description: "curated job boards for Ruby developers"
    },
    "frameworks" => {
      name: "Frameworks",
      emoji: "🏗️",
      description: "curated frameworks for Ruby developers"
    },
    "directories" => {
      name: "Directories",
      emoji: "📂",
      description: "curated directories for Ruby developers"
    },
    "products" => {
      name: "Products",
      emoji: "🚀",
      description: "curated products for Ruby developers"
    }
  }.freeze

  # Slugs whose singular form Rails cannot work out on its own.
  IRREGULAR_SINGULARS = {
    "testing-resources" => "testing resource",
    "development-environments" => "development environment",
    "documentations" => "documentation",
    "job-boards" => "job board"
  }.freeze

  DEFAULT_EMOJI = "\u{1F4E6}"

  def self.[](slug)
    new(slug)
  end

  def initialize(slug)
    @slug = slug
  end

  def name
    METADATA.dig(@slug, :name) || @slug.titleize
  end

  def emoji
    METADATA.dig(@slug, :emoji) || DEFAULT_EMOJI
  end

  def description
    METADATA.dig(@slug, :description) || "curated #{@slug} for Ruby developers"
  end

  def submission_message
    "Know a great Ruby #{singular_name}? Submit it here"
  end

  private

  def singular_name
    IRREGULAR_SINGULARS[@slug] || @slug.tr("-", " ").singularize
  end
end

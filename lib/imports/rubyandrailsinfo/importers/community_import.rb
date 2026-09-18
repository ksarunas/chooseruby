# frozen_string_literal: true

module Imports
  module Rubyandrailsinfo
    module Importers
      # Imports one communities.yml record as a Community with its Entry
      # The YAML carries no platform or membership data, so those take their defaults
      class CommunityImport < EntryRecordImport
        def self.plural
          "communities"
        end

        def self.singular
          "community"
        end

        private

        def entryable
          Community.create! { |community| community.assign_attributes(community_attributes) }
        end

        def community_attributes
          { platform: "Other", join_url: join_url, member_count: nil, is_official: false,
            created_at: time("created_at"), updated_at: time("updated_at") }
        end

        def join_url
          entry_data["website_url"].presence || "https://example.com/#{entry_data["slug"]}"
        end
      end
    end
  end
end

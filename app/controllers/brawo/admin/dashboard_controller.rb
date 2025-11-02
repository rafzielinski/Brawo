module Brawo
  module Admin
    class DashboardController < Brawo::AdminController
      def index
        @content_types = Brawo::Registry.all
        @recent_entries = []
        
        # Get recent entries from all content types
        @content_types.each do |content_type_class|
          entries = content_type_class.order(created_at: :desc).limit(5)
          @recent_entries.concat(entries.map { |entry|
            {
              entry: entry,
              content_type: content_type_class.config
            }
          })
        end
        
        @recent_entries = @recent_entries.sort_by { |item| item[:entry].created_at }.reverse.take(10)
      end
    end
  end
end
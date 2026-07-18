module BrawoCms
  module Admin
    module ApplicationHelper
      def brawo_format_date(date)
        date.strftime(t('brawo.formats.date'))
      end

      def brawo_format_datetime(datetime)
        datetime.strftime(t('brawo.formats.datetime'))
      end

      def brawo_status_label(status)
        t("brawo.status.#{status}", default: status.to_s.titleize)
      end

      def brawo_status_options
        %w[draft published archived].map do |status|
          [brawo_status_label(status), status]
        end
      end
    end
  end
end

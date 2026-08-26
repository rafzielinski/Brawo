module BrawoCms
  module Admin
    module ValidatedFieldHelper
      DEFAULT_URL_SCHEMES = %w[https http ftp].freeze

      VALIDATED_URL_PARTIAL = "brawo_cms/admin/shared/validated_url_field"
      VALIDATED_EMAIL_PARTIAL = "brawo_cms/admin/shared/validated_email_field"

      def brawo_url_field(**options)
        default_scheme = (options[:default_scheme] || "https").to_s.downcase
        allowed_schemes = normalize_url_schemes(options[:allowed_schemes])
        display = split_url_for_display(options[:value], default_scheme: default_scheme)

        BrawoCms::Admin::BaseController.render(
          partial: VALIDATED_URL_PARTIAL,
          locals: build_validated_url_locals(options, default_scheme, allowed_schemes, display),
          formats: [:html]
        )
      end

      def brawo_email_field(**options)
        BrawoCms::Admin::BaseController.render(
          partial: VALIDATED_EMAIL_PARTIAL,
          locals: build_validated_email_locals(options),
          formats: [:html]
        )
      end

      private

      def build_validated_url_locals(options, default_scheme, allowed_schemes, display)
        name = options[:name]
        stored_value = options[:value]
        disabled = options[:disabled] || false
        required = options[:required] || false
        input_html = (options[:input_html] || {}).deep_dup
        visible_class = class_names("form-control brawo-validated-field__input", input_html.delete(:class))

        {
          display_scheme: display[:scheme],
          default_scheme: default_scheme,
          allowed_schemes: allowed_schemes,
          required: required,
          disabled: disabled,
          url_hidden_field: build_url_hidden_field(
            form: options[:form],
            name: name,
            value: stored_value,
            disabled: disabled
          ),
          url_visible_field: build_url_visible_field(
            value: display[:body],
            input_html: input_html,
            input_class: visible_class,
            disabled: disabled
          ),
          invalid_message: t("brawo.fields.url_invalid")
        }
      end

      def build_validated_email_locals(options)
        name = options[:name]
        value = options[:value]
        disabled = options[:disabled] || false
        required = options[:required] || false
        input_html = (options[:input_html] || {}).deep_dup
        input_class = class_names("form-control brawo-validated-field__input", input_html.delete(:class))

        input_field = build_named_text_field(
          form: options[:form],
          name: name,
          value: value,
          input_html: input_html,
          input_class: input_class,
          disabled: disabled,
          target: "input",
          type: "email"
        )

        {
          required: required,
          disabled: disabled,
          input_field: input_field,
          invalid_message: t("brawo.fields.email_invalid")
        }
      end

      def build_named_text_field(form:, name:, value:, input_html:, input_class:, disabled:, target:, type: "text")
        data = (input_html[:data] || {}).merge(validated_field_target: target)
        html_options = input_html.merge(class: input_class, disabled: disabled, data: data, type: type)

        if form
          form.text_field(name, html_options.merge(value: value))
        else
          text_field_tag(name, value, html_options)
        end
      end

      def build_url_hidden_field(form:, name:, value:, disabled:)
        options = {
          disabled: disabled,
          data: { validated_field_target: "hidden" },
          autocomplete: "off"
        }

        if form
          form.hidden_field(name, options.merge(value: value))
        else
          hidden_field_tag(name, value, options)
        end
      end

      def build_url_visible_field(value:, input_html:, input_class:, disabled:)
        html_options = input_html.merge(
          class: input_class,
          disabled: disabled,
          type: "text",
          autocomplete: "off",
          data: (input_html[:data] || {}).merge(validated_field_target: "input")
        )

        tag.input(**html_options.merge(value: value))
      end

      def split_url_for_display(value, default_scheme: "https")
        if value.blank?
          return { scheme: default_scheme, body: "" }
        end

        if value.match(/\A([a-z][a-z0-9+.-]*):\/\/(.*)\z/i)
          { scheme: $1.downcase, body: $2 }
        else
          { scheme: default_scheme, body: value }
        end
      end

      def normalize_url_schemes(schemes)
        list = schemes.presence || DEFAULT_URL_SCHEMES
        Array(list).map { |scheme| scheme.to_s.downcase.sub(/:\z/, "") }.uniq
      end
    end
  end
end

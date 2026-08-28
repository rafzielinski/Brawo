# frozen_string_literal: true

require "rails_helper"

RSpec.configure do |config|
  config.openapi_root = BrawoCms::Engine.root.join("openapi").to_s

  config.openapi_specs = {
    "v1/swagger.yaml" => {
      openapi: "3.0.1",
      info: {
        title: "BrawoCMS API",
        version: "v1",
        description: <<~DESC.strip
          JSON API for content and taxonomy management.
          Paths are relative to the engine mount point (default `/admin`).
          Optional bearer token when `BrawoCms.api_token` is set in the host app.
          Use `content_types` and `taxonomy_types` for field schema introspection.
        DESC
      },
      paths: {},
      servers: [
        { url: "/", description: "Host app root (paths include default /admin mount)" }
      ],
      components: {
        securitySchemes: {
          bearer_auth: {
            type: :http,
            scheme: :bearer,
            description: "Required when BrawoCms.api_token is configured"
          }
        },
        schemas: {
          errors: {
            type: :object,
            properties: {
              errors: {
                type: :array,
                items: { type: :string }
              }
            },
            required: ["errors"]
          },
          field_definition: {
            type: :object,
            properties: {
              name: { type: :string },
              type: { type: :string },
              label: { type: :string },
              help_text: { type: :string, nullable: true },
              taxonomy_type: { type: :string, nullable: true },
              model_class: { type: :string, nullable: true },
              choices: {
                type: :array,
                items: { type: :array, items: { type: :string } },
                nullable: true
              },
              sub_fields: {
                type: :array,
                items: { "$ref" => "#/components/schemas/field_definition" },
                nullable: true
              },
              wrapper: {
                type: :object,
                nullable: true,
                properties: {
                  width: { type: :string, description: 'Field width percentage for tablet+ (default 100)' },
                  class: { type: :string, description: 'Extra CSS class on field wrapper' },
                  attr: {
                    oneOf: [
                      { type: :object, additionalProperties: { type: :string } },
                      { type: :string, description: 'HTML attributes string, e.g. data-foo="bar"' }
                    ]
                  }
                }
              }
            },
            required: %w[name type label]
          },
          type_schema: {
            type: :object,
            properties: {
              type: { type: :string },
              label: { type: :string },
              seo: { type: :boolean },
              tabs: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    key: { type: :string },
                    label: { type: :string, nullable: true },
                    fields: {
                      type: :array,
                      items: { "$ref" => "#/components/schemas/field_definition" }
                    }
                  },
                  required: %w[key fields]
                }
              },
              fields: {
                type: :array,
                items: { "$ref" => "#/components/schemas/field_definition" }
              },
              header_fields: {
                type: :array,
                items: { "$ref" => "#/components/schemas/field_definition" }
              }
            },
            required: %w[type label fields header_fields]
          },
          content: {
            type: :object,
            properties: {
              id: { type: :integer },
              content_type: { type: :string },
              title: { type: :string, nullable: true },
              slug: { type: :string, nullable: true },
              status: { type: :string, enum: %w[draft published archived] },
              published_at: { type: :string, format: "date-time", nullable: true },
              fields: { type: :object, additionalProperties: true },
              created_at: { type: :string, format: "date-time" },
              updated_at: { type: :string, format: "date-time" }
            },
            required: %w[id content_type status fields created_at updated_at]
          },
          content_input: {
            type: :object,
            properties: {
              title: { type: :string },
              slug: { type: :string },
              status: { type: :string, enum: %w[draft published archived] },
              published_at: { type: :string, format: "date-time", nullable: true },
              fields: { type: :object, additionalProperties: true }
            }
          },
          taxonomy: {
            type: :object,
            properties: {
              id: { type: :integer },
              taxonomy_type: { type: :string },
              name: { type: :string, nullable: true },
              slug: { type: :string, nullable: true },
              description: { type: :string, nullable: true },
              fields: { type: :object, additionalProperties: true },
              created_at: { type: :string, format: "date-time" },
              updated_at: { type: :string, format: "date-time" }
            },
            required: %w[id taxonomy_type fields created_at updated_at]
          },
          taxonomy_input: {
            type: :object,
            properties: {
              name: { type: :string },
              slug: { type: :string },
              description: { type: :string },
              fields: { type: :object, additionalProperties: true }
            }
          },
          media: {
            type: :object,
            properties: {
              id: { type: :integer },
              title: { type: :string, nullable: true },
              alt_text: { type: :string, nullable: true },
              filename: { type: :string, nullable: true },
              content_type: { type: :string, nullable: true },
              byte_size: { type: :integer, nullable: true },
              url: { type: :string, nullable: true },
              thumbnail_url: { type: :string, nullable: true },
              created_at: { type: :string, format: "date-time" },
              updated_at: { type: :string, format: "date-time" }
            },
            required: %w[id created_at updated_at]
          },
          media_input: {
            type: :object,
            properties: {
              title: { type: :string },
              alt_text: { type: :string },
              signed_id: { type: :string, description: "ActiveStorage direct upload signed blob id" }
            }
          }
        }
      }
    }
  }

  config.openapi_format = :yaml
end

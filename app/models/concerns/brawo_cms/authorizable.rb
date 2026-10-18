# frozen_string_literal: true

module BrawoCms
  module Authorizable
    extend ActiveSupport::Concern

    included do
      enum :role, Authorization::ROLES, default: :admin
    end

    def can?(capability)
      Authorization.capability?(role, capability)
    end

    def initials
      email.to_s.strip.first&.upcase || "?"
    end
  end
end

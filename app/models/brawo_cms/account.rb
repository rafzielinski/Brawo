# frozen_string_literal: true

module BrawoCms
  class Account < ActiveRecord::Base
    self.table_name = "brawo_cms_accounts"

    include Rodauth::Rails.model
    include Authorizable

    enum :status, { unverified: 1, verified: 2, closed: 3 }

    validates :email, presence: true
    validates :role, presence: true
  end
end

# frozen_string_literal: true

module BrawoCms
  class Account
    class Identity < ActiveRecord::Base
      self.table_name = "brawo_cms_account_identities"

      belongs_to :account, class_name: "BrawoCms::Account", foreign_key: :brawo_cms_account_id
    end
  end
end

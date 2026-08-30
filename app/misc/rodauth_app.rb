# frozen_string_literal: true

class RodauthApp < Rodauth::Rails::App
  configure RodauthMain

  route do |r|
    r.rodauth
  end
end

module Avo
  class BaseResource < Avo::Resources::Base
    private

  def admin_only_options
    {
      readonly: -> { !current_user.admin? }
    }
  end
  end
end

module RandomSelectable
  extend ActiveSupport::Concern

  class_methods do
    def pick_random
      ids = pluck(:id)
      return nil if ids.empty?
      find_by(id: ids.sample)
    end
  end
end

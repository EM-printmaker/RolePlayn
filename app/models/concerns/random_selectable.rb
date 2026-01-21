module RandomSelectable
  extend ActionSupport::Concern

  class_methods do
    def pick_random
      order("RANDOM()").first
    end
  end
end

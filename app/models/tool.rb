class Tool < ApplicationRecord
  def to_param
    slug
  end
end

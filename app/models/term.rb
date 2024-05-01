class Term < ApplicationRecord

  scope :search, ->(query) do
    where("name ILIKE ?", "%#{query}%").or(where("content ILIKE ?", "%#{query}%"))
  end


end

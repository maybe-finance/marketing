class Institution < ApplicationRecord
  # Set the primary key since we're using institution_id instead of id
  self.primary_key = "institution_id"

  # Validations
  validates :institution_id, presence: true, uniqueness: true
  validates :name, presence: true
  validates :country_codes, presence: true
  validates :products, presence: true

  # Scopes for common queries
  scope :by_country, ->(country_code) { where("? = ANY(country_codes)", country_code) }
  scope :with_product, ->(product) { where("? = ANY(products)", product) }
  scope :search_by_name, ->(query) { where("name ILIKE ?", "%#{query}%") }


  # Class methods
  def self.search(query, country: nil, product: nil)
    results = all
    results = results.search_by_name(query) if query.present?
    results = results.by_country(country) if country.present?
    results = results.with_product(product) if product.present?
    results.order(:name)
  end

  # Instance methods

  def supports_product?(product_name)
    products.include?(product_name)
  end

  def available_in_country?(country_code)
    country_codes.include?(country_code)
  end

  # Convert to hash for API responses
  def to_search_result
    {
      institution_id: institution_id,
      name: name,
      country_codes: country_codes,
      products: products,
      logo_url: logo_url,
      website: website,
      oauth: oauth || false,
      primary_color: primary_color
    }
  end

  # Ransack configuration
  def self.ransackable_attributes(auth_object = nil)
    %w[
      country_codes
      created_at
      institution_id
      logo_url
      name
      oauth
      primary_color
      products
      updated_at
      website
    ]
  end
end

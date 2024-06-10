module MetaImage
  extend ActiveSupport::Concern

  included do
    after_commit :create_meta_image, on: [ :create, :update ]
  end

  private

  def create_meta_image(custom_text)
    bb = Bannerbear::Client.new
    begin
      response = bb.create_image("RnxGpW5lvKw0bEXrJ1",
        synchronous: true,
        modifications: [
          {
            name: "text",
            text: custom_text
          }
        ]
      )

      self.update_columns(meta_image_url: response["image_url"])
    rescue => e
      Rails.logger.error "Failed to create image: #{e.message}"
    end
  end
end

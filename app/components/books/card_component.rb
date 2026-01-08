class Books::CardComponent < ViewComponent::Base
  def initialize(book:)
    @book = book
  end

  def cover_url
    if @book.cover_image.attached?
      Rails.application.routes.url_helpers.rails_blob_path(@book.cover_image, only_path: true)
    else
      # Placeholder SVG image
      "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='200' height='300'%3E%3Crect width='200' height='300' fill='%23ddd'/%3E%3Ctext x='50%25' y='50%25' font-family='Arial' font-size='20' fill='%23999' text-anchor='middle' dy='.3em'%3ENo Cover%3C/text%3E%3C/svg%3E"
    end
  end
end

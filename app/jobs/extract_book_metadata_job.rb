class ExtractBookMetadataJob < ApplicationJob
  queue_as :default

  def perform(book_id)
    book = Book.find(book_id)
    return unless book.epub? && book.file.attached?

    book.file.open do |file|
      metadata = EpubMetadataExtractor.new(file).extract

      # Extract cover separately
      cover_data = metadata.delete(:cover_image_data)

      # Update text metadata (only if not already set by user)
      update_attributes = {}
      update_attributes[:title] = metadata[:title] if book.title.blank?
      update_attributes[:author] = metadata[:author] if book.author.blank? && metadata[:author].present?
      update_attributes[:description] = metadata[:description] if book.description.blank? && metadata[:description].present?
      update_attributes[:publisher] = metadata[:publisher] if book.publisher.blank? && metadata[:publisher].present?
      update_attributes[:isbn] = metadata[:isbn] if book.isbn.blank? && metadata[:isbn].present?
      update_attributes[:language] = metadata[:language] if metadata[:language].present?
      update_attributes[:published_on] = metadata[:published_on] if book.published_on.blank? && metadata[:published_on].present?

      book.update!(update_attributes) if update_attributes.any?

      # Attach cover image if present and not already attached
      if cover_data && !book.cover_image.attached?
        book.cover_image.attach(cover_data)
      end
    end
  rescue StandardError => e
    Rails.logger.error "Failed to extract metadata for book #{book_id}: #{e.message}"
    # Book still saved, just without metadata
  end
end

class EpubMetadataExtractor
  def initialize(file_path)
    @file_path = file_path
  end

  def extract
    epub = GEPUB::Book.parse(@file_path)

    {
      title: extract_title(epub),
      author: extract_author(epub),
      description: extract_description(epub),
      publisher: epub.publisher&.to_s&.strip.presence,
      isbn: extract_isbn(epub),
      language: epub.language&.to_s&.strip.presence || "en",
      published_on: extract_date(epub)
    }.tap do |metadata|
      extract_cover_image(epub, metadata)
    end
  end

  private

  def extract_title(epub)
    epub.title&.to_s&.strip.presence || "Untitled"
  end

  def extract_author(epub)
    epub.creator&.to_s&.strip.presence
  end

  def extract_description(epub)
    epub.description&.to_s&.strip.presence
  end

  def extract_isbn(epub)
    # EPUB can store ISBN in identifier field
    epub.identifier_list.find { |id| id[:id] =~ /isbn/i }&.dig(:value)
  end

  def extract_date(epub)
    date_string = epub.date&.to_s
    return nil if date_string.blank?

    Date.parse(date_string)
  rescue ArgumentError
    nil
  end

  def extract_cover_image(epub, metadata)
    # Gepub provides cover_image method
    cover_item = epub.resources.find { |item| item.properties&.include?("cover-image") }
    return unless cover_item

    # Store cover data to attach later
    metadata[:cover_image_data] = {
      io: StringIO.new(cover_item.read),
      filename: cover_item.href,
      content_type: cover_item.media_type
    }
  end
end

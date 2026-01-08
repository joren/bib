class EpubMetadataExtractor
  def initialize(io)
    @io = io
  end

  def extract
    epub = GEPUB::Book.parse(@io)

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
    # Access package and manifest
    package = epub.instance_variable_get(:@package)
    return unless package

    # Try to find cover ID from metadata (EPUB 2.0 style)
    oldstyle_meta = package.metadata.oldstyle_meta
    cover_meta = oldstyle_meta.find { |meta| meta.instance_variable_get(:@attributes)&.dig("name") == "cover" }
    cover_id = cover_meta&.instance_variable_get(:@attributes)&.dig("content")

    # If cover ID found, get the item from manifest
    if cover_id
      items = package.manifest.item_list
      cover_item = items[cover_id]

      if cover_item
        metadata[:cover_image_data] = {
          io: StringIO.new(cover_item.content),
          filename: cover_item.href,
          content_type: cover_item.media_type
        }
        return
      end
    end

    # Fallback: Try EPUB 3.0 style with properties
    items = package.manifest.item_list
    cover_item = items.values.find { |item| item.properties&.include?("cover-image") }

    return unless cover_item

    metadata[:cover_image_data] = {
      io: StringIO.new(cover_item.content),
      filename: cover_item.href,
      content_type: cover_item.media_type
    }
  end
end

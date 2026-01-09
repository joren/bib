require "epub/parser"
require "tempfile"

class EpubMetadataExtractor
  def initialize(io)
    @io = io
  end

  def extract
    with_tempfile do |path|
      epub = EPUB::Parser.parse(path)

      {
        title: extract_title(epub),
        author: extract_author(epub),
        description: extract_description(epub),
        publisher: extract_publisher(epub),
        isbn: extract_isbn(epub),
        language: extract_language(epub),
        published_on: extract_date(epub)
      }.tap do |metadata|
        extract_cover_image(epub, metadata)
      end
    end
  end

  private

  def with_tempfile
    tempfile = Tempfile.new(["epub", ".epub"])
    begin
      tempfile.binmode
      @io.rewind if @io.respond_to?(:rewind)
      IO.copy_stream(@io, tempfile)
      tempfile.close
      yield tempfile.path
    ensure
      tempfile.close unless tempfile.closed?
      tempfile.unlink
    end
  end

  def extract_title(epub)
    epub.metadata.title.to_s.strip.presence || "Untitled"
  end

  def extract_author(epub)
    creator = epub.metadata.creators.first
    creator&.to_s&.strip.presence
  end

  def extract_description(epub)
    description = epub.metadata.description.to_s.strip
    return nil if description.blank?

    # Strip HTML tags for plain text description
    ActionController::Base.helpers.strip_tags(description).strip.presence
  end

  def extract_publisher(epub)
    publisher = epub.metadata.publishers.first
    publisher&.to_s&.strip.presence
  end

  def extract_isbn(epub)
    isbn_identifier = epub.metadata.identifiers.find { |id| id.scheme&.to_s&.upcase == "ISBN" }
    isbn_identifier&.to_s&.strip.presence
  end

  def extract_language(epub)
    language = epub.metadata.languages.first
    language&.to_s&.strip.presence || "en"
  end

  def extract_date(epub)
    date_string = epub.metadata.date&.to_s
    return nil if date_string.blank?

    Date.parse(date_string)
  rescue ArgumentError
    nil
  end

  def extract_cover_image(epub, metadata)
    cover = epub.cover_image
    return unless cover

    cover_data = cover.read
    return if cover_data.nil? || cover_data.empty?

    metadata[:cover_image_data] = {
      io: StringIO.new(cover_data),
      filename: File.basename(cover.href),
      content_type: cover.media_type.to_s
    }
  rescue StandardError
    # Cover extraction failed, continue without cover
    nil
  end
end

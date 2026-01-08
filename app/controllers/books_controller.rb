class BooksController < ApplicationController
  def index
    @books = Book.recent.with_attached_file.with_attached_cover_image
  end

  def show
    @book = Book.find(params[:id])
  end

  def download
    @book = Book.find(params[:id])

    if @book.file.attached?
      redirect_to rails_blob_path(@book.file, disposition: "attachment"), allow_other_host: true
    else
      redirect_to @book, alert: "File not found"
    end
  end

  def new
    @book = Book.new
  end

  def create
    @book = Book.new(book_params)
    @book.file_type = detect_file_type(@book.file)
    @book.file_size = @book.file.byte_size if @book.file.attached?

    if @book.save
      # Extract metadata in background job for EPUBs
      ExtractBookMetadataJob.perform_later(@book.id) if @book.epub?
      redirect_to books_path, notice: "Book uploaded successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @book = Book.find(params[:id])
    @book.destroy
    redirect_to books_path, notice: "Book deleted successfully"
  end

  private

  def book_params
    params.require(:book).permit(:title, :author, :description, :file)
  end

  def detect_file_type(file)
    return nil unless file.attached?

    case file.content_type
    when "application/epub+zip"
      "epub"
    when "application/pdf"
      "pdf"
    else
      # Fallback to filename extension
      extension = File.extname(file.filename.to_s).downcase
      extension == ".epub" ? "epub" : "pdf"
    end
  end
end

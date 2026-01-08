class BooksController < ApplicationController
  before_action :set_book, only: [:show, :download, :edit, :update, :destroy]
  before_action :authorize_owner!, only: [:edit, :update, :destroy]

  def index
    @books = Book.all

    # Search by title or author
    if params[:query].present?
      @books = @books.where(
        "title LIKE :query OR author LIKE :query",
        query: "%#{params[:query]}%"
      )
    end

    # Filter by file type
    if params[:type].present? && params[:type].in?(%w[epub pdf])
      @books = @books.where(file_type: params[:type])
    end

    # Sort
    @books = case params[:sort]
    when "title"
      @books.by_title
    when "author"
      @books.by_author
    else
      @books.recent
    end

    @books = @books.with_attached_file.with_attached_cover_image
  end

  def show
  end

  def download
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
    @book = current_user.books.build(book_params)
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

  def edit
  end

  def update
    if @book.update(book_params)
      redirect_to @book, notice: "Book updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @book.destroy
    redirect_to books_path, notice: "Book deleted successfully"
  end

  private

  def set_book
    @book = Book.find(params[:id])
  end

  def authorize_owner!
    unless @book.owned_by?(current_user)
      redirect_to books_path, alert: "You are not authorized to perform this action"
    end
  end

  def book_params
    params.require(:book).permit(:title, :author, :description, :file, :cover_image)
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

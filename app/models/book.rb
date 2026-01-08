class Book < ApplicationRecord
  has_one_attached :file
  has_one_attached :cover_image

  validates :title, presence: true
  validates :file_type, inclusion: { in: %w[epub pdf], allow_nil: true }

  scope :epubs, -> { where(file_type: "epub") }
  scope :pdfs, -> { where(file_type: "pdf") }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_title, -> { order(:title) }
  scope :by_author, -> { order(:author, :title) }

  def display_author
    author.presence || "Unknown Author"
  end

  def display_title
    title.presence || "Untitled"
  end

  def epub?
    file_type == "epub"
  end

  def pdf?
    file_type == "pdf"
  end
end

class Book < ApplicationRecord
  has_one_attached :file
  has_one_attached :cover_image

  belongs_to :user, optional: true

  validates :title, presence: true
  validates :file_type, inclusion: { in: %w[epub pdf], allow_nil: true }
  validate :acceptable_file

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

  def owned_by?(user)
    self.user_id == user&.id
  end

  def uploader_name
    user&.email || "Unknown"
  end

  private

  def acceptable_file
    return unless file.attached?

    unless file.content_type.in?(%w[application/epub+zip application/pdf])
      errors.add(:file, "must be an EPUB or PDF file")
    end

    if file.byte_size > 100.megabytes
      errors.add(:file, "is too large (maximum is 100 MB)")
    end
  end
end

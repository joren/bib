class Books::UploadFormComponent < ViewComponent::Base
  def initialize(book:)
    @book = book
  end
end

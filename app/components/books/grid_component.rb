class Books::GridComponent < ViewComponent::Base
  def initialize(books:)
    @books = books
  end
end

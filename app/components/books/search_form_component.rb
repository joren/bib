class Books::SearchFormComponent < ViewComponent::Base
  def initialize(query: nil, type: nil, sort: nil)
    @query = query
    @type = type
    @sort = sort
  end
end

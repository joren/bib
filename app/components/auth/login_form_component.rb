class Auth::LoginFormComponent < ViewComponent::Base
  def initialize(email: nil)
    @email = email
  end
end

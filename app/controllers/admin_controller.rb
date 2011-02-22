#Verifies that user is an admin before allowing account and user creation
class AdminController < ApplicationController
  before_filter :authenticate_user!
  before_filter :check_role

  protected

  def check_role
    if current_user.admin? == false
      flash['alert'] = "You must be an admin to access that page."
      redirect_to '/'
    end
  end
end

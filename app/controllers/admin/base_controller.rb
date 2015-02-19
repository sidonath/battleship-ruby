class Admin::BaseController < ApplicationController
  before_action :reject_non_admins

  private

  def reject_non_admins
    redirect_to root_path unless current_user.admin?
  end
end

class Admin::UsersController < Admin::BaseController
  def index
    @users = User.where("role IS NULL OR role <> 'admin'")
    @shuffled_users = @users.shuffle
    @pairs = @shuffled_users.each_slice(2).to_a
  end
end

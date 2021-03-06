class UsersController < ApplicationController
before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :following, :followers]
before_action :correct_user,   only: [:edit, :update]
before_action :admin_user,     only: :destroy

  def index
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
      render 'new'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
    redirect_to root_url and return unless @user.activated?
  end

  def edit
    
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def following
    @title = "Following"
    @user  = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow'
  end

  def followers
    @title = "Followers"
    @user  = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  def auto_complete
    @users = if params[:term].match(/(@[^\s]+)/)
      user_name = Micropost.get_user_name(params[:term])
      users = User.select('user_name').where('user_name LIKE ? AND activated = ?', "%#{user_name[-1]}%", true).limit(20)
      puts users

      users.map {|user| {user_name: " @#{user.user_name} "} }
    end
    render json: @users.to_json
  end

  def taken_user_name
    user_name = params[:user_name]
    if found = User.find_by(user_name: params[:user_name])
      render json: {status: 200,data: found.user_name}
    else
      render json: {status: 404,data: ""}
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :user_name, :password, :password_confirmation)
    end

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end

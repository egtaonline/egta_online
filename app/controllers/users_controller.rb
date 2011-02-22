class UsersController < AdminController
  before_filter :find_user, :except => [:index, :new, :create]

  def index
    @users = User.paginate :per_page=>15, :page=>(params[:page] || 1)
  end

  def show
  end

  def new
    @user = User.new
  end

  def edit
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = 'User was successfully created.'
      redirect_to @user
    else
      render :action => "new"
    end
  end

  def update
    if @user.update_attributes(params[:user])
      flash[:notice] = 'User was successfully updated.'
      redirect_to @user
    else
      render :action => "edit"
    end
  end

  def destroy
    @user.destroy

    redirect_to users_url
  end

  protected

  def find_user
    @user = User.find(params[:id])
  end
end

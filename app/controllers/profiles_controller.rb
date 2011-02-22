class ProfilesController < GameDescendentsController

  def index
    @profiles = @game.profiles.paginate :per_page => 15, :page => (params[:page] || 1)
  end

  def show
    @profile = @game.profiles.find(params[:id])
    @account_options = Account.all.collect {|s| [s.name, s.id]}
  end

  def destroy
    @game.profiles.find(params[:id]).destroy
    redirect_to(:action => "index")
  end
end

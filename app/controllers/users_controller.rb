class UsersController < ApplicationController
  include Databasedotcom::Rails::Controller
  before_filter :verify_configuration
  
  def index
    @users = User.all
  end

  def new
    @user = User.new "ProfileId" => Profile.first.Id
  end

  def create
    User.create User.coerce_params(params[:user])
    redirect_to users_path
  end

  private
  
  def verify_configuration
    redirect_to config_warning_path unless File.exist?(File.join(Rails.root, 'config', 'databasedotcom.yml'))
  end
end

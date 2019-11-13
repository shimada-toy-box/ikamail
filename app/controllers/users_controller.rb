class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update]
  before_action :authorize_user, only: [:index]

  # GET /users
  # GET /users.json
  def index
    @users = policy_scope(User).order(:username).page(params[:page])
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if current_user == @user
        format.html { redirect_to admin_users_path, alert: t(:cannot_modify_own, scope: :messages)}
        format.json { render json: {erros: t(:cannot_modify_own, scope: :messages)}, status: :unprocessable_entity }
      elsif @user.update(user_params)
        format.html { redirect_to admin_users_path, notice: t_success_action(@user, :update) }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { redirect_to admin_users_path, alert: t_failure_action(@user, :update)  }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user =
        if params[:id]
          User.find(params[:id])
        else
          current_user
        end
      authorize @user
    end

    def authorize_user
      authorize User
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:role)
    end
end

class InternalApi::UsersController < InternalApi::ApplicationController
  before_action :authenticate_user, except: [:models, :datasets, :codes, :spaces]

  def index
    users = User.where("name ~* ?", params[:name])
    render json: {users: users.as_json}
  end

  def update
    current_user.name = user_params[:name]
    current_user.nickname = user_params[:nickname]
    current_user.email = user_params[:email]
    if user_params[:avatar].present?
      avatar_url_code = AwsS3.instance.upload 'user-avatar', user_params[:avatar]
      current_user.avatar = avatar_url_code
    end
    if current_user.save
      render json: {message: '用户更新成功'}
    else
      render json: {message: current_user.errors.full_messages.to_sentence}, status: 500
    end
  end

  def models
    render json: Starhub.api.get_user_models(params[:namespace], current_user&.name, { per: params[:per] })
  end

  def datasets
    render json: Starhub.api.get_user_datasets(params[:namespace], current_user&.name, { per: params[:per] })
  end

  def spaces
    render json: Starhub.api.get_user_application_spaces(params[:namespace], current_user&.name, { per: params[:per] })
  end

  def codes
    render json: Starhub.api.get_user_codes(params[:namespace], current_user&.name, { per: params[:per] })
  end

  private

  def user_params
    params.permit(:name, :nickname, :avatar, :email)
  end
end

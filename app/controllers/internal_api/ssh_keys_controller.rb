class InternalApi::SshKeysController < InternalApi::ApplicationController
  def create
    res = csghub_api.create_ssh_key(current_user.name, params[:name], params[:ssh_key])
    raise StarhubError, res.body unless res.success?
    render json: { message: I18n.t('repo.createSuccess') }
  end

  def destroy
    res = csghub_api.delete_ssh_key(current_user.name, params[:id])
    raise StarhubError, res.body unless res.success?
    render json: {message: I18n.t('repo.delSuccess')}
  end

  private

  def create_params
    params.permit(:name, :ssh_key)
  end
end

class InternalApi::ApplicationSpacesController < InternalApi::ApplicationController
  before_action :authenticate_user, except: [:index, :files, :readme]

  include Api::SyncStarhubHelper
  include Api::BuildCommitHelper
  include Api::FileOptionsHelper
  include Api::RepoValidation

  def index
    res_body = csghub_api.get_application_spaces(current_user&.name,
                                                                     params[:search],
                                                                     params[:sort],
                                                                     params[:task_tag],
                                                                     params[:framework_tag],
                                                                     params[:license_tag],
                                                                     params[:page],
                                                                     params[:per_page])
    api_response = JSON.parse(res_body)
    render json: { spaces: api_response['data'], total: api_response['total'] }
  end

  def files
    last_commit, files = csghub_api.get_application_space_detail_files_data_in_parallel(params[:namespace], params[:application_space_name], files_options)
    last_commit_user = User.find_by(name: JSON.parse(last_commit)["data"]["committer_name"])
    render json: { last_commit: JSON.parse(last_commit)['data'], files: JSON.parse(files)['data'], last_commit_user: last_commit_user }
  end

  def readme
    readme = csghub_api.get_application_space_file_content(params[:namespace], params[:application_space_name], 'README.md', {current_user: current_user&.name})
    readme_content = JSON.parse(readme)['data']
    readme_content = relative_path_to_resolve_path 'application_space', readme_content
    render json: { readme: readme_content }
  rescue StarhubError
    render json: { readme: '' }
  end

  def create
    application_space = current_user.created_application_spaces.build(create_params)
    if application_space.save
      render json: { path: application_space.path, message: I18n.t('application_space.space_created') }, status: :created
    else
      render json: { message: application_space.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end

  def update
    if params[:private].to_s.present?
      @application_space.visibility = params[:private].to_s == 'true' ? 'private' : 'public'
    end

    @application_space.nickname = params[:nickname] if params[:nickname].present?
    @application_space.desc = params[:desc] if params[:desc].present?
    @application_space.cloud_resource = params[:cloud_resource] if params[:cloud_resource].present?

    if @application_space.save
      render json: { message: I18n.t('repo.updateSuccess') }
    else
      render json: { message: I18n.t('repo.updateFailed') }, status: :bad_request
    end
  end

  def destroy
    if @application_space.destroy
      render json: { message: I18n.t('repo.delSuccess') }
    else
      render json: { message: I18n.t('repo.delFailed') }, status: :bad_request
    end
  end

  def create_file
    options = create_file_params.slice(:branch).merge({ message: build_create_commit_message,
                                                        new_branch: 'main',
                                                        username: current_user.name,
                                                        email: current_user.email,
                                                        content: Base64.encode64(params[:content])
                                                      })
    sync_create_file('application_space', options)
    render json: { message: I18n.t('repo.createFileSuccess') }
  end


  def update_file
    options = update_file_params.slice(:branch, :sha).merge({ message: build_update_commit_message,
                                                              new_branch: 'main',
                                                              username: current_user.name,
                                                              email: current_user.email,
                                                              content: Base64.encode64(params[:content])
                                                            })
    sync_update_file('application_space', options)
    render json: { message: I18n.t('repo.updateFileSuccess') }
  end

  def upload_file
    sync_upload_file('application_space', upload_options)
    render json: { message: I18n.t('repo.uploadFileSuccess') }, status: 200
  end

  private

  def create_params
    params.permit(:name, :nickname, :desc, :sdk, :cloud_resource, :owner_id, :owner_type, :visibility, :license, :cover_image)
  end

  def create_file_params
    params.permit(:path, :content, :branch, :commit_title, :commit_desc)
  end

  def update_file_params
    params.permit(:path, :content, :branch, :commit_title, :commit_desc, :sha)
  end
end

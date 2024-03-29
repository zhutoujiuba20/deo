class InternalApi::CodesController < InternalApi::ApplicationController
  before_action :authenticate_user, except: [:index, :files, :readme]

  include Api::SyncStarhubHelper
  include Api::BuildCommitHelper
  include Api::FileOptionsHelper
  include Api::RepoValidation

  def index
    res_body = Starhub.api.get_codes(current_user&.name,
                                     params[:search],
                                     params[:sort],
                                     params[:task_tag],
                                     params[:framework_tag],
                                     params[:license_tag],
                                     params[:page],
                                     params[:per_page])
    api_response = JSON.parse(res_body)
    render json: { codes: api_response['data'], total: api_response['total'] }
  end

  def files
    last_commit, files = Starhub.api.get_code_detail_files_data_in_parallel(params[:namespace], params[:code_name], files_options)
    render json: { last_commit: JSON.parse(last_commit)['data'], files: JSON.parse(files)['data'] }
  end

  def readme
    readme = Starhub.api.get_code_file_content(params[:namespace], params[:code_name], 'README.md')
    readme_content = JSON.parse(readme)['data']
    readme_content = relative_path_to_resolve_path 'code', readme_content
    render json: { readme: readme_content }
  rescue StarhubError
    render json: { readme: '' }
  end

  def create
    code = current_user.created_codes.build(code_params)
    if code.save
      render json: { path: code.path, message: I18n.t('repo.createSuccess') }, status: :created
    else
      render json: { message: code.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end

  def update
    if params[:private].to_s.present?
      @code.visibility = params[:private].to_s == 'true' ? 'private' : 'public'
    end

    @code.nickname = params[:nickname] if params[:nickname].present?
    @code.desc = params[:desc] if params[:desc].present?

    if @code.save
      render json: { message: I18n.t('repo.updateSuccess') }
    else
      render json: { message: I18n.t('repo.updateFailed') }, status: :bad_request
    end
  end

  def destroy
    if @code.destroy
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
    sync_create_file('code', options)
    render json: { message: I18n.t('repo.createFileSuccess') }
  end


  def update_file
    options = update_file_params.slice(:branch, :sha).merge({ message: build_update_commit_message,
                                                        new_branch: 'main',
                                                        username: current_user.name,
                                                        email: current_user.email,
                                                        content: Base64.encode64(params[:content])
                                                      })
    sync_update_file('code', options)
    render json: { message: I18n.t('repo.updateFileSuccess') }
  end

  def upload_file
    file = params[:file]
    options = {
      branch: 'main',
      file_path: file.original_filename,
      file: Multipart::Post::UploadIO.new(file.tempfile.path, file.content_type),
      email: current_user.email,
      message: build_upload_commit_message,
      username: current_user.name
    }
    sync_upload_file('code', options)
    render json: { message: I18n.t('repo.uploadFileSuccess') }, status: 200
  end

  private

  def code_params
    params.permit(:name, :nickname, :desc, :owner_id, :owner_type, :visibility, :license)
  end

  def create_file_params
    params.permit(:path, :content, :branch, :commit_title, :commit_desc)
  end

  def update_file_params
    params.permit(:path, :content, :branch, :commit_title, :commit_desc, :sha)
  end
end

class ModelsController < ApplicationController
  include TagListHelper
  include LicenseListHelper
  include LocalRepoValidation
  include FileOptionsHelper
  include BlobContentHelper

  layout 'new_application'

  before_action :check_user_info_integrity
  before_action :authenticate_user, only: [:new, :new_file, :upload_file, :edit_file]
  before_action :load_branch_and_path, only: [:files, :blob, :new_file, :upload_file, :resolve, :edit_file]
  before_action :load_model_detail, only: [:show, :files, :blob, :new_file, :upload_file, :edit_file]

  def index
    get_tag_list('models')
  end

  def new
    @available_namespaces = current_user.available_namespaces
    get_license_list
  end

  def show
    @default_tab = 'summary'
  end

  def files
    render :show
  end

  def blob
    render :show
  end

  def resolve
    if params[:download] == 'true'
      if params[:lfs] == 'true'
        file_url = Starhub.api.download_model_file(params[:namespace],
                                                   params[:model_name],
                                                   params[:lfs_path],
                                                   { ref: @current_branch,
                                                     lfs: true,
                                                     save_as: @current_path})
        redirect_to JSON.parse(file_url)['data'], allow_other_host: true
      else
        file = Starhub.api.download_model_file(params[:namespace],
                                               params[:model_name],
                                               @current_path,
                                               { ref: @current_branch })
        send_data file, filename: @current_path
      end
    else
      content_type = helpers.content_type_format_mapping[params[:format]] || 'text/plain'
      if ['jpg', 'png', 'jpeg', 'gif', 'svg'].include? params[:format]
        result = Starhub.api.download_model_resolve_file(params[:namespace],
                                                         params[:model_name],
                                                         @current_path,
                                                         { ref: @current_branch })
        send_data result, type: content_type, disposition: 'inline'
      else
        result = Starhub.api.get_model_file_content(params[:namespace],
                                                    params[:model_name],
                                                    @current_path,
                                                    { ref: @current_branch })
        render plain: JSON.parse(result)['data']
      end
    end
  end

  def upload_file
    render :show
  end

  def new_file
    render :show
  end

  def edit_file
    render :show
  end

  private

  def load_model_detail
    return if action_name == 'blob' && params[:download] == 'true'

    if action_name == 'blob' || action_name == 'edit_file'
      @model, @last_commit, @branches, @blob = Starhub.api.get_model_detail_blob_data_in_parallel(params[:namespace], params[:model_name], files_options)
      update_blob_content('model')
    else
      @model, @branches = Starhub.api.get_model_detail_data_in_parallel(params[:namespace], params[:model_name], files_options)
    end

    @tags_list = Tag.where(scope: 'model', tag_type: 'task').as_json
    @tags = Tag.build_detail_tags(JSON.parse(@model)['data']['tags'], 'model').to_json
    @settings_visibility = current_user ? current_user.can_manage?(@local_model) : false
  end
end

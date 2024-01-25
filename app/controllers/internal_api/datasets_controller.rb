class InternalApi::DatasetsController < InternalApi::ApplicationController
  before_action :authenticate_user, except: [:index, :files]
  before_action :validate_authorization, only: :files

  def index
    res_body = Starhub.api.get_datasets(current_user&.name,
                                        params[:search],
                                        params[:sort],
                                        params[:task_tag],
                                        params[:framework_tag],
                                        params[:license_tag],
                                        params[:page],
                                        params[:per_page])
    api_response = JSON.parse(res_body)
    render json: {datasets: api_response['data'], total: api_response['total']}
  end

  def files
    last_commit, files = Starhub.api.get_dataset_detail_files_data_in_parallel(params[:namespace], params[:dataset_name], files_options)
    render json: { last_commit: JSON.parse(last_commit)['data'], files: JSON.parse(files)['data'] }
  end

  def create
    res = validate_owner
    if !res[:valid]
      return render json: { message: res[:message] }, status: :unprocessable_entity
    end
    dataset = current_user.created_datasets.build(dataset_params)
    if dataset.save
      render json: { path: dataset.path, message: '数据集创建成功!' }, status: :created
    else
      render json: { message: dataset.errors.full_messages.to_sentence }, status: :unprocessable_entity
    end
  end

  def destroy
    owner = User.find_by(name: params[:namespace]) || Organization.find_by(name: params[:namespace])
    @dataset = owner && owner.datasets.find_by(name: params[:dataset_name])

    unless @dataset
      return render json: { message: "未找到对应数据集" }, status: 404
    end

    unless current_user.can_manage?(@dataset)
      render json: { message: '无权限' }, status: :unauthorized
      return
    end

    if @dataset.destroy
      render json: { message: '删除成功' }
    else
      render json: { message: "删除 #{params[:namespace]}/#{params[:dataset_name]} 失败" }, status: :bad_request
    end
  end

  private

  def dataset_params
    params.permit(:name, :owner_id, :owner_type, :license)
  end

  def validate_owner
    if params[:owner_type] == 'User' && current_user.id.to_i != params[:owner_id].to_i
      return { valid: false, message: '用户不存在' }
    elsif params[:owner_type] == 'Organization'
      org = current_user.organizations.find_by(id: params[:owner_id])
      if !org || current_user.org_role(org) == 'read'
        return { valid: false, message: '组织不存在或无权限' }
      end
    end
    { valid: true }
  end

  def files_options
    {
      ref: params[:branch],
      path: params[:path]
    }
  end

  def validate_authorization
    owner = find_user_or_organization_by_name(params[:namespace])
    local_dataset = find_dataset_by_owner_and_name(owner, params[:dataset_name])

    return render_unauthorized('数据集不存在') unless local_dataset

    return render_unauthorized('无权限') unless valid_authorization?(local_dataset)
  end

  def find_user_or_organization_by_name(name)
    User.find_by(name: name) || Organization.find_by(name: name)
  end

  def find_dataset_by_owner_and_name(owner, dataset_name)
    owner&.datasets&.find_by(name: dataset_name)
  end

  def valid_authorization?(dataset)
    return true if dataset.dataset_public?

    return false unless helpers.logged_in?

    if dataset.owner.instance_of?(User)
      return dataset.owner == current_user
    end

    return current_user.org_role(dataset.owner)
  end

  def render_unauthorized(message)
    render json: { message: message }, status: :unauthorized
  end
end

module LocalRepoValidation
  extend ActiveSupport::Concern

  private

  def local_repo_validation
    get_owner_info
    type = controller_name
    local_repo = get_local_repo(type)

    unless local_repo
      return redirect_to errors_not_found_path
    end

    if local_repo.send("#{type.singularize}_private?")
      if local_repo.owner.instance_of? User
        return redirect_to errors_unauthorized_path if local_repo.owner != current_user
      else
        return redirect_to errors_unauthorized_path unless current_user.org_role(local_repo.owner)
      end
    end
  end

  def get_owner_info
    @owner = User.find_by(name: params[:namespace]) || Organization.find_by(name: params[:namespace])
    @owner_url = helpers.code_repo_owner_url @owner
    @avatar_url = @owner.avatar_url
  end

  def get_local_repo(type)
    case type
    when 'models'
      @local_model = @owner && @owner.models.find_by(name: params[:model_name])
    when 'datasets'
      @local_dataset = @owner && @owner.datasets.find_by(name: params[:dataset_name])
    end
  end
end
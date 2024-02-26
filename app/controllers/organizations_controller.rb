class OrganizationsController < ApplicationController
  before_action :check_user_info_integrity
  before_action :authenticate_user, except: [:show]

  def edit
    @organization = Organization.find_by(name: params[:id])
    authorize @organization
  end

  def new
  end

  def show
    @organization = Organization.find_by(name: params[:id])
    unless @organization
      flash[:alert] = "未找到对应的组织"
      return redirect_to errors_not_found_path
    end
    user_org_role = current_user && current_user.org_role(@organization)
    @admin = user_org_role == 'admin'
    @members = @organization.members
    @models = Starhub.api.get_org_models(@organization.name, current_user&.name)
    @datasets = Starhub.api.get_org_datasets(@organization.name, current_user&.name)
  end
end

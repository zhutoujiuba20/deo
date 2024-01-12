require "administrate/base_dashboard"

class SystemConfigDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    application_env: Field::String,
    oidc_configs: Field::JSONB,
    starhub_configs: Field::JSONB,
    license_configs: Field::JSONB,
    feature_flags: Field::JSONB,
    general_configs: Field::JSONB,
    s3_configs: Field::JSONB,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    id
    application_env
    created_at
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    application_env
    general_configs
    oidc_configs
    starhub_configs
    license_configs
    feature_flags
    s3_configs
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    application_env
    general_configs
    oidc_configs
    starhub_configs
    license_configs
    feature_flags
    s3_configs
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { resources.where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how system configs are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(system_config)
  #   "SystemConfig ##{system_config.id}"
  # end
end

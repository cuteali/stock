class RegistrationsController < Devise::RegistrationsController
  skip_before_action :require_no_authentication, only: [:new, :create]

  # POST /resource
  def create
    build_resource(sign_up_params)

    resource.save
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}"
      end
      redirect_to admin_members_path
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
  end
end
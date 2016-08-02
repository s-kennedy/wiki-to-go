class RegistrationsController < Devise::RegistrationsController  
  respond_to :json

  def create
    build_resource(sign_up_params)

    resource.save
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        sign_up(resource_name, resource)
        render json: { user: resource, status: :success }
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        render json: { user: resource, message: resource.inactive_message, status: :success }
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      render json: { user: resource, status: :unprocessable_entity }
    end
  end

  def update
    self.resource = resource_class.to_adapter.get!(send(:"current_#{resource_name}").to_key)
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)

    resource_updated = update_resource(resource, account_update_params)
    yield resource if block_given?
    if resource_updated
      # bypass_sign_in resource, scope: resource_name
      render json: { user: resource, status: :success }
    else
      clean_up_passwords resource
      render json: { 
        user: resource, 
        status: :unprocessable_entity, 
        message: resource.errors.full_messages 
      }
    end
  end


  def destroy
    resource.destroy
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    yield resource if block_given?
    # respond_with_navigational(resource){ redirect_to after_sign_out_path_for(resource_name) }
    render json: { user: resource, status: :success }
  end

  private

  def sign_up_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation)
  end

  def account_update_params
    params.require(:user).permit(:first_name, :last_name, :email, :password, :password_confirmation, :current_password)
  end

end  
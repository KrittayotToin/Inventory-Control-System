class OmniauthCallbacksController < ApplicationController
    def facebook
        # Handle Facebook authentication callback here
        # You can access the user information using request.env['omniauth.auth']
        # Example:

        Rails.logger.debug ("Omniauth callback triggered").blue
        @user = User.from_omniauth(request.env['omniauth.auth'])
    
        if @user.persisted?
          # sign_in_and_redirect @user, event: :authentication
          sign_in_and_redirect @user, :event => :authentication #this will throw if @user is not activated
          set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
        else
          session["devise.facebook_data"] = request.env["omniauth.auth"]
          redirect_to new_user_registration_url
          # redirect_to new_user_registration_url
        end
      end
    
      def failure
        # Logic for handling failed authentication
        Rails.logger.debug ("Omniauth callback triggered").blue
        flash[:alert] = "Authentication failed. Please try again."
        redirect_to root_path
      end
end

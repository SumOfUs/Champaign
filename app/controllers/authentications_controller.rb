class AuthenticationsController < Devise::OmniauthCallbacksController
  def google_oauth2
    # we override the devise mapping because routing sets it to user
    request.env["devise.mapping"] = Devise.mappings[session[:authenticating].to_sym]

    @user = ConnectWithOauthProvider.connect(request.env["omniauth.auth"])

    flash[:notice] = I18n.t "devise.omniauth_callbacks.success", kind: "Google"
    sign_in_and_redirect @user, event: :authentication
  rescue Champaign::NotWhitelisted
    redirect_to new_user_session_path, flash: {error: t('oauth.not_authorised')}
  end

  def user_passthru
    session[:authenticating] = 'user'
    redirect_to "/auth/#{params[:provider]}"
  end

  def member_passthru
    session[:authenticating] = 'member'
    redirect_to "/auth/#{params[:provider]}"
  end

  def failure
    # this is mostly a standin and needs some work
    redirect_to new_user_session_path, flash: {error: error_message}
    redirect_to after_omniauth_failure_path_for(resource_name)
  end
end

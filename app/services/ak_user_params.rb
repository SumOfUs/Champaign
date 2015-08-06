require 'browser'

class AkUserParams
  def self.create(params)
  # I'm assuming that the form params will come in with names that correspond to the AK API:
    # akid
    # email
    # name
      # name gets split to prefix, first name, middle name, last name and suffix automagically by AK ...
    # address1
    # address2
    # city
    # state
    # zip
    # postal
    # country
    # region
    # phone
    # mailing_id
    # id
    # plus4
    # lang - get from current page session
    # source - fwd, fb, tw, pr, mtl, taf
    @user_params = params[:signature]
    @user_params[:user_agent] = browser.user_agent
    @user_params[:browser_detected] = browser.known?
    @user_params[:mobile] = browser.mobile?
    @user_params[:tablet] = browser.tablet?
    @user_params[:platform] = browser.platform

    @user_params
  end
end
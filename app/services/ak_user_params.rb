require 'browser'

class AkUserParams
  def self.create(params, browser)
  # I'm assuming that the form params will come with a field called signature
  # that will contain the petition form data with names that correspond to the AK API:
    # USER:
    # akid
    # email
    # prefix
    # suffix
    # name
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

  # PETITION ACTION:
    # action_ptr - Action
    # created_at - DateTimeField
    # created_user - BooleanField
    # id - AutoField
    # ip_address - CharField
    # is_forwarded - BooleanField
    # link - IntegerField
    # mailing - Mailing
    # opq_id - CharField
    # page - Page
    # referring_mailing - Mailing
    # referring_user - User
    # source - CharField
    # status - CharField
    # subscribed_user - BooleanField
    # taf_emails_sent - IntegerField
    # targeted - Target (ManyToManyField)
    # updated_at - DateTimeField
    # user - User
    @user_params = params[:signature]
    @user_params.merge({
                           user_agent: browser.user_agent,
                           browser_detected: browser.known?,
                           mobile: browser.mobile?,
                           tablet: browser.tablet?,
                           platform: browser.platform

                       })
    @user_params
  end
end

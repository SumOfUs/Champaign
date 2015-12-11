class ManageDonation
  def self.create(params)
    new(params).create
  end

  def self.format_params(user_email:, user_country:, page_id:, amount:, exp_date:, card_num: '4111111111111111', additional_options = {})
    page = Page.find(page_id)
    result = {}
    result[:donationpage] = {
        page: [page.slug, 'donation'].join('-'),
        payment_account: 'Default Import Stub'
    }

    result[:user] = {
        email: user_email,
        country: user_country
    }

    exp_date_month, exp_date_year = exp_date.split('/')
    result[:order] = {
        amount: amount,
        card_num: card_num,
        card_code: '007',
        exp_date_month: exp_date_month,
        exp_date_year: exp_date_year
    }
    result.merge(additional_options)
  end

  def initialize(params)
    @params = params
  end

  def create
    ChampaignQueue.push(queue_message)
  end

  private
  def queue_message
    {
        type: 'donation',
        params: @params
    }
  end
end

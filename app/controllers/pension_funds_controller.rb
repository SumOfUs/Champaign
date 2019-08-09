class PensionFundsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_pension_fund, only: %i[edit update]

  def index
    @pension_funds = PensionFund.list(params).sorted
  end

  def new
    @pension_fund = PensionFund.new
  end

  def create
    @pension_fund = PensionFund.new pension_fund_params
    if @pension_fund.save
      redirect_to pension_funds_url(country_code: params[:country_code]),
                  notice: t('pension_funds.create.notice')
    else
      render :new
    end
  end

  def export
    if params[:country_code].present?
      data = PensionFund.filter_by_country_code(params['country_code']).to_json(except: 'id')
      send_data data, type: 'application/json; header=present',
                      disposition: "attachment; filename=pension-funds-#{params[:country_code]}.json"
    else
      redirect_to pension_funds_url
    end
  end

  def upload
    @pension_funds = []
    render('upload') && return unless request.post?

    uploaded_file = params[:json_file]
    @json_importer = PensionFundsJsonImporter.new(uploaded_file, params[:country_code])

    if @json_importer.import
      redirect_to pension_funds_url, notice: t('pension_funds.upload.notice')
    else
      render :upload
    end
  end

  def edit
    # Intentionally left blank.
  end

  def update
    if @pension_fund.update pension_fund_params
      redirect_to pension_funds_url(country_code: params[:country_code]),
                  notice: t('pension_funds.update.notice')
    else
      render :edit
    end
  end

  private

  def pension_fund_params
    params.require(:pension_fund).permit(:fund, :name, :email, :country_code, :active)
  end

  def set_pension_fund
    @pension_fund = PensionFund.find(params[:id])
  end
end

class ShareProgressVariantBuilder
  def self.create(params, variant_type:, campaign_page:, url:)
    new(params, variant_type, campaign_page, url).create
  end

  def self.update(params, variant_type:, campaign_page:, url:, id:)
    new(params, variant_type, campaign_page, url, id).update
  end

  def initialize(params, variant_type, campaign_page, url, id = nil)
    @params = params
    @campaign_page = campaign_page
    @variant_type = variant_type.to_s
    @url = url
    @id = id
  end

  def update
    variant = variant_class.find(@id)
    variant.update(@params)

    return variant unless variant.valid?

    button = Share::Button.find_by(sp_type: @variant_type, campaign_page_id: @campaign_page.id)
    ShareProgress::Button.new( share_progress_button_params(variant, button) ).save
    variant
  end

  def create
    variant = variant_class.new(@params)
    variant.campaign_page = @campaign_page
    variant.save

    return variant unless variant.valid?

    button = Share::Button.find_or_create_by(sp_type: @variant_type, campaign_page_id: @campaign_page.id)
    opts = share_progress_button_params(variant, button)
    pp opts
    pp "OPTS ABOVE"
    sp_button = ShareProgress::Button.new( opts ).save
    button.update(sp_id: sp_button.id, sp_button_html: sp_button.share_button_html) unless button.sp_id
    pp sp_button.variants[@variant_type].last['id']
    pp "ID ABOVE"
    variant.update(sp_id:  sp_button.variants[@variant_type].last['id'])

    variant
  end

  private

  def share_progress_button_params(variant, button)
    {
      page_url: @url,
      button_template: "sp_#{variant_initials}_large",
      page_title: "#{@campaign_page.title} [#{@variant_type}]",
      variants: send("#{@variant_type}_variants", variant),
      id: button.sp_id
    }
  end

  def facebook_variants(variant)
    {
      facebook: [
        {
          facebook_title: variant.title,
          facebook_description: variant.description,
          facebook_thumbnail: variant.image(:facebook),
          id: variant.sp_id
        }
      ]
    }
  end


  def twitter_variants(variant)
    {
      twitter: [
        {
          twitter_message: variant.description,
          id: variant.sp_id
        }
      ]
    }
  end

  def email_variants(variant)
    {
      email: [
        {
          email_subject: variant.subject,
          email_body: variant.body,
          id: variant.sp_id
        }
      ]
    }
  end

  def variant_class
    "Share::#{@variant_type.to_s.classify}".constantize
  end

  def variant_initials
    {
      facebook: 'fb',
      twitter:  'tw',
      email:    'em'
    }[@variant_type.to_sym]
  end
end


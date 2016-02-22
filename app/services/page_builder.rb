class PageBuilder
  attr_reader :params

  class << self
    def create(params)
      new(params).save_and_enqueue
    end
  end

  def initialize(params)
    @params = params
  end

  def save_and_enqueue
    set_follow_up_plan
    QueueManager.push(page, job_type: :create) if page.save
    page
  end

  private

  def page
    @page ||= Page.new(@params)
  end

  def set_follow_up_plan
    follow_up_layout = page.liquid_layout.default_follow_up_layout
    if not follow_up_layout.blank?
      page.follow_up_liquid_layout = follow_up_layout
    end
  end

end


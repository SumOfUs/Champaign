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
    QueueManager.push(page, job_type: :create) if page.save
    page
  end

  private

  def page
    @page ||= Page.new(@params)
  end
end


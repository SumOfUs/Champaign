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
    push_to_queue if page.save
    page
  end

  private

  def page
    @page ||= Page.new(@params)
  end

  def push_to_queue
    ChampaignQueue.push(data_for_queue)
  end

  def data_for_queue
    {
      type: 'create',
      params: {
        slug: page.slug,
        id: page.id,
        title: page.title,
        language_code: page.language.code
      }
    }
  end
end


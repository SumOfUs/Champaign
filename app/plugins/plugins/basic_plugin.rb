module Plugins
  class BasicPlugin
    attr_reader :page

    def initialize(page)
      @page = page
    end

    private

    def data_for_view
    end
  end
end


class PageCloner
  def self.clone!(page)
    new(page).clone!
  end

  def initialize(page)
    @page = page
  end

  def clone!
    cloned_page = @page.dup

    # TODO: I'm thinking to have the user of this API
    # decide what the new title should be and have it
    # passed in to clone! It's not this class' responsibility
    # to do the necessary checks against AK
    cloned_page.title = "#{@page.title} #{Time.now.to_s}"

    cloner(cloned_page) do |clone|
      clone.links
      clone.plugins
      clone.tags
      clone.images
    end

    cloned_page.save
    cloned_page
  end

  private

  def cloner(cloned_page)
    machine = Cloner.new(cloned_page, @page)
    yield(machine)
  end

  class Cloner
    attr_reader :cloned_page, :page

    def initialize(new_page, old_page)
      @cloned_page = new_page
      @page = old_page
    end

    def links
      page.links.each do |link|
        link.dup.tap do |clone|
          clone.page = cloned_page
          clone.save
        end
      end
    end

    def plugins
      page.plugins.each do |plugin|
        plugin.dup.tap do |clone|
          clone.page = cloned_page
          clone.save
        end
      end
    end

    def tags
      page.tags.each do |tag|
        cloned_page.tags << tag
      end
    end

    def images
      if page.primary_image
        cloned_page.update(primary_image: Image.create(content: page.primary_image.content))
      end

      page.images.each do |image|
        Image.create(content: image.content, page: cloned_page)
      end
    end
  end
end

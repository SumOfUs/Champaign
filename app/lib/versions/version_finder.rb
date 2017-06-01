# frozen_string_literal: true

module Versions
  class VersionFinder
    class << self
      def find_versions(model:, id:)
        versioned_models[model.to_sym].find(id.to_i).versions
      end

      def versioned_models
        {
          action: Action,
          actionkit_page: ActionkitPage,
          campaign: Campaign,
          form: Form,
          form_element: FormElement,
          image: Image,
          language: Language,
          link: Link,
          liquid_layout: LiquidLayout,
          liquid_partial: LiquidPartial,
          member: Member,
          page: Page,
          tag: Tag,
          user: User
        }
      end
    end
  end
end

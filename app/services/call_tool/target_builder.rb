module CallTool
  class TargetBuilder
    def self.run(params)
      new(params).run
    end

    def initialize(params)
      params = params.clone
      @country_attrs = params.extract!(:country, :country_name, :country_code)
      @attrs = params.extract!(*CallTool::Target::MAIN_ATTRS)
      @attrs[:fields] = params
    end

    def run
      full_attrs = @attrs.merge(sanitized_country_attrs)
      CallTool::Target.new(full_attrs)
    end

    private

    def sanitized_country_attrs
      Country.build(@country_attrs).to_hash
    end
  end

  class Country
    def self.build(country: nil, country_code: nil, country_name: nil)
      if country_code.present?
        build_from_code(country_code)
      elsif country_name.present?
        build_from_name(country_name)
      elsif country.present?
        build_from_code_or_name(country)
      else
        Country.new(nil, nil).to_hash
      end
    end

    def self.build_from_code(code)
      new(code, ISO3166::Country[code]&.name)
    end

    def self.build_from_name(name)
      iso_country = ISO3166::Country.find_country_by_name(name)
      new(iso_country&.alpha2, iso_country&.name || name)
    end

    def self.build_from_code_or_name(code_or_name)
      if ISO3166::Country[country].present?
        build_from_code(code_or_name)
      else
        build_from_name(code_or_name)
      end
    end

    def initialize(code, name)
      @code = code
      @name = name
    end

    def to_hash
      { country_code: @code, country_name: @name }
    end
  end
end

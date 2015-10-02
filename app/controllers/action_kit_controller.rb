module ActionKit
  LANGUAGE_URI = {
    en: 'https://act.sumofus.org/admin/core/language/100/',
    fr: 'https://act.sumofus.org/admin/core/language/103/',
    de: 'https://act.sumofus.org/admin/core/language/101/',
    es: 'https://act.sumofus.org/admin/core/language/102/'
  }

  module Client
    extend self
    def client(verb, path, params)
      Typhoeus::Request.send(verb,
                             "https://act.sumofus.org/rest/v1/#{path}/",
                             {userpwd: "#{ENV['AK_USERNAME']}:#{ENV['AK_PASSWORD']}"}.merge(params)
                            )
    end

    def get(path, params)
      client('get', path, params)
    end

    def post(path, params)
      client('post', path, params)
    end

    def put(path, params)
      client('put', path, params)
    end
  end

  module PetitionPage
    extend self

    def get(name, limit: 10)
      ActionKit::Client.get('petitionpage', params: {_limit: limit, name: name})
    end

    def create(params)
      ActionKit::Client.post('petitionpage', body: params)
    end

    def update(slug, params)
      ActionKit::Client.put("petitionpage/#{slug}", body: params.to_json)
    end
  end

  module Helper
    extend self

    def check_petition_name_is_available(name)
      resp = ActionKit::PetitionPage.get(name, limit: 1)
      JSON.parse(resp.response_body)['meta']['total_count'] == 0
    end

    def create_petition_page(page_id)
      page = Page.find(page_id)

      params = {
        title: page.title,
        name: page.slug,
        language: ActionKit::LANGUAGE_URI[page.language.code.to_sym],
        tags: page.tags.map(&:actionkit_uri)
      }

      resp = ActionKit::PetitionPage.create(params)
      page.update(status: resp.response_code, messages: resp.response_body)
      page
    end
  end
end

#res = ActionKit::PetitionPage.update('omar-test-aa-00', { title: 'hello', tags: Tag.limit(3).map(&:actionkit_uri).join(',')})

class ActionKitController < ApplicationController
  def check_slug
    valid = ActionKit::Helper.check_petition_name_is_available(params[:slug])

    respond_to do |format|
      format.json { render json: { valid: valid } }
    end
  end

  def create_petition_page
    page = ActionKit::Helper.create_petition_page(params[:id])

    respond_to do |format|
      format.json { render json: page.attributes }
    end
  end

  def check_petition_page_status
    page = Page.find params[:id]

    respond_to do |format|
      format.json { render json: { status: page.status, messages: page.messages } }
    end
  end
end


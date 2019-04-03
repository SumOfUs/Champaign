# frozen_string_literal: true

require 'browser'

class MobileDetector
  def self.detect(browser)
    new(browser).detect
  end

  def initialize(browser)
    @browser = browser
  end

  def detect
    { action_mobile: device }
  end

  private

  def device
    return 'unknown' if @browser.ua.blank?

    if @browser.device.mobile?
      'mobile'
    elsif @browser.device.tablet?
      'tablet'
    else
      'desktop'
    end
  end
end

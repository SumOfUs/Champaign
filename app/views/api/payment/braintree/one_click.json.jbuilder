# frozen_string_literal: true

json.success !@result.is_a?(PaymentProcessor::Exceptions::BraintreePaymentError) && !@result.try(:success).nil? && @result.success?
unless @result.is_a?(PaymentProcessor::Exceptions::BraintreePaymentError) && @result.try(:success).nil?
  json.params @result.params
  json.errors @result.errors
  json.message @result.message
  json.immediate_redonation @result.try(:immediate_redonation)
end

if @result.is_a?(PaymentProcessor::Exceptions::BraintreePaymentError)
  json.errorCode @result
  json.immediate_redonation false
end

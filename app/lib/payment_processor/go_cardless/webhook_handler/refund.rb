# frozen_string_literal: true

module PaymentProcessor
  module GoCardless
    module WebhookHandler
      class Refund
        attr_reader :refund_id

        def initialize(event)
          @event     = event
          @refund_id = event['links']['refund']
        end

        def process
          @resp ||= client.refunds.get(refund_id)
          if record.present?
            record.update_attributes(
              refund: true,
              refunded_at: @resp.created_at,
              refund_transaction_id: @resp.id,
              amount_refunded: (@resp.amount.to_i / 100)
            )
            record.run_refund!
          else
            Rails.logger.info "Unable to find record with gocardless_id: #{payment_id}"
            return true
          end
        end

        def payment_id
          @resp.links.try(:payment)
        end

        def record
          return nil unless payment_id.present?

          @record ||= ::Payment::GoCardless::Transaction.find_by(go_cardless_id: payment_id)
        end

        def client
          @client ||= ::GoCardlessPro::Client.new(access_token: Settings.gocardless.token)
        end
      end
    end
  end
end

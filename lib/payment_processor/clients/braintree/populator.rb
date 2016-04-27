module PaymentProcessor
  module Clients
    module Braintree
      class Populator

        def customer_options
          @customer_options ||= {
            first_name: @user[:first_name] || namesplitter.first_name,
            last_name: @user[:last_name] || namesplitter.last_name,
            email: @user[:email] || ''
          }
        end

        def billing_options
          @billing_options ||= {
            first_name: customer_options[:first_name],
            last_name: customer_options[:last_name]
          }.tap do |options|
            populate( options, :region, [:province, :state, :region])
            populate( options, :company, [:company])
            populate( options, :locality, [:city, :locality])
            populate( options, :postal_code, [:zip, :zip_code, :postal, :postal_code])
            populate( options, :street_address, [:address, :address1, :street_address])
            populate( options, :extended_address, [:apartment, :address2, :extended_address])
            populate( options, :country_code_alpha2, [:country, :country_code, :country_code_alpha2])
          end
        end

        def populate(options, field, pick_from)
          pick_from.each do |key|
            options[field] = @user[key] if @user[key].present?
          end
        end

        def namesplitter
          @splitter ||= NameSplitter.new(full_name: @user[:full_name] || @user[:name])
        end

        def existing_customer
          @existing_customer ||= Payment.customer(@user[:email])
        end

        def success?
          @result.success?
        end

        def error_container
          @result
        end
      end
    end
  end
end
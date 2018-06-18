class MemberExporter
  attr_reader :member

  def self.to_csv(member)
    new(member).to_csv
  end

  def initialize(member)
    @member = member
  end

  def to_csv
    map = {}
    extract_data.each do |category, records|
      map[category] = CSVFormatter.run(Array.wrap(records))
    end
    map
  end

  private

  def extract_data
    data = OpenStruct.new
    data.member = member.attributes
    data.actions = member.actions.includes(:page).map do |action|
      action.attributes.merge(page_slug: action.page.slug)
    end
    data.calls = Call.where(member_id: member.id).map(&:attributes)
    data.authentications = member.authentication&.attributes

    # Braintree
    braintree_customer = member.braintree_customer
    if braintree_customer
      data.braintree_customer = braintree_customer.attributes
      data.braintree_subscriptions = braintree_customer.subscriptions.map(&:attributes)
      data.braintree_payment_methods = braintree_customer.payment_methods.map(&:attributes)
      data.braintree_transactions = braintree_customer.transactions.map(&:attributes)
    end

    # GoCardless
    gc_customers = member.go_cardless_customers.includes(:payment_methods, :transactions, :subscriptions)
    data.go_cardless_customers = gc_customers.map(&:attributes)
    data.go_cardless_payment_methods = gc_customers.map(&:payment_methods).flatten.map(&:attributes)
    data.go_cardless_transactions = gc_customers.map(&:transactions).flatten.map(&:attributes)
    data.go_cardless_subscriptions = gc_customers.map(&:subscriptions).flatten.map(&:attributes)
    data.to_h
  end
end

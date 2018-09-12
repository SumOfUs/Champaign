
class ForgetMember
  attr_reader :member

  def self.forget(member)
    new(member).forget
  end

  def initialize(member)
    @member = member
  end

  def forget
    Member.transaction do
      anonymise_actions
      delete_authentication
      anonymise_braintree_customer
      anonymise_member
    end
  end

  private

  def delete_authentication
    member.authentication&.destroy
  end

  def anonymise_actions
    member.actions.each do |action|
      action.update(form_data: nil)
    end
  end

  def anonymise_braintree_customer
    if member.braintree_customer
      member.braintree_customer.payment_methods.each do |payment|
        payment.update(email: nil)
      end

      member.braintree_customer.update(
        email: nil
      )
    end
  end

  def anonymise_member
    member.update(
      more: nil,
      email: nil,
      actionkit_user_id: nil,
      address1: nil,
      address2: nil,
      postal: nil,
      first_name: nil,
      last_name: nil
    )
  end
end

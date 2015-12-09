class ManageDonation < ManageAction
  private
  def queue_message
    {
        type: 'donation',
        params: @params
    }
  end
end

var CampaignPageClient = {
  update: function(data, success){
    $.ajax({
      dataType: 'json',
      type: 'PUT',
      url: "/campaign_pages/" + window.campaign_page_id + ".json",
      data: { campaign_page: data },
    }).done(success);
  }
};

module.exports = CampaignPageClient;

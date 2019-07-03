import I18n from 'champaign-i18n';

const style = imageUrl => ({
  backgroundImage: `url(${imageUrl})`,
});

const CampaignTile = props => {
  const url = `${props.url}?${props.query}`;
  return (
    <a className="campaign-tile campaign-tile--compact" href={url}>
      <div className="campaign-tile__image" style={style(props.image)}>
        <div className="campaign-tile__overlay">
          {I18n.t('recommend_pages.actions', {
            action_count: props.campaign_action_count,
          })}
        </div>
      </div>
      <div className="campaign-tile__lead">{props.title}</div>
      <div className="campaign-tile__cta campaign-tile__open-cta">
        {I18n.t('recommend_pages.learn_more')} »
      </div>
    </a>
  );
};

export default CampaignTile;

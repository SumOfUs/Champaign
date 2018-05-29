import React from 'react';
import { render } from 'react-dom';
import ComponentWrapper from '../components/ComponentWrapper';
import queryString from 'query-string';

const store = window.champaign.store;

class RecommendPagesView extends React.Component {
  constructor() {
    super();
    this.state = {
      pages: [],
    };
  }

  queryStr() {
    const query = queryString.parse(location.search);
    query.source = 'similar_pages';
    return queryString.stringify(query);
  }

  render() {
    const query = this.queryStr();
    return (
      <div className="campaign-tiles">
        {this.state.pages.map(function(page) {
          return <CampaignTile key={page.id} {...page} query={query} />;
        })}
      </div>
    );
  }

  componentDidMount() {
    fetch(`/api/pages/${this.props.pageId}/similar.json?limit=4`)
      .then(res => res.json())
      .then(
        result => {
          this.setState({
            pages: result,
          });
        },
        error => {
          console.log(`Error: ${error}`);
        }
      );
  }
}

const CampaignTile = props => (
  <a
    className="campaign-tile campaign-tile--compact"
    href={`${props.url}?${props.query}`}
  >
    <div
      className="campaign-tile__image"
      style={{ backgroundImage: `url(${props.image})` }}
    >
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

window.mountRecommendPages = (root, props) => {
  render(
    <ComponentWrapper store={store} locale={props.locale}>
      <RecommendPagesView {...props} />
    </ComponentWrapper>,
    document.getElementById(root)
  );
};

// @flow
import React, { Component } from 'react';
import { render } from 'react-dom';
import queryString from 'query-string';
import I18n from 'champaign-i18n';
import ee from '../shared/pub_sub';
import CampaignTile from '../components/CampaignTile';

class RecommendPagesView extends Component {
  constructor(props) {
    super(props);
    this.state = {
      pages: [],
    };
  }

  queryStr() {
    return queryString.stringify({
      ...queryString.parse(location.search),
      source: 'similar_pages',
    });
  }

  render() {
    return (
      <div className="campaign-tiles">
        {this.state.pages.map(function(page) {
          return (
            <CampaignTile key={page.id} {...page} query={this.queryStr()} />
          );
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

ee.on('champaign:recommend_pages:init', (root: string, props) => {
  render(<RecommendPagesView {...props} />, document.getElementById(root));
});

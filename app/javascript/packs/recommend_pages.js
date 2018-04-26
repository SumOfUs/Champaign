import React, { Component } from 'react';
import { render } from 'react-dom';
import ComponentWrapper from '../components/ComponentWrapper';

const store = window.champaign.store;

class RecommendPagesView extends Component {
  render() {
    console.log(this.props);
    return (
      <h1>Hello</h1>
      // loop through pages (this.state.pages) and build up view
    );
  }

  // https://developers.google.com/web/updates/2015/03/introduction-to-fetch
  componentDidMount() {
    fetch(`/api/pages/${this.props.pageId}/similar.json`).then(resp => {
      console.log(resp);
    });
  }

  // this.setState({pages: resp.pages})
}

window.mountRecommendPages = (root, props) => {
  render(
    <ComponentWrapper store={store} locale="en">
      <RecommendPagesView {...props} />
    </ComponentWrapper>,
    document.getElementById(root)
  );
};

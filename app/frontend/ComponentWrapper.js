/* @flow */
import React, { Component } from 'react';
import { Provider } from 'react-redux';
import { IntlProvider } from 'react-intl';

class ComponentWrapper extends Component {
  props: {
    store: Store;
    children?: React$Element<any>;
  };

  state = {
    language: 'en',
  };

  render() {
    return (
      <Provider store={this.props.store}>
        <IntlProvider locale={'en'}>
          <div className="App">
            {this.props.children}
          </div>
        </IntlProvider>
      </Provider>
    );
  }
}

export default ComponentWrapper;

/* @flow */
import React, { Component } from 'react';
import { Provider } from 'react-redux';
import { IntlProvider } from 'react-intl';
import loadTranslations from './util/TranslationsLoader';

class ComponentWrapper extends Component {
  props: {
    store: Store;
    children?: React$Element<any>;
    locale: string;
  };

  render() {
    return (
      <Provider store={this.props.store}>
        <IntlProvider locale={this.props.locale} messages={ loadTranslations(this.props.locale) }>
          <div className="App">
            {this.props.children}
          </div>
        </IntlProvider>
      </Provider>
    );
  }
}

export default ComponentWrapper;

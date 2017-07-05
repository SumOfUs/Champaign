/* @flow */
import React, { Component } from 'react';
import { Provider } from 'react-redux';
import { IntlProvider, addLocaleData } from 'react-intl';
import loadTranslations from '../util/TranslationsLoader';
import enLocaleData from 'react-intl/locale-data/en';
import deLocaleData from 'react-intl/locale-data/de';
import frLocaleData from 'react-intl/locale-data/fr';
import esLocaleData from 'react-intl/locale-data/es';

addLocaleData([
  ...enLocaleData,
  ...deLocaleData,
  ...frLocaleData,
  ...esLocaleData,
]);

function WrapInStore({ store, children }) {
  if (store) {
    return (
      <Provider store={store}>
        {children}
      </Provider>
    );
  }
  return children;
}

export default class ComponentWrapper extends Component {
  props: {
    store?: Store,
    children?: any,
    locale: string,
    optimizelyHook?: void => void,
  };

  componentDidMount() {
    this.optimizelyHook();
  }
  componentDidUpdate() {
    this.optimizelyHook();
  }

  optimizelyHook() {
    if (typeof this.props.optimizelyHook === 'function') {
      this.props.optimizelyHook();
    }
  }

  render() {
    return (
      <IntlProvider
        locale={this.props.locale}
        messages={loadTranslations(this.props.locale)}
      >
        <WrapInStore store={this.props.store}>
          <div className="App">
            {this.props.children}
          </div>
        </WrapInStore>
      </IntlProvider>
    );
  }
}

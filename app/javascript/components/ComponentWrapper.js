/* @flow */
import React, { Component } from 'react';
import { Provider } from 'react-redux';
import { IntlProvider, addLocaleData } from 'react-intl';
import enLocaleData from 'react-intl/locale-data/en';
import deLocaleData from 'react-intl/locale-data/de';
import frLocaleData from 'react-intl/locale-data/fr';
import loadTranslations from '../util/TranslationsLoader';

function WrapInStore({ store, children }) {
  if (store) {
    return <Provider store={store}>{children}</Provider>;
  }
  return children;
}

export default class ComponentWrapper extends Component {
  props: {
    store?: Store,
    children?: any,
    locale: string,
    messages?: { [key: string]: string },
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
        messages={this.props.messages || loadTranslations(this.props.locale)}
      >
        <WrapInStore store={this.props.store}>
          <div className="App">{this.props.children}</div>
        </WrapInStore>
      </IntlProvider>
    );
  }
}

addLocaleData([...enLocaleData, ...deLocaleData, ...frLocaleData]);

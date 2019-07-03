/*  */
import React, { Component } from 'react';
import { Provider } from 'react-redux';
import { IntlProvider, addLocaleData } from 'react-intl';
import enLocaleData from 'react-intl/locale-data/en';
import deLocaleData from 'react-intl/locale-data/de';
import frLocaleData from 'react-intl/locale-data/fr';
import esLocaleData from 'react-intl/locale-data/es';
import loadTranslations from '../util/TranslationsLoader';

function WrapInStore(options) {
  if (options.store) {
    return <Provider store={options.store}>{options.children}</Provider>;
  }
  return options.children;
}

export default class ComponentWrapper extends Component {
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

addLocaleData([
  ...enLocaleData,
  ...deLocaleData,
  ...frLocaleData,
  ...esLocaleData,
]);

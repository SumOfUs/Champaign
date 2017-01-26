/* @flow */
import React, { Component } from 'react';
import { Provider } from 'react-redux';
import { IntlProvider } from 'react-intl';
import loadTranslations from './util/TranslationsLoader';

class ComponentWrapper extends Component {
  props: {
    store?: Store;
    children?: any;
    locale: string;
  };

  render() {
    return (
      <IntlProvider locale={this.props.locale} messages={ loadTranslations(this.props.locale) }>
        { this.wrapInStoreProvider(
            <div className="App">
              {this.props.children}
            </div>
          )
        }
      </IntlProvider>
    );
  }

  wrapInStoreProvider(inner) {
    if (this.props.store) {
      return (
        <Provider store={this.props.store}>
          { inner }
        </Provider>
      );
    } else {
      return inner;
    }
  }
}

export default ComponentWrapper;

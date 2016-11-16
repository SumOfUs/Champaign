/* @flow */
import React, { Component } from 'react';
import { Provider } from 'react-redux';
import { IntlProvider, addLocaleData } from 'react-intl';
import enLocaleData from 'react-intl/locale-data/en';
import deLocaleData from 'react-intl/locale-data/de';
import frLocaleData from 'react-intl/locale-data/fr';
import esLocaleData from 'react-intl/locale-data/es';
import FundraiserView from './containers/FundraiserView/FundraiserView';
import './App.css';

addLocaleData([
  ...enLocaleData,
  ...deLocaleData,
  ...frLocaleData,
  ...esLocaleData,
]);

class App extends Component {
  props: {
    store: Store,
  };

  state = {
    language: 'en',
  };

  componentWillMount() {
    this.setState({ language: navigator.language.split('-')[0] });
  }

  render() {
    return (
      <Provider store={this.props.store}>
        <IntlProvider locale={'en'}>
          <div className="App">
            <FundraiserView />
          </div>
        </IntlProvider>
      </Provider>
    );
  }
}

export default App;

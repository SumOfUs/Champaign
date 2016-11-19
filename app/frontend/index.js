/* @flow */
import React from 'react';
import ReactDOM from 'react-dom';
import App from './App';
import configureStore from './state';
import './index.css';

const store = configureStore();

if (process.env.NODE_ENV === 'development') {
  ReactDOM.render(
    <App store={store}/>,
    document.getElementById('root')
  );

  if (module.hot) {
    module.hot.accept('./App', () => {
      const UpdatedApp = require('./App').default;
      ReactDOM.render(
        <UpdatedApp store={store} />,
        document.getElementById('root')
      );
    });
  }
}

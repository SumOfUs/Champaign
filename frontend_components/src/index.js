/* @flow */
import React from 'react';
import ReactDOM from 'react-dom';
import App from './App';
import configureStore from './state';
import './index.css';

const store = configureStore();

ReactDOM.render(
  <App store={store}/>,
  document.getElementById('root')
);


if (process.env.NODE_ENV === 'development') {
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

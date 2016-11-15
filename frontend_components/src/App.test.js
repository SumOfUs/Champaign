import React from 'react';
import ReactDOM from 'react-dom';
import configureStore from './state';
import App from './App';

it('renders without crashing', () => {
  const div = document.createElement('div');
  ReactDOM.render(<App store={configureStore()} />, div);
});

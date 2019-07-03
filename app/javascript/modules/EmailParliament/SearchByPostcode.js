import React, { useState, useEffect } from 'react';
import classnames from 'classnames';
import Button from '../../components/Button/Button';
import SweetInput from '../../components/SweetInput/SweetInput';
import FormGroup from '../../components/Form/FormGroup';
import SearchError from './SearchError';
import { search } from './api';

import './SearchByPostcode.css';

const SearchByPostcode = props => {
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState(false);
  const [postcode, setPostcode] = useState(null);
  const [input, setInput] = useState('');

  const className = classnames('SearchByPostcode', props.className);

  useEffect(() => {
    (async () => {
      if (!postcode) return;

      setLoading(true);
      setError(false);
      props.onChange(null);

      try {
        const target = await search(postcode);
        props.onChange(target);
      } catch (e) {
        setError(true);
      } finally {
        setLoading(false);
      }
    })();
  }, [postcode]);

  const submit = e => {
    e.preventDefault();
    setPostcode(input);
  };

  return (
    <div className={className}>
      <form className="action-form form--big" onSubmit={submit}>
        <FormGroup>
          <h3 className="title">Enter your UK postcode</h3>
          <SweetInput
            type="text"
            label="Postcode"
            value={input}
            onChange={setInput}
            hasError={!!error}
          />
        </FormGroup>
        <Button disabled={loading} onClick={() => setPostcode(input)}>
          Find your MP
        </Button>
        <SearchError error={error} />
      </form>
    </div>
  );
};

export default SearchByPostcode;

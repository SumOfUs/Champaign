import React, { useState } from 'react';
import classnames from 'classnames';
import { search } from './api';
import SearchByPostcode from './SearchByPostcode';
import EmailComposer from './EmailComposer';
import ComponentWrapper from '../../components/ComponentWrapper';
import { redirect } from '../../util/redirector';

const EmailParliament = props => {
  const [target, setTarget] = useState(null);
  const searchClassname = classnames({
    'hidden-irrelevant': target !== null,
  });
  return (
    <div className="EmailParliament">
      <ComponentWrapper locale={props.config.locale}>
        <SearchByPostcode className={searchClassname} onChange={setTarget} />
        <EmailComposer
          title={props.config.title}
          postcode={''}
          target={target}
          subject={props.config.subject}
          template={props.config.template}
          onSend={props.onSend || redirect}
        />
      </ComponentWrapper>
    </div>
  );
};

export default EmailParliament;

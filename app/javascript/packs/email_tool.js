// @flow
import React from 'react';
import { render } from 'react-dom';
import { camelizeKeys } from '../util/util';
import ComponentWrapper from '../components/ComponentWrapper';
import EmailToolView from '../email_tool/EmailToolView';

type Props = {
  locale: string,
  emailSubject?: string,
  country?: string,
  emailBody?: string,
  emailHeader?: string,
  emailFooter?: string,
  email?: string,
  name?: string,
  pageId: string | number,
  isSubmitting: boolean,
};

function mount(root: string, props: Props) {
  const locale = window.champaign.personalization.member;
  render(
    <ComponentWrapper locale={props.locale}>
      <EmailToolView {...camelizeKeys(props)} />
    </ComponentWrapper>,
    document.getElementById(root)
  );
}

window.mountEmailTool = (root: string, props: Props) => {
  mount(root, props);
  if (process.env.NODE_ENV === 'development' && module.hot) {
    module.hot.accept('../email_tool/EmailToolView', () => {
      mount(root, props, require('../email_tool/EmailToolView').default);
    });
  }
};

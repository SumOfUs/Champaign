// @flow
import React from 'react';
import { render } from 'react-dom';
import { camelizeKeys } from '../util/util';
import ComponentWrapper from '../components/ComponentWrapper';
import EmailToolView from '../email_tool/EmailToolView';
import type { EmailTarget } from '../email_tool/EmailToolView';

type Props = {
  country?: string,
  emailSubject: string,
  emailBody: string,
  emailHeader: string,
  emailFooter: string,
  emailFrom: string,
  email?: string,
  isSubmitting: boolean,
  locale: string,
  name?: string,
  postal?: string,
  page: string,
  pageId: number,
  targets: EmailTarget[],
  title: string,
  useMemberEmail: boolean,
  manualTargeting: boolean,
  onSuccess: (target: EmailTarget) => void,
};

function mount(
  root: string,
  props: Props,
  Component: typeof EmailToolView = EmailToolView
) {
  const { locale, ...emailProps } = props;
  render(
    <ComponentWrapper locale={props.locale}>
      <Component {...camelizeKeys(emailProps)} />
    </ComponentWrapper>,
    document.getElementById(root)
  );
}

window.mountEmailTool = (root: string, props: Props) => {
  mount(root, props, EmailToolView);
  if (process.env.NODE_ENV === 'development' && module.hot) {
    module.hot.accept('../email_tool/EmailToolView', () => {
      mount(root, props, require('../email_tool/EmailToolView').default);
    });
  }
};

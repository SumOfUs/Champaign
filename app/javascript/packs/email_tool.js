// @flow
import React from 'react';
import { render } from 'react-dom';
import { camelizeKeys } from '../util/util';
import ComponentWrapper from '../components/ComponentWrapper';
import EmailToolView from '../plugins/email_tool/EmailToolView';
import type { EmailTarget } from '../plugins/email_tool/EmailToolView';

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
  const el = document.getElementById(root);
  if (!el) return;
  render(
    <ComponentWrapper locale={props.locale}>
      <Component {...camelizeKeys(emailProps)} />
    </ComponentWrapper>,
    el
  );
}

window.mountEmailTool = (root: string, props: Props) => {
  mount(root, props, EmailToolView);
  if (process.env.NODE_ENV === 'development' && module.hot) {
    module.hot.accept('../plugins/email_tool/EmailToolView', () => {
      mount(
        root,
        props,
        require('../plugins/email_tool/EmailToolView').default
      );
    });
  }
};

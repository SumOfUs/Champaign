import { Store } from 'redux';

export type AppState = {
  readonly consent: any;
  readonly member: Member;
  readonly page: ChampaignPage;
};

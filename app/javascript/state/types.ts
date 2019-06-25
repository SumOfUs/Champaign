import { Store } from 'redux';
import { ChampaignPage } from '../interfaces';

export type AppState = {
  readonly consent: any;
  readonly member: Member;
  readonly page: ChampaignPage;
};

export type Member = {
  id: number;
  email: string;
  country?: string;
  consented: boolean;
  consentedUpdatedAt: boolean;
  name?: string;
  firstName?: string;
  lastName?: string;
  fullName?: string;
  welcomeName?: string;
  postal?: string;
  donorStatus: 'donor' | 'non_donor' | 'recurring_donor';
  registered: boolean;
  actionKitUserId?: string;
} | null;

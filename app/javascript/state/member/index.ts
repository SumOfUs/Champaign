export type Member = {
  actionKitUserId?: string;
  consented: boolean;
  consentedUpdatedAt: boolean;
  country?: string;
  donorStatus: 'donor' | 'non_donor' | 'recurring_donor';
  email: string;
  firstName?: string;
  fullName?: string;
  id: number;
  lastName?: string;
  name?: string;
  postal?: string;
  registered: boolean;
  welcomeName?: string;
  more: { [key: string]: string | number };
} | null;

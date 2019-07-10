import { pick } from 'lodash';
import * as qs from 'query-string';
import { IFormField } from '../../types';

const HIDDEN_FIELDS = Object.freeze([
  'source',
  'bucket',
  'referrer_id',
  'rid',
  'akid',
  'referring_akid',
]);

const SAFE_OVERRIDES = [
  ...HIDDEN_FIELDS,
  'country',
  'currency',
  'amount',
  'donation_band',
];

export function formValues(fields: IFormField[]) {
  const search = qs.parse(window.location.search);
  const member = window.champaign.personalization.member || {};
  const urlParams = pick(search, ...SAFE_OVERRIDES);
  const formFieldKeys = fields.map(field => field.name).concat(HIDDEN_FIELDS);
  const defaultValues = fields.reduce(
    (obj, field) => ({ ...obj, [field.name]: field.default_value }),
    {}
  );

  return {
    ...defaultValues,
    ...pick({ ...member, ...urlParams }, ...formFieldKeys),
  };
}

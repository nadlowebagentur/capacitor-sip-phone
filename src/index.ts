import { registerPlugin } from '@capacitor/core';

import type { SipPhoneControlPlugin } from './definitions';

const SipPhoneControl = registerPlugin<SipPhoneControlPlugin>(
  'SipPhoneControl',
  {
    web: () => import('./web').then(m => new m.SipPhoneControlWeb()),
  },
);

export * from './definitions';
export { SipPhoneControl };

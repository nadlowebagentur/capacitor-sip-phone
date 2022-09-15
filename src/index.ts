import { registerPlugin } from '@capacitor/core';

import type { SipPhoneControlPlugin } from './definitions';

const SipPhoneControl: SipPhoneControlPlugin = registerPlugin<SipPhoneControlPlugin>(
  'SipPhoneControl',
  {
    web: () => import('./web').then(m => new m.SipPhoneControlWeb()),
  },
);

export {
  SipEvent,
  SipLoginOptions,
  SipOutgoingCallOptions,
} from './definitions';

export { SipPhoneControl };

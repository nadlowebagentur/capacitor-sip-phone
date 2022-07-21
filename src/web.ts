import { WebPlugin } from '@capacitor/core';

import type {
  SipLoginOptions,
  SipOutgoingCallOptions,
  SipPhoneControlPlugin,
} from './definitions';

export class SipPhoneControlWeb
  extends WebPlugin
  implements SipPhoneControlPlugin {
  initialize(): Promise<void> {
    return Promise.reject('Not implemented on Web platform');
  }

  login(__: SipLoginOptions): Promise<void> {
    return Promise.reject('Not implemented on Web platform');
  }

  logout(): Promise<void> {
    return Promise.reject('Not implemented on Web platform');
  }

  acceptCall(): Promise<void> {
    return Promise.reject('Not implemented on Web platform');
  }

  call(__: SipOutgoingCallOptions): Promise<void> {
    return Promise.reject('Not implemented on Web platform');
  }

  hangUp(): Promise<void> {
    return Promise.reject('Not implemented on Web platform');
  }
}

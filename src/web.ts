import { WebPlugin } from '@capacitor/core';

import type { SipPhoneControlPlugin } from './definitions';

export class SipPhoneControlWeb
  extends WebPlugin
  implements SipPhoneControlPlugin {
  async echo(options: { value: string }): Promise<{ value: string }> {
    console.log('ECHO', options);
    return options;
  }
}

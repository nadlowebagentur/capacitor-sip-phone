export interface SipLoginOptions {
  /**
   * By default "UDP"
   */
  transport?: 'TLS' | 'TCP' | 'UDP';

  /**
   * SIP domain address
   */
  domain: string;

  /**
   * User login for authentication
   */
  username: string;

  /**
   * User password for authentication
   */
  password: string;
}

export interface SipOutgoingCallOptions {
  address: string;
}

export enum SipEvent {
  AccountStateChanged = 'SIPAccountStateChanged',
  CallStateChanged = 'SIPCallStateChanged',
}

export interface SipPhoneControlPlugin {
  /**
   * Initialize plugin state
   */
  initialize(): Promise<void>;

  /**
   * Make login to the SIP
   * @param options
   */
  login(options: SipLoginOptions): Promise<void>;

  /**
   * Logout & terminate account
   */
  logout(): Promise<void>;

  /**
   * Make outgoing call
   * @param options
   */
  call(options: SipOutgoingCallOptions): Promise<void>;

  /**
   * Accept incoming call
   */
  acceptCall(): Promise<void>;

  /**
   * Terminate current call
   */
  hangUp(): Promise<void>;
}

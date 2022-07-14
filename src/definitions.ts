export interface SipPhoneControlPlugin {
  echo(options: { value: string }): Promise<{ value: string }>;
}

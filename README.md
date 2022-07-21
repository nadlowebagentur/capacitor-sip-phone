# @nadlowebagentur/capacitor-sip-phone

Connect to SIP phone line

## Install

```bash
npm install @nadlowebagentur/capacitor-sip-phone
npx cap sync
```

## API

<docgen-index>

* [`initialize()`](#initialize)
* [`login(...)`](#login)
* [`logout()`](#logout)
* [`call(...)`](#call)
* [`acceptCall()`](#acceptcall)
* [`hangUp()`](#hangup)
* [Interfaces](#interfaces)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### initialize()

```typescript
initialize() => Promise<void>
```

Initialize plugin state

--------------------


### login(...)

```typescript
login(options: SipLoginOptions) => Promise<void>
```

Make login to the SIP

| Param         | Type                                                        |
| ------------- | ----------------------------------------------------------- |
| **`options`** | <code><a href="#siploginoptions">SipLoginOptions</a></code> |

--------------------


### logout()

```typescript
logout() => Promise<void>
```

Logout & terminate account

--------------------


### call(...)

```typescript
call(options: SipOutgoingCallOptions) => Promise<void>
```

Make outgoing call

| Param         | Type                                                                      |
| ------------- | ------------------------------------------------------------------------- |
| **`options`** | <code><a href="#sipoutgoingcalloptions">SipOutgoingCallOptions</a></code> |

--------------------


### acceptCall()

```typescript
acceptCall() => Promise<void>
```

Accept incoming call

--------------------


### hangUp()

```typescript
hangUp() => Promise<void>
```

Terminate current call

--------------------


### Interfaces


#### SipLoginOptions

| Prop            | Type                                 | Description                      |
| --------------- | ------------------------------------ | -------------------------------- |
| **`transport`** | <code>'TLS' \| 'TCP' \| 'UDP'</code> | By default "UDP"                 |
| **`domain`**    | <code>string</code>                  | SIP domain address               |
| **`username`**  | <code>string</code>                  | User login for authentication    |
| **`password`**  | <code>string</code>                  | User password for authentication |


#### SipOutgoingCallOptions

| Prop          | Type                |
| ------------- | ------------------- |
| **`address`** | <code>string</code> |

</docgen-api>

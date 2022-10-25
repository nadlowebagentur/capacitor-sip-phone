import Foundation
import linphonesw

class SipPhoneControl: ObservableObject {
    var mCore: Core!
    var mAccount: Account?
    var mCoreDelegate : CoreDelegate!
    
    @Published var username : String = ""
    @Published var passwd : String = ""
    @Published var domain : String = ""
    @Published var loggedIn: Bool = false
    @Published var transportType : String = "UDP"
    
    // Outgoing call related variables
    @Published var callMsg : String = ""
    @Published var isCallRunning : Bool = false
    @Published var isVideoEnabled : Bool = false
    @Published var canChangeCamera : Bool = false
    @Published var remoteAddress : String = ""
    
    // Callkit related variables
    @Published var isCallIncoming: Bool = false
    @Published var isCallOutgoing: Bool = false
    @Published var incomingCallName = ""
    @Published var mCall : Call?
    @Published var mProviderDelegate : SipPhoneCallKitProviderDelegate!
    @Published var mCallAlreadyStopped : Bool = false;
    
    // event handlers
    @Published var registrationStateListener: (() -> Void)?;
    @Published var callStateListener: (() -> Void)?;
    
    init()
    {
        LoggingService.Instance.logLevel = LogLevel.Debug
        
        let factory = Factory.Instance
        // IMPORTANT : In this tutorial, we require the use of a core configuration file.
        // This way, once the registration is done, and until it is cleared, it will return to the LoggedIn state on launch.
        // This allows us to have a functional call when the app was closed and is started by a VOIP push notification (incoming call
        // We also need to enable "Push Notitifications" and "Background Mode - Voice Over IP"
        let configDir = factory.getConfigDir(context: nil)
        try? mCore = factory.createCore(configPath: "\(configDir)/SipConfig", factoryConfigPath: "", systemContext: nil)
        
        mProviderDelegate = SipPhoneCallKitProviderDelegate(context: self)
        
        // enabling push notifications management in the core
        mCore.callkitEnabled = true
        mCore.pushNotificationEnabled = true
        
        // Here we enable the video capture & display at Core level
        // It doesn't mean calls will be made with video automatically,
        // But it allows to use it later
        mCore.videoCaptureEnabled = false
        mCore.videoDisplayEnabled = false
        
        // When enabling the video, the remote will either automatically answer the update request
        // or it will ask it's user depending on it's policy.
        // Here we have configured the policy to always automatically accept video requests
        // mCore.videoActivationPolicy!.automaticallyAccept = true
        
        
        // If the following property is enabled, it will automatically configure created call params with video enabled
        //core.videoActivationPolicy.automaticallyInitiate = true
        
        try? mCore.start()
        
        mCoreDelegate = CoreDelegateStub( onCallStateChanged: { (core: Core, call: Call, state: Call.State, message: String) in
            // This function will be called each time a call state changes,
            // which includes new incoming/outgoing calls
            self.callMsg = message
            
            NSLog("[sip]: callMsg \(message)")
            NSLog("[sip]: state \(state)")
            
            if (state == .PushIncomingReceived){
                // We're being called by someone (and app is in background)
                self.mCall = call
                self.isCallIncoming = true
                
                self.incomingCallName = call.remoteAddress?.displayName ?? "Unknown"
                
                self.mProviderDelegate.incomingCall()
            } else if (state == .IncomingReceived) {
                // If app is in foreground, it's likely that we will receive the SIP invite before the Push notification
                if (!self.isCallIncoming) {
                    self.mCall = call
                    self.isCallIncoming = true
                    
                    self.incomingCallName = call.remoteAddress?.displayName ?? "Unknown"
                    
                    self.mProviderDelegate.incomingCall()
                }
                self.remoteAddress = call.remoteAddress!.asStringUriOnly()
            } else if (state == .OutgoingInit) {
                // When the 200 OK has been received
                self.isCallIncoming = false
                self.isCallOutgoing = true
                
                // repot outgoing call
                self.mProviderDelegate.outgoingCallStarted()
            } else if (state == .OutgoingRinging) {
                // This state will be reached upon reception of the 180 RINGING
            } else if (state == .Connected) {
                // When the 200 OK has been received
                self.isCallIncoming = false
                self.isCallOutgoing = false
                self.isCallRunning = true
            } else if (state == .StreamsRunning) {
                // This state indicates the call is active.
                // You may reach this state multiple times, for example after a pause/resume
                // or after the ICE negotiation completes
                
                // Only enable toggle camera button if there is more than 1 camera
                // We check if core.videoDevicesList.size > 2 because of the fake camera with static image created by our SDK (see below)
                self.canChangeCamera = core.videoDevicesList.count > 2
                
                // report like connected
                if (self.isCallOutgoing) {
                    self.mProviderDelegate.outgoingCallConnected();
                }
            } else if (state == .Paused) {
                // When you put a call in pause, it will became Paused
                self.canChangeCamera = false
            } else if (state == .PausedByRemote) {
                // When the remote end of the call pauses it, it will be PausedByRemote
            } else if (state == .Updating) {
                // When we request a call update, for example when toggling video
            } else if (state == .UpdatedByRemote) {
                // When the remote requests a call update
            } else if (state == .Released || state == .End || state == .Error) {
                // Call has been terminated by any side
                
                // Report to CallKit that the call is over, if the terminate action was initiated by other end of the call
                if (self.isCallRunning) {
                    self.mProviderDelegate.stopCall()
                }
                
                self.remoteAddress = "Nobody yet"
                
                self.isCallRunning = false
                self.isCallOutgoing = false
                self.isCallIncoming = false
            }
            
            // notify changed call state
            if let callback = self.callStateListener {
                callback()
            }
        }, onAccountRegistrationStateChanged: { (core: Core, account: Account, state: RegistrationState, message: String) in
            if (state == .Ok) {
                self.loggedIn = true
            } else if (state == .Cleared) {
                self.loggedIn = false
            }
            
            if let callback = self.registrationStateListener {
                callback()
            }
        })
        
        mCore.addDelegate(delegate: mCoreDelegate)
    }
    
    func login() throws {
        do {
            if (self.loggedIn) {
                return
            }
            
            var transport : TransportType
            if (transportType == "TLS") { transport = TransportType.Tls }
            else if (transportType == "TCP") { transport = TransportType.Tcp }
            else  { transport = TransportType.Udp }
            
            let authInfo = try Factory.Instance.createAuthInfo(username: username, userid: "", passwd: passwd, ha1: "", realm: "", domain: domain)
            let accountParams = try mCore.createAccountParams()
            let identity = try Factory.Instance.createAddress(addr: String("sip:" + username + "@" + domain))
            try! accountParams.setIdentityaddress(newValue: identity)
            let address = try Factory.Instance.createAddress(addr: String("sip:" + domain))
            try address.setTransport(newValue: transport)
            try accountParams.setServeraddress(newValue: address)
            accountParams.registerEnabled = true
            
            // Enable push notifications on this account
            accountParams.pushNotificationAllowed = true
            
            // We're in a sandbox application, so we must set the provider to "apns.dev" since it will be "apns" by default, which is used only for production apps
            accountParams.pushNotificationConfig?.provider = "apns.dev"
            
            mAccount = try mCore.createAccount(params: accountParams)
            mCore.addAuthInfo(info: authInfo)
            try mCore.addAccount(account: mAccount!)
            mCore.defaultAccount = mAccount
            
        } catch {
            NSLog("[SIP] login error \(error.localizedDescription)")
            throw error
        }
    }
    
    func unregister()
    {
        if let account = mCore.defaultAccount {
            let params = account.params
            let clonedParams = params?.clone()
            clonedParams?.registerEnabled = false
            account.params = clonedParams
        }
    }
    
    func delete() {
        if let account = mCore.defaultAccount {
            mCore.removeAccount(account: account)
            mCore.clearAccounts()
            mCore.clearAllAuthInfo()
        }
    }
    
    func outgoingCall() throws {
        do {
            // As for everything we need to get the SIP URI of the remote and convert it to an Address
            let remoteAddress = try Factory.Instance.createAddress(addr: remoteAddress)
            
            // We also need a CallParams object
            // Create call params expects a Call object for incoming calls, but for outgoing we must use null safely
            let params = try mCore.createCallParams(call: nil)
            
            // We can now configure it
            // Here we ask for no encryption but we could ask for ZRTP/SRTP/DTLS
            params.mediaEncryption = MediaEncryption.None
            // If we wanted to start the call with video directly
            //params.videoEnabled = true
            
            // Finally we start the call
            let _ = mCore.inviteAddressWithParams(addr: remoteAddress, params: params)
            // Call process can be followed in onCallStateChanged callback from core listener
        } catch {
            throw error
        }
        
    }
    
    func terminateCall() {
        if (self.isCallRunning) {
            do {
                if (mCore.callsNb == 0) { return }
                
                // If the call state isn't paused, we can get it using core.currentCall
                let coreCall = (mCore.currentCall != nil) ? mCore.currentCall : mCore.calls[0]
                
                // Terminating a call is quite simple
                if let call = coreCall {
                    try call.terminate()
                }
            } catch { NSLog(error.localizedDescription) }
        }
    }
}

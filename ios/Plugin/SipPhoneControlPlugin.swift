import Foundation
import Capacitor
import AVFoundation
import Combine

enum SipEvent: String {
    case AccountStateChanged = "SIPAccountStateChanged", CallStateChanged = "SIPCallStateChanged";
}

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(SipPhoneControlPlugin)
public class SipPhoneControlPlugin: CAPPlugin {
    private let implementation = SipPhoneControl()
    let session: AVAudioSession = AVAudioSession.sharedInstance()
    var cancellableBag = Set<AnyCancellable>()
    
    override public func load() {
        let registerStateChangedListener = { [self] in
            NSLog("[SIP] Value of the isLoggedIn \(self.implementation.loggedIn)")
            
            self.notifyListeners(SipEvent.AccountStateChanged.rawValue, data: [
                "isLoggedIn": self.implementation.loggedIn
            ])
        }
        
        let callStateChangedListener = { [self] in
            self.notifyListeners(SipEvent.CallStateChanged.rawValue, data: [
                "isCallRunning": self.implementation.isCallRunning,
                "isCallIncoming": self.implementation.isCallIncoming,
                "isCallOutgoing": self.implementation.isCallOutgoing,
            ])
        }
        
        implementation.registrationStateListener = registerStateChangedListener
        implementation.callStateListener = callStateChangedListener
        
        implementation.$loggedIn.sink { value in
            registerStateChangedListener()
        }.store(in: &cancellableBag)
        
        implementation.objectWillChange.sink {
            callStateChangedListener()
        }.store(in: &cancellableBag)
    }
    
    @objc override public func checkPermissions(_ call: CAPPluginCall) {
        // TODO
        call.unimplemented("TODO: implement this method")
    }
    
    @objc override public func requestPermissions(_ call: CAPPluginCall) {
        if (session.responds(to: #selector(AVAudioSession.requestRecordPermission(_:)))) {
            AVAudioSession.sharedInstance().requestRecordPermission({(granted: Bool)-> Void in
                if granted {
                    print("granted")
                    
                    do {
                        try self.session.setCategory(AVAudioSession.Category.playAndRecord)
                        try self.session.setActive(true)
                    }
                    catch {
                        
                        print("Couldn't set Audio session category")
                    }
                } else{
                    print("not granted")
                }
            })
        }
    }
    
    @objc func login(_ call: CAPPluginCall) {
        if let cb = implementation.registrationStateListener {
            cb()
        }
        
        let transport = call.getString("transport", "UDP")
        
        let domain = call.getString("domain")
        let username = call.getString("username")
        let password = call.getString("password")
        
        if (domain == nil || username == nil || password == nil) {
            call.reject("[SipPhoneControl] domain, username, password are required fields!")
            
            return
        }
        
        implementation.transportType = transport
        
        implementation.domain = domain ?? ""
        implementation.username = username  ?? ""
        implementation.passwd = password  ?? ""
        
        do {
            try implementation.login()
            
            call.resolve()
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    @objc func logout(_ call: CAPPluginCall) {
        implementation.unregister()
        implementation.delete()
    }
    
    @objc func call(_ call: CAPPluginCall) {
        let address = call.getString("address") ?? ""
        
        if (address.isEmpty) {
            call.reject("[SipPhoneControl] address is required")
            
            return
        }
        
        implementation.remoteAddress = address
        
        do {
            try implementation.outgoingCall()
        } catch {
            call.reject(error.localizedDescription)
        }
    }
    
    @objc func acceptCall(_ call: CAPPluginCall) {
        call.unimplemented("TODO: implement accept call")
    }
    
    @objc func hangUp(_ call: CAPPluginCall) {
        implementation.terminateCall()
    }
}

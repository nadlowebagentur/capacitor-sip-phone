import Foundation
import Capacitor

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(SipPhoneControlPlugin)
public class SipPhoneControlPlugin: CAPPlugin {
    private let implementation = SipPhoneControl()
    
    @objc func initialize(_ call: CAPPluginCall) {
        call.resolve()
    }
    
    @objc func login(_ call: CAPPluginCall) {
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
        call.reject("TODO: implement accept call")
    }
    
    @objc func hangUp(_ call: CAPPluginCall) {
        call.reject("TODO: implement hangUp")
    }
}

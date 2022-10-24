import Foundation
import CallKit
import linphonesw
import AVFoundation


@objc
class SipPhoneCallKitProviderDelegate : NSObject
{
    private let provider: CXProvider
    let mCallController = CXCallController()
    var sipPhoneCtx : SipPhoneControl!
    
    var activeCallUUID : UUID!
    
    init(context: SipPhoneControl)
    {
        sipPhoneCtx = context
        // let providerConfiguration = CXProviderConfiguration(localizedName: Bundle.main.infoDictionary!["CFBundleName"] as! String)
        let providerConfiguration = CXProviderConfiguration(localizedName: Bundle.main.infoDictionary!["CFBundleDisplayName"] as! String)
        providerConfiguration.supportsVideo = true
        providerConfiguration.supportedHandleTypes = [.generic]
        
        providerConfiguration.maximumCallsPerCallGroup = 1
        providerConfiguration.maximumCallGroups = 1
        
        provider = CXProvider(configuration: providerConfiguration)
        super.init()
        provider.setDelegate(self, queue: nil) // The CXProvider delegate will trigger CallKit related callbacks
        
    }
    
    func incomingCall()
    {
        NSLog("[sip]: incomingCall")
        
        activeCallUUID = UUID()
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type:.generic, value: sipPhoneCtx.incomingCallName)
        
        provider.reportNewIncomingCall(with: activeCallUUID, update: update, completion: { error in }) // Report to CallKit a call is incoming
    }
    
    func outgoingCallStarted()
    {
        activeCallUUID = UUID()
        
        NSLog("[sip]: outgoingCallStarted \(activeCallUUID)")
        
        provider.reportOutgoingCall(with: activeCallUUID, startedConnectingAt: nil) // Report to CallKit
    }
    
    func outgoingCallConnected()
    {
        NSLog("[sip]: outgoingCallConnected with ID \(activeCallUUID)")
        
        provider.reportOutgoingCall(with: activeCallUUID, connectedAt: nil) // Report to CallKit
    }
    
    func stopCall()
    {
        NSLog("[sip]: [stopCall] activeCallUUID: \(String(describing: activeCallUUID))")
        
        let endCallAction = CXEndCallAction(call: activeCallUUID)
        let transaction = CXTransaction(action: endCallAction)
        
        mCallController.request(transaction, completion: { error in
            NSLog("[sip]: stoCall error \(error)")
        }) // Report to CallKit a call must end
    }
    
}


// In this extension, we implement the action we want to be done when CallKit is notified of something.
// This can happen through the CallKit GUI in the app, or directly in the code (see, incomingCall(), stopCall() functions above)
extension SipPhoneCallKitProviderDelegate: CXProviderDelegate {
    
    func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        do {
            if (sipPhoneCtx.mCall?.state != .End && sipPhoneCtx.mCall?.state != .Released)  {
                try sipPhoneCtx.mCall?.terminate()
            }
        } catch {
            NSLog(error.localizedDescription)
            
            NSLog("[sip]: CXEndCallAction")
        }
        
        sipPhoneCtx.isCallRunning = false
        sipPhoneCtx.isCallIncoming = false
        sipPhoneCtx.isCallOutgoing = false
        
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        do {
            sipPhoneCtx.mCore.configureAudioSession()
            
            try sipPhoneCtx.mCall?.accept()
            sipPhoneCtx.isCallRunning = true
        } catch {
            print(error)
        }
        action.fulfill()
    }
    
    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
        action.fulfill()
    }
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        sipPhoneCtx.mCore.configureAudioSession()
        
        sipPhoneCtx.isCallRunning = true
        
        
        action.fulfill()
    }
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
        action.fulfill()
    }
    func provider(_ provider: CXProvider, perform action: CXPlayDTMFCallAction) {
        action.fulfill()
    }
    func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
        action.fulfill()
    }
    func providerDidReset(_ provider: CXProvider) {
        NSLog("[sip]: providerDidReset")
    }
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        sipPhoneCtx.mCore.activateAudioSession(actived: true)
    }
    
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        sipPhoneCtx.mCore.activateAudioSession(actived: false)
    }
}

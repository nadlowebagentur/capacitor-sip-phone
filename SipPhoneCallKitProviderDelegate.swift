import Foundation
import CallKit
import linphonesw
import AVFoundation


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
        activeCallUUID = UUID()
        let update = CXCallUpdate()
        update.remoteHandle = CXHandle(type:.generic, value: sipPhoneCtx.incomingCallName)
        
        provider.reportNewIncomingCall(with: activeCallUUID, update: update, completion: { error in }) // Report to CallKit a call is incoming
    }
    
    func outgoingCallStarted()
    {
        activeCallUUID = UUID()
        
        let handle = CXHandle(type: .generic, value: "displayName")
        let startCallAction = CXStartCallAction(call: activeCallUUID, handle: handle)
        let transaction = CXTransaction(action: startCallAction)

        mCallController.request(transaction, completion: { error in })
        
        provider.reportOutgoingCall(with: activeCallUUID, startedConnectingAt: Date()) // Report to CallKit
    }
    
    func outgoingCallConnected()
    {
        provider.reportOutgoingCall(with: activeCallUUID, connectedAt: Date()) // Report to CallKit
    }
    
    func stopCall()
    {
        let endCallAction = CXEndCallAction(call: activeCallUUID)
        let transaction = CXTransaction(action: endCallAction)

        mCallController.request(transaction, completion: { error in }) // Report to CallKit a call must end
        
        // provider.reportCall(with: activeCallUUID, endedAt: Date(), reason: .remoteEnded)
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
        } catch { NSLog(error.localizedDescription) }
        
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
    
    func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {}
    func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
        sipPhoneCtx.mCore.configureAudioSession()
        
        sipPhoneCtx.isCallRunning = true
        
        
        action.fulfill()
    }
    func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {}
    func provider(_ provider: CXProvider, perform action: CXPlayDTMFCallAction) {}
    func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {}
    func providerDidReset(_ provider: CXProvider) {}
    
    func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        sipPhoneCtx.mCore.activateAudioSession(actived: true)
    }
    
    func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        sipPhoneCtx.mCore.activateAudioSession(actived: false)
    }
}

import Foundation

@objc public class SipPhoneControl: NSObject {
    @objc public func echo(_ value: String) -> String {
        print(value)
        return value
    }
}

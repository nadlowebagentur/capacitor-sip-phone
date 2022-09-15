#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

// Define the plugin using the CAP_PLUGIN Macro, and
// each method the plugin supports using the CAP_PLUGIN_METHOD macro.
CAP_PLUGIN(SipPhoneControlPlugin, "SipPhoneControl",
           CAP_PLUGIN_METHOD(initialize, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(login, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(logout, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(call, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(acceptCall, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(hangUp, CAPPluginReturnPromise);
        
)

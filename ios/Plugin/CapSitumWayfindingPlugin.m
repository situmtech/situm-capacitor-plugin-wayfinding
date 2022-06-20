#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

// Define the plugin using the CAP_PLUGIN Macro, and
// each method the plugin supports using the CAP_PLUGIN_METHOD macro.
CAP_PLUGIN(CapSitumWayfindingPlugin, "SitumWayfinding",
           CAP_PLUGIN_METHOD(internalLoad, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(internalUnload, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(internalSetOverlays, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(internalOnPoiSelected, CAPPluginReturnCallback);
           CAP_PLUGIN_METHOD(internalOnPoiDeselected, CAPPluginReturnCallback);
           CAP_PLUGIN_METHOD(internalOnFloorChange, CAPPluginReturnCallback);
           CAP_PLUGIN_METHOD(internalSetCaptureTouchEvents, CAPPluginReturnNone);
           CAP_PLUGIN_METHOD(internalSelectBuilding, CAPPluginReturnNone);
           CAP_PLUGIN_METHOD(internalSelectPoi, CAPPluginReturnNone);
           CAP_PLUGIN_METHOD(internalNavigateToPoi, CAPPluginReturnNone);
           CAP_PLUGIN_METHOD(internalNavigateToLocation, CAPPluginReturnNone);
           CAP_PLUGIN_METHOD(internalStopPositioning, CAPPluginReturnNone);
           CAP_PLUGIN_METHOD(internalStopNavigation, CAPPluginReturnNone);
           CAP_PLUGIN_METHOD(internalOnNavigationRequested, CAPPluginReturnCallback);
           CAP_PLUGIN_METHOD(internalOnNavigationError, CAPPluginReturnCallback);
           CAP_PLUGIN_METHOD(internalOnNavigationFinished, CAPPluginReturnCallback);
           CAP_PLUGIN_METHOD(internalLockCameraToBuilding, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(internalUnlockCameraToBuilding, CAPPluginReturnPromise);
)

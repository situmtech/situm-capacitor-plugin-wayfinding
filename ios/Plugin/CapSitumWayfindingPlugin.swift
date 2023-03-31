import Foundation
import Capacitor
import GoogleMaps
import SitumSDK



/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(CapSitumWayfindingPlugin)
public class CapSitumWayfindingPlugin: CAPPlugin, WayfindingNativeToCapProtocol {
    
    private var containerView: UIView?
    private let situmWayFindingWrapper = CapSitumWayfinding()
    private var screenInfo: CapScreenInfo?
    private var touchDistributorView:CapTouchDistributorView?
    
    
    //Capacitor callbacks
    private var onPoiSelectedCall: CAPPluginCall?
    private var onPoiDeselectedCall: CAPPluginCall?
    private var onFloorChangedCall: CAPPluginCall?
    private var onNavigationRequestedCallback: CAPPluginCall?
    private var onNavigationStartedCallback: CAPPluginCall?
    private var onNavigationErrorCallback: CAPPluginCall?
    private var onNavigationFinishedCallback: CAPPluginCall?
    
    //MARK: Public methods implementation
    
    @objc func internalLoad(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            self.bridge?.saveCall(call)
            let devicePixelRatio = call.getDouble("devicePixelRatio", 1.0)
            let settingsJsonObject = call.getObject("librarySettings", [:])
            let screenInfoJsonObject = call.getObject("screenInfo", [:])
            let googleMapView:GMSMapView = self.getGMSMapView()!
            self.containerView = self.replaceMapWithContainerView(googleMapView)
            self.screenInfo = CapScreenInfo.from(pixelRatio: devicePixelRatio, screenInfo: screenInfoJsonObject)
            do{
                let librarySettings = try CapLibrarySettings.from(settingsJsonObject)
                self.situmWayFindingWrapper.load(containerView: self.containerView, librarySettings: librarySettings.toWyfLibraySettings(googleMap: googleMapView)) { result in
                    switch result {
                    case .success:
                        do{
                            self.situmWayFindingWrapper.delegate = self
                            //After next instruction events will be captured by the native map if librarySettings.captureTouchEvents is true
                            try self.enableHtmlOverMap(isMapTouchEventsAllowed: librarySettings.captureTouchEvents)
                            
                            if librarySettings.lockCameraToBuilding {
                                self.situmWayFindingWrapper.lockCameraToBuilding(buildingId: librarySettings.buildingId)
                            }
                            
                            let result: Dictionary = [
                                "status" : "SUCCESS",
                            ]
                            call.resolve(result)
                            self.bridge?.releaseCall(call)
                        }catch{
                            self.handleLoadError(error: error, call: call)
                        }
                    case .failure(let error):
                        self.handleLoadError(error: error, call: call)
                    }
                }
            }catch{
                self.handleLoadError(error: error, call: call)
            }
        }
    }
    
    @objc func internalUnload(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            self.situmWayFindingWrapper.stop()
            self.containerView?.removeFromSuperview()
            self.touchDistributorView?.removeFromSuperview()
            self.containerView = nil;
            self.touchDistributorView = nil;
            call.resolve()
        }
    }

    @objc func internalSetOverlays(_ call: CAPPluginCall){
        let jsonOverlaysArray = call.getArray("overlays",[])
        screenInfo?.add(jsonOverlaysArray: jsonOverlaysArray)
        touchDistributorView?.screenInfo = screenInfo
        call.resolve()
    }
    
    // Set if touch events are captured by html view or native map
    @objc func internalSetCaptureTouchEvents(_ call: CAPPluginCall){
        //In this method the varibale name is captureEvents. However in LibrarySettings the same variable its named captureTouchEvents. Being overprotective here to avoid misspelling errors
        let captureTouchEvents = call.getBool("captureEvents", true) && call.getBool("captureTouchEvents", true)
        self.touchDistributorView?.setIsMapTouchEventsAllowed(captureTouchEvents)
        call.resolve()
    }
    
    @objc func internalSelectBuilding(_ call: CAPPluginCall){
    }
    
    @objc func internalSelectPoi(_ call: CAPPluginCall){
        self.bridge?.saveCall(call)
        let buildingId = call.getString("buildingId","")
        let poiID = call.getString("id","")
        self.situmWayFindingWrapper.selectPoi(buildingId: buildingId, poiId: poiID) { result in
            switch result {
            case .success:
                call.resolve()
            case .failure(let error):
                call.reject(error.localizedDescription)
            }
            self.bridge?.releaseCall(call)
        }
    }
    
    @objc func internalNavigateToPoi(_ call: CAPPluginCall){
        let buildingId = call.getString("buildingId")
        let poiID = call.getString("id")
        
        guard let uBuildingId = buildingId, let uPoiID = poiID else{
            call.reject("All required parameters must be set: buildingId, poiID")
            return
        }
        
        self.bridge?.saveCall(call)
        self.situmWayFindingWrapper.navigateToPoi(buildingId: uBuildingId, poiId: uPoiID) { result in
            switch result {
            case .success:
                call.resolve()
            case .failure(let error):
                call.reject(error.localizedDescription)
            }
            self.bridge?.releaseCall(call)
        }
    }
    
    @objc func internalNavigateToLocation(_ call: CAPPluginCall){
        let buildingId = call.getString("buildingId")
        let floorId = call.getString("floorId")
        let latitude = call.getDouble("latitude")
        let longitude = call.getDouble("longitude")
        
        guard let uBuildingId = buildingId, let uFloorId = floorId, let uLatitude = latitude, let uLongitude = longitude else{
            call.reject("All required parameters must be set: buildingId, floorId, latitude, longitude")
            return
        }
        
        self.bridge?.saveCall(call)
        self.situmWayFindingWrapper.navigateToLocation(buildingId: uBuildingId, floorId: uFloorId, latitude: uLatitude, longitude: uLongitude) { result in
            switch result {
            case .success:
                call.resolve()
            case .failure(let error):
                call.reject(error.localizedDescription)
            }
            self.bridge?.releaseCall(call)
        }
    }
    
    @objc func internalStopPositioning(_ call: CAPPluginCall){
        self.situmWayFindingWrapper.stopPositioning()
        call.resolve()
    }

    @objc func internalStopNavigation(_ call: CAPPluginCall){
        self.situmWayFindingWrapper.stopNavigation()
        call.resolve()
    }

    //MARK: Set callbacks to notify on events over the plugin
    @objc func internalOnPoiSelected(_ call: CAPPluginCall){
        call.keepAlive = true
        self.onPoiSelectedCall = call
    }
    
    @objc func internalOnPoiDeselected(_ call: CAPPluginCall){
        call.keepAlive = true
        self.onPoiDeselectedCall = call
    }
    
    @objc func internalOnFloorChange(_ call: CAPPluginCall){
        call.keepAlive = true
        self.onFloorChangedCall = call
    }

    @objc func internalOnNavigationRequested(_ call: CAPPluginCall){
        call.keepAlive = true
        self.onNavigationRequestedCallback = call
    }
    
    @objc func internalOnNavigationStarted(_ call: CAPPluginCall){
        call.keepAlive = true
        self.onNavigationStartedCallback = call
    }

    @objc func internalOnNavigationError(_ call: CAPPluginCall){
        call.keepAlive = true
        self.onNavigationErrorCallback = call
    }

    @objc func internalOnNavigationFinished(_ call: CAPPluginCall){
        call.keepAlive = true
        self.onNavigationFinishedCallback = call
    }

    //MARK: Error handling
    private func handleLoadError(error:Error, call:CAPPluginCall){
        call.reject(error.localizedDescription)
        self.bridge?.releaseCall(call)
    }
    
    //MARK: Prepare WebView and GSMMapView for SitumWayfinding
    
    private func getGMSMapView() -> GMSMapView?{
        let gmsMapView = getViewFromHierarchy(classOfView: GMSMapView.self)
        return gmsMapView as? GMSMapView;
    }
    
    // The plugin need the view where the map is going to be presented, not the map itself
    private func replaceMapWithContainerView(_ mapView:GMSMapView)->UIView{
        let view = CapMapContainerView.init(frame: mapView.frame)
        mapView.parentViewController?.view=view
        return view;
    }
    
    private func enableHtmlOverMap(isMapTouchEventsAllowed:Bool) throws {
        let scrollView = getViewFromHierarchy(classOfView: UIScrollView.self)
        let mapContainerView = getViewFromHierarchy(classOfView: CapMapContainerView.self)
        if let uScrollView = scrollView, let uMapContainerView = mapContainerView {
            //Move to front to see html overlays above map.
            bridge?.viewController?.view.bringSubviewToFront(uScrollView)
            //Now webView dont let us see map. Make webView transparent
            makeWebViewTransparent()
            //Add transparent view to decide whom should be responsible of touch events
            touchDistributorView = self.addTouchDistributorView(uMapContainerView, webScrollView: uScrollView, isMapTouchEventsAllowed: isMapTouchEventsAllowed)
        } else {
            throw(CapWayfindingError.noProperViewHierarchy)
        }
    }
    
    private func makeWebViewTransparent(){
        let webView: WKWebView? = self.bridge?.viewController?.view as? WKWebView
        webView?.isOpaque = false
        webView?.scrollView.isOpaque = false
        webView?.backgroundColor = UIColor(ciColor: .clear)
        webView?.scrollView.backgroundColor = UIColor(ciColor: .clear)
    }
    
    private func getViewFromHierarchy<T>(classOfView:T.Type)->UIView?{
        let capacitorViews =  self.bridge?.viewController?.view.subviews
        return capacitorViews?.first(where: {$0 is T})
    }
    
    private func addTouchDistributorView(_ mapContainerView:UIView, webScrollView: UIView, isMapTouchEventsAllowed: Bool) -> CapTouchDistributorView{
        let touchDistributorView = CapTouchDistributorView.init(frame: webScrollView.frame)
        touchDistributorView.webScrollView = webScrollView
        touchDistributorView.setIsMapTouchEventsAllowed(isMapTouchEventsAllowed)
        self.bridge?.viewController?.view.addSubview(touchDistributorView)
        return touchDistributorView
    }

    // MARK: CapSitumWayfindingNativeToCap methods
    internal func onPoiSelected(poi: SITPOI, level: SITFloor, building: SITBuilding) {
        if let call = self.onPoiSelectedCall {
            let result: Dictionary = [
                "buildingId" : building.identifier,
                "buildingName" : building.name,
                "floorId" : level.identifier,
                "floorName" : level.name,
                "poiId" : poi.identifier,
                "poiName" : poi.name
            ]
            call.resolve(result)
        }
    }
    
    internal func onPoiDeselected(building: SITBuilding) {
        if let call = self.onPoiDeselectedCall {
            let result: Dictionary = [
                "buildingId" : building.identifier,
                "buildingName" : building.name,
            ]
            call.resolve(result)
        }
    }
    
    internal func onFloorChanged(from: SITFloor, to: SITFloor, building: SITBuilding) {
        if let call = self.onFloorChangedCall {
            let result: Dictionary = [
                "buildingId" : building.identifier,
                "buildingName" : building.name,
                "fromFloorId" : from.identifier,
                "fromFloorName" : from.name,
                "toFloorId" : to.identifier,
                "toFloorName" : to.name
            ]
            call.resolve(result)
        }
    }
        
    internal func onNavigationRequested(navigationResult:Dictionary<String, Any>){
        if let call = self.onNavigationRequestedCallback {
            call.resolve(navigationResult)
        }
    }
    
    internal func onNavigationStarted(navigationResult: Dictionary<String, Any>) {
        if let call = self.onNavigationStartedCallback {
            call.resolve(navigationResult)
        }
    }
    
    internal func onNavigationError(navigationResult:Dictionary<String, Any>){
        if let call = self.onNavigationErrorCallback {
            call.resolve(navigationResult)
        }
    }
    
    internal func onNavigationFinished(navigationResult:Dictionary<String, Any>){
        if let call = self.onNavigationFinishedCallback {
            call.resolve(navigationResult)
        }
        
    }
}

//Needed to find the proper view in the window hierarchy
public class CapMapContainerView:UIView{
    
}

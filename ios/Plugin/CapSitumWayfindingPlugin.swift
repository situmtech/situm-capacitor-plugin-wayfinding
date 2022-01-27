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
    
    private var onPoiSelectedCall: CAPPluginCall?
    private var onPoiDeselectedCall: CAPPluginCall?
    private var onFloorChangedCall: CAPPluginCall?

    public enum CapPluginError: Error {
        case noProperViewHierarchy
    }
    
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
           
            do {
                try self.situmWayFindingWrapper.load(containerView: self.containerView, googleMapView: googleMapView, librarySettings: settingsJsonObject)
                self.situmWayFindingWrapper.delegate = self
                try self.enableHtmlOverMap()
                call.resolve()
                self.bridge?.releaseCall(call)
            }catch CapPluginError.noProperViewHierarchy{
                call.reject("UNEXPECTED ERROR laying views!")
            }catch CapSitumWayfinding.CapSitumWayfindingError.errorLoadingWYF{
                call.reject("UNEXPECTED ERROR loading Situm Wayfinding!")
            }catch CapSitumWayfinding.CapSitumWayfindingError.noSitumCredentials {
                call.reject("SITUM USER OR API key missing!")
            } catch  CapSitumWayfinding.CapSitumWayfindingError.noGoogleMapsApiKey {
                call.reject("GOOGLE MAPS API key missing!")
            }catch {
                call.reject("UNEXPECTED ERROR obtaining credentials!")
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
    
    @objc func internalSetCaptureTouchEvents(_ call: CAPPluginCall){
        // Check if touch events are captura by native view or map..
        self.touchDistributorView?.setIsGesturesAllowed(isGestureAllowed: call.getBool("captureEvents", true))
        call.resolve()
    }
    
    @objc func internalSelectBuilding(_ call: CAPPluginCall){
    }
    
    @objc func internalSelectPoi(_ call: CAPPluginCall){
    }
    
    @objc func internalNavigateToPoi(_ call: CAPPluginCall){
    }
    
    @objc func internalNavigateToLocation(_ call: CAPPluginCall){
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
    
    private func enableHtmlOverMap() throws {
        let scrollView = getViewFromHierarchy(classOfView: UIScrollView.self)
        let mapContainerView = getViewFromHierarchy(classOfView: CapMapContainerView.self)
        if let uScrollView = scrollView, let uMapContainerView = mapContainerView {
            //Move to front to see html overlays above map.
            bridge?.viewController?.view.bringSubviewToFront(uScrollView)
            //Now webView dont let us see map. Make webView transparent
            makeWebViewTransparent()
            //Add transparent view to decide whom should be responsible of touch events
            touchDistributorView = self.addTouchDistributorView(uMapContainerView,webScrollView: uScrollView)
        } else {
            throw(CapPluginError.noProperViewHierarchy)
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
    
    private func addTouchDistributorView(_ mapContainerView:UIView, webScrollView: UIView) -> CapTouchDistributorView{
        let touchDistributorView = CapTouchDistributorView.init(frame: webScrollView.frame)
        touchDistributorView.webScrollView = webScrollView
        self.bridge?.viewController?.view.addSubview(touchDistributorView)
        return touchDistributorView
    }

    // MARK: CapSitumWayfindingNativeToCap methods
    public func onPoiSelected(poi: SITPOI, level: SITFloor, building: SITBuilding) {
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
    
    public func onPoiDeselected(building: SITBuilding) {
        if let call = self.onPoiDeselectedCall {
            let result: Dictionary = [
                "buildingId" : building.identifier,
                "buildingName" : building.name,
            ]
            call.resolve(result)
        }
    }
    
    public func onFloorChanged(from: SITFloor, to: SITFloor, building: SITBuilding) {
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
}

//Needed to find the proper view in the window hierarchy
public class CapMapContainerView:UIView{
    
}

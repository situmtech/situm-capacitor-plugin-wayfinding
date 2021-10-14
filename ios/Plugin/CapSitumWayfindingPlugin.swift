import Foundation
import Capacitor
import GoogleMaps
import SitumWayfinding


/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(CapSitumWayfindingPlugin)
public class CapSitumWayfindingPlugin: CAPPlugin {
    private let implementation = SitumWayfinding()
    private var containerView: UIView?
    private var library: SitumMapsLibrary?
    
    @objc func internalLoad(_ call: CAPPluginCall) {

        DispatchQueue.main.async {

            self.bridge?.saveCall(call)
            let googleMapView:GMSMapView = self.getGMSMapView()!
            self.containerView = self.replaceMapWithContainerView(googleMapView)
            
            do {
                let librarySettings = try CapLibrarySettings.from(call).toWyfLibraySettings(googleMap: googleMapView)

                self.library = SitumMapsLibrary.init(containedBy: self.containerView!, controlledBy: self.containerView!.parentViewController!, withSettings: librarySettings)
                do{
                    try self.library!.load()
                    call.resolve();
                    self.bridge?.releaseCall(call);
                }catch{
                    call.reject("ERROR LOADING WAYFINDING")
                }
            } catch CapLibrarySettings.CapLibrarySettingsMappingError.noSitumCredentials {
                call.reject("SITUM USER OR API key missing!")
            } catch  CapLibrarySettings.CapLibrarySettingsMappingError.noGoogleMapsApiKey {
                call.reject("GOOGLE MAPS API key missing!")
            } catch {
                call.reject("Error obtaining credentials!")
            }
            
        }
    }
    
    private func stopSitumProcesses(){
        if let ulibrary = library{
            ulibrary.stopPositioning()
            ulibrary.stopNavigation()
        }
    }
    
    @objc func internalUnload(_ call: CAPPluginCall) {
        DispatchQueue.main.async {
            if let uContinerView=self.containerView{
                self.stopSitumProcesses()
                uContinerView.removeFromSuperview()
                self.containerView=nil;
                call.resolve()
            }else{
                call.reject("Error obtaining credentials!")
            }
        }
    }
    
    //Needed for Android
    func internalSetOverlays(_ call: CAPPluginCall){
    
    }
    
    private func getGMSMapView() -> GMSMapView?{
        for view:UIView in self.bridge?.viewController?.view.subviews ?? [] {
            if view is GMSMapView{
                return view as? GMSMapView;
            }
        }
        return nil;
    }
    
    // The plugin need the view where the map is going to be presented, not the map itself
    private func replaceMapWithContainerView(_ mapView:GMSMapView)->UIView{
        let view = UIView.init(frame: mapView.frame)
        mapView.parentViewController?.view=view
        return view;
    }
}

private extension UIView {
    var parentViewController: UIViewController? {
        sequence(first: self) { $0.next }
            .first(where: { $0 is UIViewController })
            .flatMap { $0 as? UIViewController }
    }
}

import Foundation
import SitumWayfinding
import Capacitor
import GoogleMaps

@objc public class CapSitumWayfinding: NSObject {
    private var library: SitumMapsLibrary?
    
    public enum CapSitumWayfindingError: Error {
        case noSitumCredentials
        case noGoogleMapsApiKey
        case errorLoadingWYF
    }
    
    public func load(containerView:UIView?, googleMapView:GMSMapView, librarySettings:JSObject) throws{
        let librarySettings = try CapLibrarySettings.from(librarySettings).toWyfLibraySettings(googleMap: googleMapView)
        self.library = SitumMapsLibrary.init(containedBy: containerView!, controlledBy: containerView!.parentViewController!, withSettings: librarySettings)
        do{
            try self.library!.load()
        }catch{
            throw CapSitumWayfindingError.errorLoadingWYF
        }
    }
    
    public func stop(){
        if let ulibrary = library{
            ulibrary.stopPositioning()
            ulibrary.stopNavigation()
        }
    }
}

extension UIView {
    var parentViewController: UIViewController? {
        sequence(first: self) { $0.next }
            .first(where: { $0 is UIViewController })
            .flatMap { $0 as? UIViewController }
    }
}

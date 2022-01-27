import Foundation
import SitumWayfinding
import Capacitor
import GoogleMaps

//Protocol used to propagate the delegates calls from native to CapSitumWayfindingPlugin
public protocol WayfindingNativeToCapProtocol {
    func onPoiSelected(poi: SITPOI, level: SITFloor, building: SITBuilding)
    func onPoiDeselected(building: SITBuilding)
    func onFloorChanged(from:SITFloor, to:SITFloor, building:SITBuilding)

}

@objc public class CapSitumWayfinding: NSObject, OnPoiSelectionListener, OnFloorChangeListener {
    private var library: SitumMapsLibrary?

    public var delegate: WayfindingNativeToCapProtocol?
    
    public enum CapSitumWayfindingError: Error {
        case noSitumCredentials
        case noGoogleMapsApiKey
        case errorLoadingWYF
    }
    
    public func load(containerView:UIView?, googleMapView:GMSMapView, librarySettings:JSObject) throws{
        let librarySettings = try CapLibrarySettings.from(librarySettings).toWyfLibraySettings(googleMap: googleMapView)
        self.library = SitumMapsLibrary.init(containedBy: containerView!, controlledBy: containerView!.parentViewController!, withSettings: librarySettings)
        self.library?.setOnFloorChangeListener(listener: self)
        self.library?.setOnPoiSelectionListener(listener: self)

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

    // MARK: Native Wayfinding delegate methods
    public func onPoiSelected(poi: SITPOI, level: SITFloor, building: SITBuilding) {
        if let del = self.delegate {
            del.onPoiSelected(poi: poi, level: level, building: building)
        }
    }
    
    public func onPoiDeselected(building: SITBuilding) {
        if let del = self.delegate {
            del.onPoiDeselected(building: building)
        }
    }
    
    public func onFloorChanged(from: SITFloor, to: SITFloor, building: SITBuilding) {
        if let del = self.delegate {
            del.onFloorChanged(from: from, to: to, building: building)
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

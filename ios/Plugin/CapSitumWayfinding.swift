import Foundation
import SitumWayfinding
import Capacitor
import GoogleMaps

//Protocol used to propagate the delegates calls from native to CapSitumWayfindingPlugin
protocol WayfindingNativeToCapProtocol {
    func onPoiSelected(poi: SITPOI, level: SITFloor, building: SITBuilding)
    func onPoiDeselected(building: SITBuilding)
    func onFloorChanged(from:SITFloor, to:SITFloor, building:SITBuilding)
}

class CapSitumWayfinding: NSObject, OnPoiSelectionListener, OnFloorChangeListener {
    private var library: SitumMapsLibrary?

    var delegate: WayfindingNativeToCapProtocol?
    
    func load(containerView:UIView?, googleMapView:GMSMapView, librarySettings:JSObject, completion: @escaping (Result<SitumMap, Error>) -> Void){
        do{
            let librarySettings = try CapLibrarySettings.from(librarySettings).toWyfLibraySettings(googleMap: googleMapView)
            self.library = SitumMapsLibrary.init(containedBy: containerView!, controlledBy: containerView!.parentViewController!, withSettings: librarySettings)
            self.library?.setOnFloorChangeListener(listener: self)
            self.library?.setOnPoiSelectionListener(listener: self)
            // We notify the Capacitor module is ready using the resolve of CapSitumWayfindingPlugin load()
            // The native delegation is handled by CapMapReadyListener and propagated to CapSitumWayfindingPlugin using the completion passed as function parameter
            self.library?.setOnMapReadyListener(listener: CapMapReadyListener(withCompletion: completion))
            try self.library!.load()
        }catch{
            completion(.failure(error))
        }
    }
    
    func selectPoi(buildingId:String, poiId:String,completion: @escaping (Result<Void, Error>) -> Void){
        guard let ulibrary = library else{
            completion(.failure(CapWayfindingError.unknownError))
            return
        }
        CapCommunicatonManager.fetchPoi(buildingId: buildingId, poiId: poiId) { result in
            switch result {
            case .success(let poi):
                ulibrary.selectPoi(poi: poi, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
            
        }
    }
    
    func navigateToPoi(buildingId:String, poiId:String, completion: @escaping (Result<Void, Error>) -> Void){
        guard let ulibrary = library else{
            completion(.failure(CapWayfindingError.unknownError))
            return
        }
        CapCommunicatonManager.fetchPoi(buildingId: buildingId, poiId: poiId) { result in
            switch result {
            case .success(let poi):
                ulibrary.navigateToPoi(poi: poi)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    func stop(){
        if let ulibrary = library{
            ulibrary.stopPositioning()
            ulibrary.stopNavigation()
        }
    }

    // MARK: Native Wayfinding delegate methods
    func onPoiSelected(poi: SITPOI, level: SITFloor, building: SITBuilding) {
        if let del = self.delegate {
            del.onPoiSelected(poi: poi, level: level, building: building)
        }
    }
    
    func onPoiDeselected(building: SITBuilding) {
        if let del = self.delegate {
            del.onPoiDeselected(building: building)
        }
    }
    
    func onFloorChanged(from: SITFloor, to: SITFloor, building: SITBuilding) {
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

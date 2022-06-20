import Foundation
import SitumWayfinding
import Capacitor
import GoogleMaps

//Protocol used to propagate the delegates calls from native to CapSitumWayfindingPlugin
protocol WayfindingNativeToCapProtocol {
    func onPoiSelected(poi: SITPOI, level: SITFloor, building: SITBuilding)
    func onPoiDeselected(building: SITBuilding)
    func onFloorChanged(from:SITFloor, to:SITFloor, building:SITBuilding)
    func onNavigationRequested(navigationResult:Dictionary<String, Any>)
    func onNavigationError(navigationResult:Dictionary<String, Any>)
    func onNavigationFinished(navigationResult:Dictionary<String, Any>)
}

class CapSitumWayfinding: NSObject, OnPoiSelectionListener, OnFloorChangeListener {
    private var library: SitumMapsLibrary?

    var delegate: WayfindingNativeToCapProtocol?
    
    func load(containerView:UIView?, librarySettings:LibrarySettings, completion: @escaping (Result<SitumMap, Error>) -> Void){
        self.library = SitumMapsLibrary.init(containedBy: containerView!, controlledBy: containerView!.parentViewController!, withSettings: librarySettings)
        self.library?.setOnFloorChangeListener(listener: self)
        self.library?.setOnPoiSelectionListener(listener: self)
        self.library?.setOnNavigationListener(listener: self)
        do{
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
                //SITCommunication completions return in the main thread thats why we dont need to go to main thread
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
                //SITCommunication completions return in the main thread thats why we dont need to go to main thread
                ulibrary.navigateToPoi(poi: poi)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func navigateToLocation(buildingId:String, floorId:String, latitude:Double,longitude:Double, completion: @escaping (Result<Void, Error>) -> Void){
        guard let ulibrary = library else{
            completion(.failure(CapWayfindingError.unknownError))
            return
        }
        CapCommunicatonManager.fetchFloor(buildingId:buildingId, floorId:floorId) { result in
            switch result {
            case .success(let floor):
            //SITCommunication completions return in the main thread thats why we dont need to go to main thread
                ulibrary.navigateToLocation(floor: floor, lat: latitude, lng: longitude)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    func stopPositioning(){
        if let ulibrary = library{
            DispatchQueue.main.sync{
                ulibrary.stopPositioning()
            }
        }
    }
    
    func stopNavigation(){
        if let ulibrary = library{
            DispatchQueue.main.sync{
                ulibrary.stopNavigation()
            }
        }
    }
    
    func lockCameraToBuilding(buildingId: String) {
        if let ulibrary = library{
            DispatchQueue.main.sync{
                ulibrary.lockCameraToBuilding(buildingId: buildingId) { _ in }
            }
        }
    }
    
    func unlockCameraToBuilding() {
        if let ulibrary = library{
            DispatchQueue.main.sync{
                ulibrary.unlockCamera()
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

extension CapSitumWayfinding:OnNavigationListener{
    //MARK: OnNavigationListener delegate methods
    func onNavigationRequested(navigation: Navigation) {
        if let del = self.delegate {
            del.onNavigationRequested(navigationResult: navigation.jsValue)
        }
    }
    
    func onNavigationError(navigation: Navigation, error: Error) {
        if let del = self.delegate {
            del.onNavigationError(navigationResult: navigation.jsValue)
        }
    }
    
    func onNavigationFinished(navigation: Navigation) {
        if let del = self.delegate {
            del.onNavigationFinished(navigationResult: navigation.jsValue)
        }
    }
}

//TODO: Study if it is posible to do this in WYF native or in a specific library to reuse it also in React, Cordova, etc
extension Navigation{
    var jsValue:Dictionary<String, Any>{
        var jsResult = Dictionary<String, Any>()
        var jsNav = Dictionary<String, Any>()
        var jsDest = Dictionary<String, Any>()
        var jsPoint = Dictionary<String, Any>()
        
        //Destination Point
        let destinationPoint = self.destination.point
        jsPoint["latitude"] = destinationPoint.coordinate().latitude
        jsPoint["longitude"] = destinationPoint.coordinate().longitude
        jsPoint["floorId"] = destinationPoint.floorIdentifier
        jsPoint["buildingId"] = destinationPoint.buildingIdentifier
        
        //Destination
        jsDest["category"] =  self.destination.category.jsString
        jsDest["identifier"] = self.destination.identifier
        jsDest["name"] = self.destination.name
        jsDest["point"] = jsPoint
        
        //Navigation
        jsNav["status"] = self.status.jsString
        jsNav["destination"] = jsDest
        
        if case .error(let error) = self.status{
            var jsError = Dictionary<String, Any>()
            jsError["code"] = (error as NSError).code
            jsError["message"] = error.localizedDescription
            jsResult["error"] = jsError
        }
        
        jsResult["navigation"] = jsNav
        return jsResult
    }
}

//TODO: Perform in WYF native to let it be reusable
extension NavigationStatus{
    var jsString:String{
        switch self{
        case .requested:
            return  "REQUESTED"
        case .error(_):
            return "ERROR"
        case .destinationReached:
            return "DESTINATION_REACHED"
        case .canceled:
            return "CANCELED"
        }
    }
}

//TODO: Perform in WYF native to let it be reusable
extension DestinationCategory{
    var jsString:String{
        switch self{
        case .poi(_):
            return "POI"
        case .location(_):
            return "LOCATION"
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

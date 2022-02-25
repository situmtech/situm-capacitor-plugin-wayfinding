//
//  CapCommunicationManager.swift
//  SitumCapacitorPluginWayfinding
//
//  Created by fsvilas on 3/2/22.
//

import Foundation
import SitumSDK

struct CapCommunicatonManager{
    //TODO: Analize to place this part in wyf native and offer methods with ids instead of dowloading them here
    static func fetchPoi(buildingId:String, poiId:String, completion:@escaping (Result<SITPOI, Error>) -> Void){
        SITCommunicationManager.shared().fetchPois(ofBuilding: buildingId, withOptions: nil){ result in
            let pois = result?["results"] as? [SITPOI] ?? []
            guard let poi = pois.first(where: { $0.identifier == poiId}) else{
                completion(.failure(CapWayfindingError.noPoiInBuilding(buildingId: buildingId, poiId: poiId)))
                return
            }
            completion(.success(poi))
        }failure: { error in
            guard let uError = error else{
                completion(.failure(CapWayfindingError.unknownDownloadError))
                return
            }
            completion(.failure(uError))
        }
    }
    
    static func fetchFloor(buildingId:String, floorId:String, completion:@escaping (Result<SITFloor, Error>) -> Void){
        CapCommunicatonManager.fetchBuildingInfo(buildingId: buildingId) { result in
            switch result{
            case .success(let buildinInfo):
                let floor = buildinInfo.floors.first(where:  {$0.identifier==floorId})
                if let ufloor = floor{
                    completion(.success(ufloor))
                }else{
                    completion(.failure(CapWayfindingError.noFloorInBuilding(buildingId: buildingId, floorId: floorId)))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    static func fetchBuildingInfo(buildingId:String, completion:@escaping (Result<SITBuildingInfo, Error>) -> Void){
        SITCommunicationManager.shared().fetchBuildingInfo(buildingId, withOptions: nil) { (mapping: [AnyHashable : Any]?) in
            guard mapping != nil, let buildingInfo = mapping!["results"] as? SITBuildingInfo else{
                completion(.failure(CapWayfindingError.unknownDownloadError))
                return
            }
            completion(.success(buildingInfo))
            return
        } failure: { error in
            guard let uError = error else{
                completion(.failure(CapWayfindingError.unknownDownloadError))
                return
            }
            completion(.failure(uError))
        }
    }
}

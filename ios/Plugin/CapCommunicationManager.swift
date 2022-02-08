//
//  CapCommunicationManager.swift
//  SitumCapacitorPluginWayfinding
//
//  Created by fsvilas on 3/2/22.
//

import Foundation
import SitumSDK

struct CapCommunicatonManager{
    
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
                completion(.failure(CapWayfindingError.unknownPoiDownloadError))
                return
            }
            completion(.failure(uError))
        }
    }
}

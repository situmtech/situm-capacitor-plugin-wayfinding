//
//  WayfindingError.swift
//  SitumCapacitorPluginWayfinding
//
//  Created by fsvilas on 3/2/22.
//

import Foundation

enum CapWayfindingError: Error {
    case noSitumCredentials
    case noGoogleMapsApiKey
    case noProperViewHierarchy
    case unknownDownloadError
    case noPoiInBuilding(buildingId:String, poiId:String)
    case noFloorInBuilding(buildingId:String, floorId:String)
    case unknownError
}

extension CapWayfindingError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .noSitumCredentials:
            return "Situm user or apikey is missing"
        case .noGoogleMapsApiKey:
            return "GoogleMaps apikey is missing"
        case .noProperViewHierarchy:
            return "Unexpected error loading WYF module"
        case .unknownDownloadError:
            return "Unexpected error obtaining dashboard info"
        case .noPoiInBuilding(let buildingId,let poiId):
            return "The poi with id \(poiId) was not found in building with id \(buildingId) "
        case .noFloorInBuilding(let buildingId,let floorId):
            return "The floor with id \(floorId) was not found in building with id \(buildingId) "
        case .unknownError:
            return "Unknown error"
        }
    }
}

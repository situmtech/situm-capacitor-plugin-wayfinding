//
//  CapacitorLibrarySettings.swift
//  SitumCapacitorPluginWayfinding
//
//  Created by fsvilas on 7/10/21.
//

import Foundation
import Capacitor
import SitumWayfinding
import GoogleMaps

public class CapLibrarySettings: NSObject {

    var user:String = ""
    var apiKey:String = ""
    var googleMapsApiKey:String = ""
    var buildingId:String = ""
    var searchViewPlaceholder = ""
    var useDashboardTheme = true
    var userPositionIcon = ""
    var userPositionArrowIcon = ""
    var captureTouchEvents = true
    var useRemoteConfig = true
    var showPoiNames = true
    var showSearchBar = true
    var lockCameraToBuilding = false
    var enablePoiClustering = true
    var maxZoom = -1
    var minZoom = -1
    var initialZoom = -1
    
    public static func from(_ jsonObject: JSObject) throws -> CapLibrarySettings {
        let capacitorLibrarySettings=CapLibrarySettings()
        capacitorLibrarySettings.user = jsonObject["user"]  as? String ?? ""
        capacitorLibrarySettings.apiKey = jsonObject["apiKey"]  as? String ?? ""
        capacitorLibrarySettings.googleMapsApiKey = jsonObject["iosGoogleMapsApiKey"]  as? String ?? ""
        capacitorLibrarySettings.buildingId = jsonObject["buildingId"]  as? String ?? ""
        capacitorLibrarySettings.searchViewPlaceholder = jsonObject["searchViewPlaceholder", default: ""]  as! String
        capacitorLibrarySettings.useDashboardTheme = jsonObject["useDashboardTheme", default: true]  as! Bool
        capacitorLibrarySettings.userPositionIcon = jsonObject["userPositionIcon"]  as? String ?? ""
        capacitorLibrarySettings.userPositionArrowIcon = jsonObject["userPositionArrowIcon"]  as? String ?? ""
        capacitorLibrarySettings.captureTouchEvents = jsonObject["captureTouchEvents", default: true] as! Bool
        capacitorLibrarySettings.useRemoteConfig = jsonObject["useRemoteConfig", default: true] as! Bool
        capacitorLibrarySettings.showPoiNames = jsonObject["showPoiNames", default: true] as! Bool
        capacitorLibrarySettings.showSearchBar = jsonObject["hasSearchView", default: true] as! Bool
        capacitorLibrarySettings.lockCameraToBuilding = jsonObject["lockCameraToBuilding", default: false] as! Bool
        capacitorLibrarySettings.enablePoiClustering = jsonObject["enablePoiClustering", default: false] as! Bool
        capacitorLibrarySettings.maxZoom = jsonObject["maxZoom", default: -1] as! Int
        capacitorLibrarySettings.minZoom = jsonObject["minZoom", default: -1] as! Int
        
        if capacitorLibrarySettings.user.isEmpty || capacitorLibrarySettings.apiKey.isEmpty {
            throw CapWayfindingError.noSitumCredentials
        }
        
        if capacitorLibrarySettings.googleMapsApiKey.isEmpty {
            throw CapWayfindingError.noGoogleMapsApiKey
        }
        
        return capacitorLibrarySettings
    }
    
    public func toWyfLibraySettings(googleMap: GMSMapView) -> LibrarySettings{
        let credentials = Credentials(user: user, apiKey: apiKey, googleMapsApiKey: googleMapsApiKey)
        let librarySettings = LibrarySettings.Builder().setCredentials(credentials: credentials).setGoogleMap(googleMap: googleMap )
            .setBuildingId(buildingId: buildingId)
            .setUseDashboardTheme(useDashboardTheme: useDashboardTheme)
            .setSearchViewPlaceholder(searchViewPlaceholder: searchViewPlaceholder)
            .setUserPositionIcon(userPositionIcon: userPositionIcon)
            .setUserPositionArrowIcon(userPositionArrowIcon: userPositionArrowIcon)
            .setUseRemoteConfig(useRemoteConfig: useRemoteConfig)
            .setShowPoiNames(showPoiNames: showPoiNames)
            .setShowBackButton(showBackButton: false) // In capacitor it does not make sense to show the back button in the navigation bar so it is disabled
            .setShowSearchBar(showSearchBar: showSearchBar)
            .setEnablePoiClustering(enablePoisClustering: enablePoiClustering)
            .setMinZoom(minZoom: minZoom)
            .setMaxZoom(maxZoom: maxZoom)
            .build()
        return librarySettings
    }
}

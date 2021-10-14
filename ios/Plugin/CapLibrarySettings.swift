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
    //var hasSearchView = true
    var useDashboardTheme = true
    
    public enum CapLibrarySettingsMappingError: Error {
        case noSitumCredentials
        case noGoogleMapsApiKey
    }
    
    public static func from(_ call: CAPPluginCall) throws -> CapLibrarySettings {
        let capacitorLibrarySettings=CapLibrarySettings()
        let jsonObject = call.getObject("librarySettings", [:])
        capacitorLibrarySettings.user = jsonObject["user"]  as? String ?? ""
        
        capacitorLibrarySettings.apiKey = jsonObject["apiKey"]  as? String ?? ""
        capacitorLibrarySettings.googleMapsApiKey = jsonObject["iosGoogleMapsApiKey"]  as? String ?? ""
        capacitorLibrarySettings.buildingId = jsonObject["buildingId"]  as? String ?? ""
        //capacitorLibrarySettings.hasSearchView = (jsonObject["hasSearchView"]  as? NSString ?? "").boolValue
        capacitorLibrarySettings.useDashboardTheme = (jsonObject["useDashboardTheme"]  as? NSString ?? "").boolValue
        
        if capacitorLibrarySettings.user.isEmpty || capacitorLibrarySettings.apiKey.isEmpty {
            throw CapLibrarySettingsMappingError.noSitumCredentials
        }
        
        if capacitorLibrarySettings.googleMapsApiKey.isEmpty {
            throw CapLibrarySettingsMappingError.noGoogleMapsApiKey
        }
        
        return capacitorLibrarySettings
    }
    
    public func toWyfLibraySettings(googleMap: GMSMapView) -> LibrarySettings{
        let credentials = Credentials(user: user, apiKey: apiKey, googleMapsApiKey: googleMapsApiKey)
        let librarySettings = LibrarySettings.Builder().setCredentials(credentials: credentials).setGoogleMap(googleMap: googleMap ).setBuildingId(buildingId: buildingId).setUseDashboardTheme(useDashboardTheme: useDashboardTheme).build()
        return librarySettings
        
    }
    
}

//
//  CapMapReadyListener.swift
//  SitumCapacitorPluginWayfinding
//
//  Created by fsvilas on 1/2/22.
//

import Foundation
import SitumWayfinding

//Handles native calls when the map is ready and executes the callback passed at initialization
class CapMapReadyListener:OnMapReadyListener{
    let capLoadCompletion:(Result<SitumMap, Error>) -> Void
    
    init(withCompletion completion:@escaping (Result<SitumMap, Error>) -> Void){
        capLoadCompletion = completion
    }
    
    
    //OnMapReadyListener delegate
    func onMapReady(map: SitumMap) {
        capLoadCompletion(.success(map))
    }
    
    //TODO: when native implements the onErrorMethod add it here
}

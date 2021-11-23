//
//  CapScreenInfo.swift
//  SitumCapacitorPluginWayfinding
//
//  Created by fsvilas on 19/11/21.
//

import Foundation
import Capacitor

public class CapScreenInfo: NSObject {
    
    var mapScreenRect: CapScreenRect?
    var htmlOverlaysRects = Array<CapScreenRect>()
    var pixelRatio:Double = 1.0
    
    public static func from(pixelRatio: Double, screenInfo:JSObject) -> CapScreenInfo {
        let capScreenInfo = CapScreenInfo()
        capScreenInfo.pixelRatio = pixelRatio
        capScreenInfo.mapScreenRect = CapScreenRect.from(screenInfo , pixelRatio: pixelRatio)
        return capScreenInfo
    }
    
    public func add(jsonOverlaysArray:JSArray){
        for jsonHtmlOverlay in jsonOverlaysArray{
            htmlOverlaysRects = Array<CapScreenRect>()
            let htmlOverlay = CapScreenRect.from(jsonHtmlOverlay as! JSObject, pixelRatio: pixelRatio )
            htmlOverlaysRects.append(htmlOverlay)
        }
    }
}

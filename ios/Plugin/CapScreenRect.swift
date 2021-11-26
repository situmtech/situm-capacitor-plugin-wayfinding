//
//  CapScreenRect.swift
//  SitumCapacitorPluginWayfinding
//
//  Created by fsvilas on 19/11/21.
//

import Foundation
import Capacitor


public class CapScreenRect: NSObject {
    
    var bounds:CGRect = CGRect(x: 0,y: 0,width: 0,height: 0)
    
    public static func from(_ jsonObject: JSObject, pixelRatio:Double) -> CapScreenRect {
        let capScreenRect = CapScreenRect()
        let x = jsonObject["x"] as? Double ?? 0
        let y = jsonObject["y"] as? Double ?? 0
        let width = jsonObject["width"] as? Double ?? 0
        let height = jsonObject["height"] as? Double ?? 0
        
        capScreenRect.bounds = CGRect(x: x * pixelRatio, y: y * pixelRatio, width: width * pixelRatio, height: height * pixelRatio)
        return capScreenRect
    }
    
    func point(inside point: CGPoint) -> Bool
    {
        return bounds.contains(point)
    }
    
}

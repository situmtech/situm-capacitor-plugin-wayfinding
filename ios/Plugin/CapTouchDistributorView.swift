//
//  File.swift
//  SitumCapacitorPluginWayfinding
//
//  Created by fsvilas on 22/11/21.
//

import Foundation

// This view captures touch events. It is a transparent view
// Depending on the area of the screen where the event happens it enable or disable events on the WKWebView WKScrollView.
//The events are disabled or enable over WKScrollView because the WKWebView in in the top of the view hierarchy.
//If the touch occurs on the area outside the map or in the html overlays above the map, the WKScrollView events are enabled
//If the touch occurs on the area inside the map where there are no html overlays the WKScrollView events are disabled


//The final view hierarchy is as follow:
//  Capacitor adds a WKWebView
//      This WKWebView has a WKScrollView as a subview
//       Capacitor Google Maps plugin add a GMSMapView as subview of WKWebView
//       SitumWYF substitues this GMSMapView for a normal View and uses the GMSMapView internally


public class CapTouchDistributorView:UIView{
    var webScrollView:UIView? = nil
    var screenInfo: CapScreenInfo?
    var isGestureAllowed: Bool = false
    
    //MARK: Init
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        isOpaque = false
        backgroundColor = UIColor(ciColor: .clear)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        isOpaque = false
        backgroundColor = UIColor(ciColor: .clear)
    }
    
    //MARK: hitTest override
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if shouldTouchEventGoToMap(point){
            webScrollView?.isUserInteractionEnabled = false
        }else{
            webScrollView?.isUserInteractionEnabled = true
        }
        // As we dont want this view to keep events we return nil
        return nil
    }
    
    // MARK: Functions to decide where touch event has happened
    
    func shouldTouchEventGoToMap(_ point: CGPoint) ->Bool{
        if isTouchEventOnMap(point) == true && isTouchEventOnHtmlOverlays(point)==false && self.isGestureAllowed == true {
            return true
        }
        return false
    }
    
    func isTouchEventOnMap(_ point: CGPoint) -> Bool{
        if let mapScreenRect = screenInfo?.mapScreenRect, mapScreenRect.point(inside: point) {
            return true
        }
        return false
    }
    
    func isTouchEventOnHtmlOverlays(_ point: CGPoint) ->Bool{
        if let uScreenInfo=screenInfo{
            return uScreenInfo.htmlOverlaysRects.contains(where:{$0.point(inside:point)})
        }
        return false
    }

    public func setIsGesturesAllowed(isGestureAllowed: Bool) {
        self.isGestureAllowed = isGestureAllowed
    }
    
}

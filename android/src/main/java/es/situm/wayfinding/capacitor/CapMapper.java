package es.situm.wayfinding.capacitor;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.getcapacitor.JSObject;

import es.situm.sdk.model.cartography.Point;
import es.situm.wayfinding.navigation.Destination;
import es.situm.wayfinding.navigation.Navigation;
import es.situm.wayfinding.navigation.NavigationError;

public class CapMapper {
    public static JSObject fromNavigation(@NonNull Navigation navigation, @Nullable NavigationError error) {
        JSObject jsResult = new JSObject();
        JSObject jsNav = new JSObject();
        JSObject jsDest = new JSObject();
        JSObject jsPoint = new JSObject();

        Destination destination = navigation.getDestination();

        // Destination Point:
        Point point = destination.getPoint();
        jsPoint.put("latitude", point.getCoordinate().getLatitude());
        jsPoint.put("longitude", point.getCoordinate().getLongitude());
        jsPoint.put("floorId", point.getFloorIdentifier());
        jsPoint.put("buildingId", point.getBuildingIdentifier());

        // Destination
        jsDest.put("category", destination.getCategory());
        jsDest.put("identifier", destination.getIdentifier());
        jsDest.put("name", destination.getName());
        jsDest.put("point", jsPoint);

        // Navigation:
        jsNav.put("status", navigation.getStatus());
        jsNav.put("destination", jsDest);

        // Result:
        jsResult.put("navigation", jsNav);
        if (error != null) {
            JSObject err = new JSObject();
            err.put("code", error.getCode());
            err.put("message", error.getMessage());
            jsResult.put("error", err);
        }
        return jsResult;
    }
}

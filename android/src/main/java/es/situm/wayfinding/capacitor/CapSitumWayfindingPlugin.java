package es.situm.wayfinding.capacitor;

import android.annotation.SuppressLint;
import android.graphics.Rect;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;

import androidx.appcompat.app.AppCompatActivity;

import com.getcapacitor.JSObject;
import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;
import com.google.android.gms.maps.MapView;
import com.hemangkumar.capacitorgooglemaps.CapacitorGoogleMaps;
import com.hemangkumar.capacitorgooglemaps.CustomMapView;

import org.json.JSONException;

import java.lang.reflect.Field;
import java.util.Map;

import es.situm.sdk.model.cartography.Building;
import es.situm.sdk.model.cartography.Floor;
import es.situm.sdk.model.cartography.Poi;
import es.situm.wayfinding.OnFloorChangeListener;
import es.situm.wayfinding.OnPoiSelectedListener;

@CapacitorPlugin(name = "SitumWayfinding")
public class CapSitumWayfindingPlugin extends Plugin {

    private final CapSitumWayfinding implementation = new CapSitumWayfinding();
    private View libraryTargetView = null;
    private CapScreenInfo screenInfo = null;

    @PluginMethod
    public void internalLoad(PluginCall call) {
        try {
            bridge.saveCall(call);
            final String callbackId = call.getCallbackId();

            AppCompatActivity activity = bridge.getActivity();
            JSObject jsSettings = call.getObject("librarySettings");
            CapLibrarySettings capacitorLibrarySettings = CapLibrarySettings.fromJS(jsSettings);
            capacitorLibrarySettings.activity = activity;
            JSObject jsScreenInfo = call.getObject("screenInfo");
            screenInfo = CapScreenInfo.fromJS(jsScreenInfo);
            String mapId = call.getString("mapId");
            MapView mapView = getMapViewFromNativePlugin(mapId);
            if (mapView == null) {
                throw new IllegalStateException("Could not get MapView from capacitor-googlemaps-native plugin.");
            }
            // Call plugin implementation; on response, resolve/reject and release call:
            implementation.load(mapView, capacitorLibrarySettings, screenInfo, libraryResult -> {
                if (libraryResult.error != null) {
                    call.reject(libraryResult.error);
                    getBridge().releaseCall(callbackId);
                    return;
                }
                libraryTargetView = activity.findViewById(es.situm.maps.library.R.id.situm_maps_library_target);
                setupTouchEventsDispatching();
                JSObject response = new JSObject();
                response.put("loadResult", libraryResult);
                call.resolve(response);
                getBridge().releaseCall(callbackId);
            });

        } catch (Exception poke) {
            poke.printStackTrace();
            call.errorCallback(poke.getMessage());
        }
    }

    @PluginMethod
    public void internalSetOverlays(PluginCall call) {
        try {
            Log.d("ATAG", "Got a call to internalSetOverlays: " + call);
            screenInfo.populateOverlays(call.getArray("overlays"));
            call.resolve();
        } catch (JSONException e) {
            e.printStackTrace();
            call.reject(e.getMessage());
        }
    }

    @SuppressLint("ClickableViewAccessibility")
    private void setupTouchEventsDispatching() {
        // Override CGM event dispatching.
        bridge.getWebView().setOnTouchListener((v, event) -> false);
        // Delegate touch events to our view if necessary.
        this.getActivity().findViewById(R.id.situm_maps_dispatcher).setOnTouchListener((v, event) -> {
            int x = (int) event.getX();
            int y = (int) event.getY();
            // Delegate event to map if event is inside the map rect.
            if (screenInfo.contains(x, y)) {
                // Delegate (also) to WebView if there is a child view in the given point.
                if (screenInfo.overlaysContains(x, y)) {
                    bridge.getWebView().dispatchTouchEvent(event);
                }
                dispatchTouchEventToLibraryView(event);
            } else {
                // Event is outside the map rect, delegate to the WebView.
                bridge.getWebView().dispatchTouchEvent(event);
            }
            // Burn event always.
            return true;
        });
    }

    private void dispatchTouchEventToLibraryView(MotionEvent event) {
        event = MotionEvent.obtain(event);
        Rect offsetViewBounds = new Rect();
        // returns the visible bounds
        libraryTargetView.getDrawingRect(offsetViewBounds);
        // calculates the relative coordinates to the parent
        ViewGroup parentViewGroup = (ViewGroup) bridge.getWebView().getParent();
        parentViewGroup.offsetDescendantRectToMyCoords(libraryTargetView, offsetViewBounds);

        int relativeTop = offsetViewBounds.top;
        int relativeLeft = offsetViewBounds.left;

        // Set location with offset points,
        // because if a map is positioned with a different top and left point than the WebView,
        // that should be accounted for.
        event.setLocation(event.getX() - relativeLeft, event.getY() - relativeTop);

        libraryTargetView.dispatchTouchEvent(event);
    }

    private MapView getMapViewFromNativePlugin(String mapId) throws NoSuchFieldException, IllegalAccessException {
        // TODO: make mapview accessible.
        CapacitorGoogleMaps mapsPlugin = (CapacitorGoogleMaps) bridge.getPlugin("CapacitorGoogleMaps").getInstance();
        Field customMapViewsField = CapacitorGoogleMaps.class.getDeclaredField("customMapViews");
        customMapViewsField.setAccessible(true);
        Map customMapViews = (Map) customMapViewsField.get(mapsPlugin);
        CustomMapView customMapView = (CustomMapView) customMapViews.get(mapId);
        Field mapViewField = CustomMapView.class.getDeclaredField("mapView");
        mapViewField.setAccessible(true);
        MapView mapView = (MapView) mapViewField.get(customMapView);
        Log.d("ATAG", "I have a MapView: " + mapView);
        return mapView;
    }

    private MapView getMapViewFromViewsHierarchy() {
        // TODO: avoid accessing private methods but ignores mapId:
        ViewGroup wvParent = (ViewGroup) bridge.getWebView().getParent();
        int totalChildren = wvParent.getChildCount();
        for (int i = 0; i < totalChildren; i++) {
            View v = wvParent.getChildAt(i);
            if (v instanceof MapView) {
                Log.d("ATAG", "I have a MapView again!!!: " + v);
                return (MapView) v;
            }
        }
        return null;
    }

    @PluginMethod
    public void internalUnload(PluginCall call) {
        try {
            implementation.unload((ViewGroup) bridge.getWebView().getParent());
            call.resolve();
        } catch (IllegalStateException e) {
            call.reject(e.getMessage());
        }
    }

    @PluginMethod(returnType = PluginMethod.RETURN_CALLBACK)
    public void internalSetOnPoiSelectedListener(PluginCall call) {
        call.setKeepAlive(true);
        final String callbackId = call.getCallbackId();
        implementation.setOnPoiSelectedListener(new OnPoiSelectedListener() {
            @Override
            public void onPOISelected(Poi poi, Floor floor, Building building) {
                JSObject result = new JSObject();
                result.put("key", "onPoiSelected");
                result.put("buildingId", building.getIdentifier());
                result.put("buildingName", building.getName());
                result.put("floorId", floor.getIdentifier());
                result.put("floorName", floor.getName());
                result.put("poiId", poi.getIdentifier());
                result.put("poiName", poi.getName());
                resultForCallbackId(callbackId, result);
            }

            @Override
            public void onPoiDeselected(Building building) {
                JSObject result = new JSObject();
                result.put("key", "onPoiDeselected");
                result.put("buildingId", building.getIdentifier());
                result.put("buildingName", building.getName());
                resultForCallbackId(callbackId, result);
            }
        });
    }

    @PluginMethod(returnType = PluginMethod.RETURN_CALLBACK)
    public void internalSetOnFloorChangeListener(PluginCall call) {
        call.setKeepAlive(true);
        final String callbackId = call.getCallbackId();
        implementation.setOnFloorSelectedListener((from, to, building) -> {
            JSObject result = new JSObject();
            result.put("key", "onFloorChanged");
            result.put("buildingId", building.getIdentifier());
            result.put("buildingName", building.getName());
            result.put("fromFloorId", from.getIdentifier());
            result.put("toFloorId", to.getIdentifier());
            result.put("fromFloorName", from.getName());
            result.put("toFloorName", to.getName());
            resultForCallbackId(callbackId, result);
        });
    }


    private void resultForCallbackId(String callbackId, JSObject result) {
        PluginCall call = bridge.getSavedCall(callbackId);
        call.resolve(result);
    }
}
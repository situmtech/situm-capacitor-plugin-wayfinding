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
import es.situm.wayfinding.OnPoiSelectionListener;
import es.situm.wayfinding.navigation.Navigation;
import es.situm.wayfinding.navigation.NavigationError;
import es.situm.wayfinding.navigation.OnNavigationListener;

@CapacitorPlugin(name = "SitumWayfinding")
public class CapSitumWayfindingPlugin extends Plugin {

    private final CapSitumWayfinding implementation = new CapSitumWayfinding();
    private View libraryTargetView = null;
    private CapScreenInfo screenInfo = null;
    private boolean captureTouchEvents = false;

    // Keep alive callbacks:
    private String onPoiSelectedCallbackId = null;
    private String onPoiDeselectedCallbackId = null;

    // WYF Android uses a single listener for both onPoiSelected and onPoiDeselected:
    private final OnPoiSelectionListener onPoiSelectionListener = new OnPoiSelectionListener() {
        @Override
        public void onPoiSelected(Poi poi, Floor floor, Building building) {
            if (onPoiSelectedCallbackId != null) {
                JSObject result = new JSObject();
                result.put("buildingId", building.getIdentifier());
                result.put("buildingName", building.getName());
                result.put("floorId", floor.getIdentifier());
                result.put("floorName", floor.getName());
                result.put("poiId", poi.getIdentifier());
                result.put("poiName", poi.getName());
                resultForCallbackId(onPoiSelectedCallbackId, result);
            }
        }

        @Override
        public void onPoiDeselected(Building building) {
            if (onPoiDeselectedCallbackId != null) {
                JSObject result = new JSObject();
                result.put("buildingId", building.getIdentifier());
                result.put("buildingName", building.getName());
                resultForCallbackId(onPoiDeselectedCallbackId, result);
            }
        }
    };

    // Keep alive callbacks:
    private String onNavigationRequestedCallbackId = null;
    private String onNavigationErrorCallbackId = null;
    private String onNavigationFinishedCallbackId = null;

    private final OnNavigationListener onNavigationListener = new OnNavigationListener() {
        @Override
        public void onNavigationRequested(Navigation navigation) {
            if (onNavigationRequestedCallbackId != null) {
                JSObject jsNav = CapMapper.fromNavigation(navigation, null);
                resultForCallbackId(onNavigationRequestedCallbackId, jsNav);
            }
        }

        @Override
        public void onNavigationStarted(Navigation navigation) {
            // TODO: add navigationStarted callback.
        }

        @Override
        public void onNavigationError(Navigation navigation, NavigationError error) {
            if (onNavigationErrorCallbackId != null) {
                JSObject jsNav = CapMapper.fromNavigation(navigation, error);
                resultForCallbackId(onNavigationErrorCallbackId, jsNav);
            }
        }

        @Override
        public void onNavigationFinished(Navigation navigation) {
            if (onNavigationFinishedCallbackId != null) {
                JSObject jsNav = CapMapper.fromNavigation(navigation, null);
                resultForCallbackId(onNavigationFinishedCallbackId, jsNav);
            }
        }
    };

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
                implementation.setOnPoiSelectionListener(onPoiSelectionListener);
                implementation.setOnNavigationListener(onNavigationListener);
                setupTouchEventsDispatching();
                JSObject response = new JSObject();
                response.put("loadResult", libraryResult);
                response.put("status", "SUCCESS");
                this.captureTouchEvents = capacitorLibrarySettings.captureTouchEvents;
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
            if (captureTouchEvents && screenInfo.contains(x, y)) {
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
    public void internalOnPoiSelected(PluginCall call) {
        call.setKeepAlive(true);
        if (onPoiSelectedCallbackId != null) {
            releaseCallbackById(onPoiSelectedCallbackId);
        }
        onPoiSelectedCallbackId = call.getCallbackId();
    }

    @PluginMethod(returnType = PluginMethod.RETURN_CALLBACK)
    public void internalOnPoiDeselected(PluginCall call) {
        call.setKeepAlive(true);
        if (onPoiDeselectedCallbackId != null) {
            releaseCallbackById(onPoiDeselectedCallbackId);
        }
        onPoiDeselectedCallbackId = call.getCallbackId();
    }

    @PluginMethod(returnType = PluginMethod.RETURN_CALLBACK)
    public void internalOnFloorChange(PluginCall call) {
        call.setKeepAlive(true);
        final String callbackId = call.getCallbackId();
        implementation.setOnFloorChangeListener((from, to, building) -> {
            JSObject result = new JSObject();
            result.put("key", "onFloorChanged");
            result.put("buildingId", building.getIdentifier());
            result.put("buildingName", building.getName());
            result.put("fromFloorId", from.getIdentifier());
            result.put("fromFloorName", from.getName());
            if (to != null) {
                result.put("toFloorId", to.getIdentifier());
                result.put("toFloorName", to.getName());
            }
            resultForCallbackId(callbackId, result);
        });
    }

    @PluginMethod(returnType = PluginMethod.RETURN_NONE)
    public void internalSetCaptureTouchEvents(PluginCall call) {
        captureTouchEvents = call.getBoolean("captureEvents", true);
        call.resolve();
    }

    @PluginMethod(returnType = PluginMethod.RETURN_NONE)
    public void internalSelectBuilding(PluginCall call) {
        final String buildingId = call.getString("id", null);
        if (buildingId != null) {
            implementation.centerBuilding(buildingId, new CapSitumWayfinding.Callback<Building>() {
                @Override
                public void onSuccess(Building result) {
                    call.resolve();
                }

                @Override
                public void onError(String message) {
                    call.reject(message);
                }
            });
        } else {
            call.reject("Building id property required.");
        }
    }

    @PluginMethod(returnType = PluginMethod.RETURN_NONE)
    public void internalSelectPoi(PluginCall call) {
        final String buildingId = call.getString("buildingId", null);
        final String poiId = call.getString("id", null);
        if (buildingId != null && poiId != null) {
            implementation.centerPoi(buildingId, poiId, new CapSitumWayfinding.Callback<Poi>() {
                @Override
                public void onSuccess(Poi result) {
                    call.resolve();
                }

                @Override
                public void onError(String message) {
                    call.reject(message);
                }
            });
        } else {
            call.reject("Both id and buildingId properties required.");
        }
    }

    @PluginMethod(returnType = PluginMethod.RETURN_NONE)
    public void internalNavigateToPoi(PluginCall call) {
        final String buildingId = call.getString("buildingId", null);
        final String poiId = call.getString("id", null);
        if (buildingId != null && poiId != null) {
            implementation.navigateToPoi(buildingId, poiId, new CapSitumWayfinding.Callback<Poi>() {
                @Override
                public void onSuccess(Poi result) {
                    call.resolve();
                }

                @Override
                public void onError(String message) {
                    call.reject(message);
                }
            });
        } else {
            call.reject("Both id and buildingId properties required.");
        }
    }

    @PluginMethod(returnType = PluginMethod.RETURN_NONE)
    public void internalNavigateToLocation(PluginCall call) {
        final String buildingId = call.getString("buildingId", null);
        final String floorId = call.getString("floorId", null);
        final Double latitude = call.getDouble("latitude");
        final Double longitude = call.getDouble("longitude");
        if (buildingId != null && floorId != null && latitude != null && longitude != null) {
            implementation.navigateToLocation(buildingId, floorId, latitude, longitude);
            call.resolve();
        } else {
            call.reject("Required parameters: buildingId, floorId, latitude, longitude.");
        }
    }

    @PluginMethod(returnType = PluginMethod.RETURN_NONE)
    public void internalStopPositioning(PluginCall call) {
        implementation.stopPositioning();
    }

    @PluginMethod(returnType = PluginMethod.RETURN_NONE)
    public void internalStopNavigation(PluginCall call) {
        implementation.stopNavigation();
    }

    @PluginMethod(returnType = PluginMethod.RETURN_CALLBACK)
    public void internalOnNavigationRequested(PluginCall call) {
        call.setKeepAlive(true);
        if (onNavigationRequestedCallbackId != null) {
            releaseCallbackById(onNavigationRequestedCallbackId);
        }
        onNavigationRequestedCallbackId = call.getCallbackId();
    }

    @PluginMethod(returnType = PluginMethod.RETURN_CALLBACK)
    public void internalOnNavigationError(PluginCall call) {
        call.setKeepAlive(true);
        if (onNavigationErrorCallbackId != null) {
            releaseCallbackById(onNavigationErrorCallbackId);
        }
        onNavigationErrorCallbackId = call.getCallbackId();
    }

    @PluginMethod(returnType = PluginMethod.RETURN_CALLBACK)
    public void internalOnNavigationFinished(PluginCall call) {
        call.setKeepAlive(true);
        if (onNavigationFinishedCallbackId != null) {
            releaseCallbackById(onNavigationFinishedCallbackId);
        }
        onNavigationFinishedCallbackId = call.getCallbackId();
    }

    private void releaseCallbackById(String callbackId) {
        PluginCall call = bridge.getSavedCall(callbackId);
        if (call != null && call.isKeptAlive()) {
            call.release(bridge);
        }
    }

    private void resultForCallbackId(String callbackId, JSObject result) {
        PluginCall call = bridge.getSavedCall(callbackId);
        call.resolve(result);
    }

}

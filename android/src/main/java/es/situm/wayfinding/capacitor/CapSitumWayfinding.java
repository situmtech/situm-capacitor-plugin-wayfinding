package es.situm.wayfinding.capacitor;

import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.appcompat.app.AppCompatActivity;

import com.getcapacitor.PluginCall;
import com.google.android.gms.maps.MapView;
import com.hemangkumar.capacitorgooglemaps.CustomMapView;

import es.situm.sdk.SitumSdk;
import es.situm.sdk.error.Error;
import es.situm.sdk.model.cartography.Building;
import es.situm.sdk.model.cartography.BuildingInfo;
import es.situm.sdk.model.cartography.Floor;
import es.situm.sdk.model.cartography.Poi;
import es.situm.sdk.utils.Handler;
import es.situm.wayfinding.LibrarySettings;
import es.situm.wayfinding.OnFloorChangeListener;
import es.situm.wayfinding.OnPoiSelectedListener;
import es.situm.wayfinding.SitumMapsLibrary;
import es.situm.wayfinding.SitumMapsListener;

public class CapSitumWayfinding {

    private SitumMapsLibrary library;

    public void load(MapView mapView, CapLibrarySettings capacitorLibrarySettings, CapScreenInfo screenInfo, SitumWayfindingCallback callback) {
        Log.d("ATAG", "Load method was called!!!");
        AppCompatActivity activity = capacitorLibrarySettings.activity;
        activity.runOnUiThread(() -> {
            // Prepare:
            ViewGroup mapViewParent = (ViewGroup) mapView.getParent();
            int index = mapViewParent.indexOfChild(mapView);
            ViewGroup.LayoutParams params = mapView.getLayoutParams();
            mapViewParent.removeView(mapView);
            // Inflate and insert the brand new view:
            LayoutInflater inflater = LayoutInflater.from(activity);
            int layout = activity.getResources().getIdentifier("sitummap_creator_layout", "layout", activity.getPackageName());
            View rootView = inflater.inflate(layout, mapViewParent, false);
            rootView.setLayoutParams(params);
            mapViewParent.addView(rootView, index);
            // Inflate and insert a view for event dispatching:
            int dispatcherLayout = activity.getResources().getIdentifier("sitummap_dispatcher_layout", "layout", activity.getPackageName());
            View dispatcherView = inflater.inflate(dispatcherLayout, mapViewParent, false);
            mapViewParent.addView(dispatcherView);
            // Bring this view to the front so we can use it to delegate touch events appropriately.
            dispatcherView.bringToFront();
            // Use that view as WYF target:
            LibrarySettings settings = capacitorLibrarySettings.toLibrarySettings();
            settings.setGoogleMap(mapView);
            library = new SitumMapsLibrary(es.situm.maps.library.R.id.situm_maps_library_target, activity, settings);
            CapLibraryLoadResult result = new CapLibraryLoadResult();
            library.setSitumMapsListener(new SitumMapsListener() {
                @Override
                public void onSuccess() {
                    result.library = library;
                    callback.onLoadResult(result);
                    onLoadSuccess(library, capacitorLibrarySettings);
                }

                @Override
                public void onError(int error) {
                    result.error = "Error loading SitumMapsLibrary, error code is " + error;
                }
            });
            library.load();
        });
    }

    private void onLoadSuccess(SitumMapsLibrary library, CapLibrarySettings capacitorLibrarySettings) {
        if (capacitorLibrarySettings.hasBuildingId()) {
            // TODO: decide one building mode vs center building.
            SitumSdk.communicationManager().fetchBuildingInfo(capacitorLibrarySettings.buildingId, new Handler<BuildingInfo>() {
                @Override
                public void onSuccess(BuildingInfo buildingInfo) {
                    library.centerBuilding(buildingInfo.getBuilding());
                }

                @Override
                public void onFailure(Error error) {
                    // TODO: parameter buildingId will be ignored by now.
                    Log.e("ATAG", "Error fetching info for building with ID: " + capacitorLibrarySettings.buildingId);
                }
            });
        }
    }

    public void unload(ViewGroup rootView) throws IllegalStateException {
        if (library == null) {
            throw new IllegalStateException("Called unload() but SitumMapsLibrary is null.");
        }
        rootView.post(() -> {
            library.unload();
            rootView.removeView(rootView.findViewById(es.situm.maps.library.R.id.situm_maps_library_target));
            rootView.removeView(rootView.findViewById(R.id.situm_maps_dispatcher));
            library = null;
        });
    }

    public void setOnPoiSelectedListener(OnPoiSelectedListener listener) {
        library.setOnPoiSelectedListener(listener);
    }

    public void setOnFloorSelectedListener(OnFloorChangeListener listener) {
        library.setOnFloorSelectedListener(listener);
    }

    interface SitumWayfindingCallback {
        void onLoadResult(CapLibraryLoadResult result);
    }
}
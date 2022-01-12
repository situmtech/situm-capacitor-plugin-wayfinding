package es.situm.wayfinding.capacitor;

import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.google.android.gms.maps.MapView;

import java.util.Collection;

import es.situm.sdk.SitumSdk;
import es.situm.sdk.error.Error;
import es.situm.sdk.model.cartography.Building;
import es.situm.sdk.model.cartography.BuildingInfo;
import es.situm.sdk.model.cartography.Poi;
import es.situm.sdk.utils.Handler;
import es.situm.wayfinding.LibrarySettings;
import es.situm.wayfinding.OnFloorChangeListener;
import es.situm.wayfinding.OnPoiSelectedListener;
import es.situm.wayfinding.SitumMapsLibrary;
import es.situm.wayfinding.SitumMapsListener;
import es.situm.wayfinding.actions.ActionsCallback;

public class CapSitumWayfinding {

    private SitumMapsLibrary library;
    private CapLibrarySettings capacitorLibrarySettings;

    public void load(MapView mapView, CapLibrarySettings capacitorLibrarySettings, CapScreenInfo screenInfo, SitumWayfindingCallback callback) {
        Log.d("ATAG", "Load method was called!!!");
        AppCompatActivity activity = capacitorLibrarySettings.activity;
        this.capacitorLibrarySettings = capacitorLibrarySettings;
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
                    if (capacitorLibrarySettings.hasBuildingId()) {
                        // TODO: decide one building mode vs center building.
                        centerBuilding(capacitorLibrarySettings.buildingId, new CommunicationManagerResult<Building>() {
                            @Override
                            public void onSuccess(Building building) {
                                callback.onLoadResult(result);
                            }

                            @Override
                            public void onError(String message) {
                                // Parameter buildingId will be ignored.
                                callback.onLoadResult(result);
                            }
                        });
                    } else {
                        callback.onLoadResult(result);
                    }

                }

                @Override
                public void onError(int error) {
                    result.error = "Error loading SitumMapsLibrary, error code is " + error;
                }
            });
            library.load();
        });
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

    public void centerBuilding(@NonNull String buildingId, @NonNull CommunicationManagerResult<Building> callback) {
        SitumSdk.communicationManager().fetchBuildingInfo(buildingId, new Handler<BuildingInfo>() {
            @Override
            public void onSuccess(BuildingInfo buildingInfo) {
                library.centerBuilding(buildingInfo.getBuilding(), new ActionsCallback() {
                    @Override
                    public void onActionConcluded() {
                        callback.onSuccess(buildingInfo.getBuilding());
                    }
                });
            }

            @Override
            public void onFailure(Error error) {
                callback.onError(error.getMessage());
            }
        });
    }

    public void centerPoi(@NonNull String buildingId, @NonNull String poiId, @NonNull CommunicationManagerResult<Poi> callback) {
        runOnPoi(buildingId, poiId, new CommunicationManagerResult<Poi>() {
            @Override
            public void onSuccess(Poi poi) {
                library.centerPoi(poi, new ActionsCallback() {
                    @Override
                    public void onActionConcluded() {
                        callback.onSuccess(poi);
                    }
                });
            }

            @Override
            public void onError(String message) {
                callback.onError(message);
            }
        });
    }

    public void findRouteToPoi(@NonNull String buildingId, @NonNull String poiId, @NonNull CommunicationManagerResult<Poi> callback) {
        runOnPoi(buildingId, poiId, new CommunicationManagerResult<Poi>() {
            @Override
            public void onSuccess(Poi poi) {
                library.findRouteToPoi(poi);
                callback.onSuccess(poi);
            }

            @Override
            public void onError(String message) {
                callback.onError(message);
            }
        });
    }

    public void findRouteToLocation(@NonNull String buildingId, @NonNull String floorId, double latitude, double longitude) {
        this.capacitorLibrarySettings.activity.runOnUiThread(() ->
                library.findRouteToLocation(buildingId, floorId, latitude, longitude));
    }

    private void runOnPoi(@NonNull String buildingId, @NonNull String poiId, @NonNull CommunicationManagerResult<Poi> callback) {
        // Executes an arbitrary action after fetching a POI, if the given POI id is found.
        SitumSdk.communicationManager().fetchIndoorPOIsFromBuilding(buildingId, new Handler<Collection<Poi>>() {
            @Override
            public void onSuccess(Collection<Poi> pois) {
                for (Poi poi : pois) {
                    if (poiId.equals(poi.getIdentifier())) {
                        library.findRouteToPoi(poi);
                        callback.onSuccess(poi);
                        return;
                    }
                }
                callback.onError("Poi with id=" + poiId + " not found for building with id=" + buildingId);
            }

            @Override
            public void onFailure(Error error) {
                callback.onError(error.getMessage());
            }
        });
    }

    interface SitumWayfindingCallback {
        void onLoadResult(CapLibraryLoadResult result);
    }

    interface CommunicationManagerResult<T> {
        void onSuccess(T result);

        void onError(String message);
    }
}
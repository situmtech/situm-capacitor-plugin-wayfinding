package es.situm.wayfinding.capacitor;

import androidx.annotation.NonNull;

import java.util.Collection;

import es.situm.sdk.SitumSdk;
import es.situm.sdk.error.Error;
import es.situm.sdk.model.cartography.Poi;
import es.situm.sdk.utils.Handler;

public class CapCommunicationManager {

    /**
     * Get a Poi using both Building and Poi identifiers.
     * @param buildingId The building id.
     * @param poiId The POI id.
     * @param callback Callback to handle success/failure.
     */
    public static void fetchPoi(@NonNull String buildingId, @NonNull String poiId, @NonNull Callback<Poi> callback) {
        SitumSdk.communicationManager().fetchIndoorPOIsFromBuilding(buildingId, new Handler<Collection<Poi>>() {
            @Override
            public void onSuccess(Collection<Poi> pois) {
                for (Poi poi : pois) {
                    if (poiId.equals(poi.getIdentifier())) {
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

    interface Callback<T> {
        void onSuccess(T result);

        void onError(String message);
    }
}

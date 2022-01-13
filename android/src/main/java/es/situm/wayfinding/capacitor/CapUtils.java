package es.situm.wayfinding.capacitor;

import androidx.annotation.NonNull;

import java.util.Collection;

import es.situm.sdk.SitumSdk;
import es.situm.sdk.error.Error;
import es.situm.sdk.model.cartography.Poi;
import es.situm.sdk.utils.Handler;
import es.situm.wayfinding.SitumMapsListener;

public class CapUtils {

    private CapUtils() {
        super();
    }

    /**
     * Returns a human readable error message given the error code received from WYF#load().
     * @param errorCode WYF error code.
     * @return Human readable error message.
     */
    public static String loadErrorCodeToMessage(int errorCode) {
        String message;
        switch (errorCode) {
            case SitumMapsListener.Errors.WRONG_CREDENTIALS:
                message = "Wrong credentials";
                break;
            case SitumMapsListener.Errors.CONNECTION_ERROR:
                message = "Connectivity error";
                break;
            case SitumMapsListener.Errors.INVALID_CREDENTIALS:
                message = "Invalid credentials";
                break;
            case SitumMapsListener.Errors.THEME_NOT_DEFINED:
                message = "Dashboard theme not defined";
                break;
            case SitumMapsListener.Errors.ERROR_LOADING_THEME:
                message = "Error loading theme";
                break;
            default:
                message = "error code is " + errorCode;
                break;
        }
        return message;
    }

    /**
     * Executes an arbitrary action after fetching a POI, if the given POI id is found.
     * @param buildingId The building id.
     * @param poiId The POI id.
     * @param callback Callback to handle success/failure.
     */
    public static void runOnPoi(@NonNull String buildingId, @NonNull String poiId, @NonNull CapSitumWayfinding.CommunicationManagerResult<Poi> callback) {
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
}

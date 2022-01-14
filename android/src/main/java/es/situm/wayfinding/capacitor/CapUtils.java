package es.situm.wayfinding.capacitor;

import es.situm.wayfinding.SitumMapsListener;

public class CapUtils {

    private CapUtils() {
        super();
    }

    /**
     * Returns a human readable error message given the error code received from WYF#load().
     *
     * @param errorCode WYF error code.
     * @return Human readable error message.
     */
    public static String getErrorMessage(int errorCode) {
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
}

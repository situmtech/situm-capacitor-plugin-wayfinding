package es.situm.wayfinding.capacitor;

import androidx.appcompat.app.AppCompatActivity;

import com.getcapacitor.JSObject;

import org.json.JSONException;

import es.situm.wayfinding.LibrarySettings;

public class CapLibrarySettings {
    String user;
    String apiKey;
    String dashboardUrl;
    String buildingId;
    Boolean hasSearchView;
    String searchViewPlaceholder;
    Boolean useDashboardTheme;
    String userPositionIcon;
    String userPositionArrowIcon;
    Boolean captureTouchEvents;
    Boolean useRemoteConfig;
    Boolean showPoiNames;
    Boolean lockCameraToBuilding;
    Boolean enablePoiClustering;
    int maxZoom;
    int minZoom;
    int initialZoom;

    AppCompatActivity activity;

    public CapLibrarySettings() {
    }

    public static CapLibrarySettings fromJS(JSObject o) throws JSONException {
        CapLibrarySettings s = new CapLibrarySettings();
        s.user = o.getString("user");
        s.apiKey = o.getString("apiKey");
        if (s.user == null || s.apiKey == null) {
            throw new IllegalArgumentException("'user' and 'apiKey' parameters required to run Situm WYF module.");
        }
        s.dashboardUrl = o.getString("dashboardUrl", "https://dashboard.situm.com");
        s.buildingId = o.getString("buildingId", "-1");
        s.hasSearchView = o.getBoolean("hasSearchView", true);
        s.searchViewPlaceholder = o.getString("searchViewPlaceholder");
        s.useDashboardTheme = o.getBoolean("useDashboardTheme", true);
        s.userPositionIcon = o.getString("userPositionIcon", null);
        s.userPositionArrowIcon = o.getString("userPositionArrowIcon", null);
        s.captureTouchEvents = o.getBoolean("captureTouchEvents", true);
        s.useRemoteConfig = o.getBoolean("useRemoteConfig", true);
        s.showPoiNames = o.getBoolean("showPoiNames", true);
        s.lockCameraToBuilding = o.getBoolean("lockCameraToBuilding", false);
        s.enablePoiClustering = o.getBoolean("enablePoiClustering", true);
        s.maxZoom = o.getInteger("maxZoom", -1);
        s.minZoom = o.getInteger("minZoom", -1);
        s.initialZoom = o.getInteger("initialZoom", -1);
        return s;
    }

    public LibrarySettings toLibrarySettings() {
        LibrarySettings s = new LibrarySettings();
        s.setApiKey(user, apiKey);
        s.setDashboardUrl(dashboardUrl);
        s.setHasSearchView(hasSearchView);
        s.setSearchViewPlaceholder(searchViewPlaceholder);
        s.setUseDashboardTheme(useDashboardTheme);
        s.setUserPositionIcon(userPositionIcon);
        s.setUserPositionArrowIcon(userPositionArrowIcon);
        s.setUseRemoteConfig(useRemoteConfig);
        s.setShowPoiNames(showPoiNames);
        s.setEnablePoiClustering(enablePoiClustering);
        s.setMaxZoom(maxZoom);
        s.setMinZoom(minZoom);
        s.setInitialZoom(initialZoom);
        return s;
    }

    boolean hasBuildingId() {
        return buildingId != null && !"-1".equals(buildingId) && !"".equals(buildingId);
    }
}


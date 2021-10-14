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
        s.useDashboardTheme = o.getBoolean("useDashboardTheme", false);
        return s;
    }

    public LibrarySettings toLibrarySettings() {
        LibrarySettings s = new LibrarySettings();
        s.setApiKey(user, apiKey);
        s.setDashboardUrl(dashboardUrl);
        s.setHasSearchView(hasSearchView);
        s.setSearchViewPlaceholder(searchViewPlaceholder);
        s.setUseDashboardTheme(useDashboardTheme);
        return s;
    }

    boolean hasBuildingId() {
        return buildingId != null && !"-1".equals(buildingId) && !"".equals(buildingId);
    }
}


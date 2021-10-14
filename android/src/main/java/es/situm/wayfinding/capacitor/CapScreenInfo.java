package es.situm.wayfinding.capacitor;

import com.getcapacitor.JSArray;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;

public class CapScreenInfo {

    private CapScreenRect screenRect = new CapScreenRect();
    private Double devicePixelRatio = .0;
    private final List<CapScreenRect> overlays = new CopyOnWriteArrayList<>();

    public static CapScreenInfo fromJS(JSONObject jsObject) throws JSONException {
        CapScreenInfo info = new CapScreenInfo();
        if (jsObject != null) {
            info.screenRect = CapScreenRect.fromJS(jsObject);
            if (jsObject.has("devicePixelRatio")) {
                info.devicePixelRatio = jsObject.getDouble("devicePixelRatio");
                info.screenRect.map(info.devicePixelRatio);
            }
        }
        return info;
    }

    /**
     * This method should be called from the JS side under DOM modifications.
     * @param jsOverlays Array of Rect specs defining areas where the map should also delegate touch
     *                   events to the underlying WebView.
     * @throws JSONException
     */
    public void populateOverlays(JSArray jsOverlays) throws JSONException {
        overlays.clear();
        List<JSONObject> jsOverlaysList = jsOverlays.toList();
        for (JSONObject jsOverlay : jsOverlaysList) {
            CapScreenRect overlay = CapScreenRect.fromJS(jsOverlay);
            overlay.map(devicePixelRatio);
            overlays.add(overlay);
        }
    }

    public boolean contains(int pX, int pY) {
        return screenRect.contains(pX, pY);
    }

    public boolean overlaysContains(int pX, int pY) {
        for (CapScreenRect rect : overlays) {
            if (rect.contains(pX, pY)) {
                return true;
            }
        }
        return false;
    }
}

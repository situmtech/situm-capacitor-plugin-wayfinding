package es.situm.wayfinding.capacitor;

import org.json.JSONException;
import org.json.JSONObject;

public class CapScreenRect {
    Integer width = 0;
    Integer height = 0;
    Integer x = 0;
    Integer y = 0;

    double top;
    double bottom;
    double left;
    double right;

    public static CapScreenRect fromJS(JSONObject jsObject) throws JSONException {
        CapScreenRect rect = new CapScreenRect();
        if (jsObject != null) {
            if (jsObject.has("width")) {
                rect.width = jsObject.getInt("width");
            }
            if (jsObject.has("height")) {
                rect.height = jsObject.getInt("height");
            }
            if (jsObject.has("x")) {
                rect.x = jsObject.getInt("x");
            }
            if (jsObject.has("y")) {
                rect.y = jsObject.getInt("y");
            }
        }
        return rect;
    }

    /**
     * Map the x, y, width and height values to top, bottom, left and right using the given
     * device pixel ratio, which is received from the JS side.
     * @param devicePixelRatio JS device pixel ratio.
     */
    public void map(Double devicePixelRatio) {
        top = y * devicePixelRatio;
        bottom = height * devicePixelRatio + top;
        left = x * devicePixelRatio;
        right = width * devicePixelRatio + left;
    }

    public boolean contains(int pX, int pY) {
        return pX >= left && pX <= right && pY >= top && pY <= bottom;
    }
}

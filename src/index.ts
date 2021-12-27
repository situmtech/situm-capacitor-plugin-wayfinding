import { registerPlugin } from '@capacitor/core';
import { CapacitorGoogleMaps } from '@capacitor-community/capacitor-googlemaps-native';

import type { 
  SitumWayfindingPlugin,
  LibrarySettings,
  WayfindingResult,
  SitumMapOverlay,
  OnPoiSelectedResult,
  OnFloorChangeResult
} from './definitions';

const SitumWayfindingInternal = registerPlugin<SitumWayfindingPlugin>(
  'SitumWayfinding',
  {
    web: () => import('./web').then(m => new m.SitumWayfindingWeb()),
  },
);

class WayfindingTSWrapper {

  helper?: WayfindingHelper;

  async load(element: HTMLElement, librarySettings: LibrarySettings) : Promise<WayfindingResult> {
    element.style.background = '';
    const boundingRect = element.getBoundingClientRect();

    // Capacitor Google Maps initialization:
    await CapacitorGoogleMaps.initialize({
      key: librarySettings.iosGoogleMapsApiKey?.toString(),
      devicePixelRatio: window.devicePixelRatio,
    });

    const result = await CapacitorGoogleMaps.createMap({
      boundingRect: {
        width: Math.round(boundingRect.width),
        height: Math.round(boundingRect.height),
        x: Math.round(boundingRect.x),
        y: Math.round(boundingRect.y),
      },
      cameraPosition: {
        target: {
          latitude: 0,
          longitude: 0,
        },
        zoom: 12,
        bearing: 0,
        tilt: 0
      },
      preferences: {
        gestures: {
          isScrollAllowedDuringRotateOrZoom: false,
          isRotateAllowed: true,
          isScrollAllowed: false,
          isTiltAllowed: true,
          isZoomAllowed: true
        },
        appearance: {
          style: null,
          isMyLocationDotShown: false,
          isBuildingsShown: true,
          isIndoorShown: true,
          isTrafficShown: false,
          type: 1
        },
        controls: {
          isCompassButtonEnabled: false,
          isMapToolbarEnabled: false,
          isMyLocationButtonEnabled: false,
          isZoomButtonsEnabled: false
        },
        minZoom: 2,
        maxZoom: 21,
        liteMode: false,
        padding: 0
      },
    });
    element.setAttribute('data-maps-id', result.googleMap.mapId);
    // END CGM.

    // TODO: probably the CGM dependency should be removed to get a cleaner code.
    // TODO: uncomment if CGM is finally removed:
    // element.setAttribute('data-maps-id', 'situm-wyf');
    // const boundingRect = element.getBoundingClientRect();
    const screenInfo = {
      width: Math.round(boundingRect.width),
      height: Math.round(boundingRect.height),
      x: Math.round(boundingRect.x),
      y: Math.round(boundingRect.y),
      devicePixelRatio: window.devicePixelRatio,
    }
    const loadResponse = await SitumWayfindingInternal.internalLoad({
      mapId: result.googleMap.mapId,
      librarySettings: librarySettings,
      screenInfo: screenInfo
    });
    // Let the native layer know the areas of the screen where the touch events should be
    // dispatched by the webview.
    this.helper = new WayfindingHelper(element);
    this.helper.init();
    return loadResponse;
  }

  async unload(): Promise<any> {
    SitumWayfindingInternal.internalUnload();
    if (this.helper) {
      this.helper.stop();
    }
  }

  async setOnPoiSelectedListener(callback: (data: OnPoiSelectedResult) => void) {
    SitumWayfindingInternal.internalSetOnPoiSelectedListener(callback);
  }

  async setOnFloorChangeListener(callback: (data: OnFloorChangeResult) => void) {
    SitumWayfindingInternal.internalSetOnFloorChangeListener(callback);
  }

};

class WayfindingHelper {
  element: HTMLElement;
  resizeObserver: ResizeObserver;
  resizeWorking: Boolean = false;
  mutationObserver: MutationObserver;

  constructor(element: HTMLElement) {
    this.element = element;
    const me = this;
    this.resizeObserver = new ResizeObserver(() => {
      me.onResizeObserved();
    });
    this.mutationObserver = new MutationObserver(() => {
      me.onMutationObserved();
    });
  }

  init() {
    // Update native layer with information about elements that should receive touch events
    // even when they live inside the map area (overlays).
    this.sendSitumOverlays();
    // Observe DOM mutations (node additions/removals, attributes modified, etc) to keep native
    // layer up to date.
    this.observeMutations();
    // Also observe changes in the size of that elements to keep native layer up to date.
    this.observeResize();
  }

  stop() {
    if (this.resizeObserver) {
      this.resizeObserver.disconnect();
    }
    if (this.mutationObserver) {
      this.mutationObserver.disconnect();
    }
  }

  sendSitumOverlays() {
    //let elements: Array<Element> = Array.from(document.getElementsByClassName("situm-map-overlay"));
    const elements: Array<Element> = Array.from(this.element.children);
    const overlays: Array<SitumMapOverlay> = [];
    elements.forEach(element => {
      const boundingRect = element.getBoundingClientRect();
      //TODO: Check why in ios the cast from DOMRect to SitumMapOverlay is not done properly
      const mo: SitumMapOverlay = {
        x: boundingRect.x,
        y: boundingRect.y,
        width: boundingRect.width,
        height: boundingRect.height
      };
      overlays.push(mo);
    });
    SitumWayfindingInternal.internalSetOverlays({
      overlays: overlays
    });
  };

  observeMutations() {
    const config = { attributes: true, childList: true, subtree: true };
    // Start observing the target node for configured mutations
    this.mutationObserver.observe(this.element, config);
  };

  onMutationObserved() {
    this.sendSitumOverlays();
    // Update resizeObserver observed elements.
    this.observeResize();
  };

  observeResize() {
    const elements: Array<Element> = Array.from(this.element.children);
    this.resizeObserver.disconnect();
    elements.forEach(element => {
      this.resizeObserver.observe(element);
    });
  }

  onResizeObserved() {
    // Limit the number of updates due to element resizing to 1 per 100ms, which
    // is enough for this purpose.
    if (!this.resizeWorking) {
      this.resizeWorking = true;
      setTimeout(() => {
        this.sendSitumOverlays();
        this.resizeWorking = false;
      }, 100);
    }
  }
}

const SitumWayfinding = new WayfindingTSWrapper();

export * from './definitions';
export { SitumWayfinding };

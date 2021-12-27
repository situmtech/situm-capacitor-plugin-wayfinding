export type CallbackID = string;
export interface LibrarySettings {
    user: String;
    apiKey: String;
    iosGoogleMapsApiKey: String;
    buildingId : String;
    dashboardUrl: String;
    hasSearchView: Boolean;
    searchViewPlaceholder: String;
    useDashboardTheme: Boolean;
    userPositionIcon?: String;
    userPositionArrowIcon?: String;
}
export interface ScreenInfo {
    devicePixelRatio: Number;
    x: Number;
    y: Number;
    width: Number;
    height: Number;
}
export interface SitumMapOverlay {
    x: Number;
    y: Number;
    width: Number;
    height: Number;
}
export interface SitumMapOverlays {
    overlays: Array<SitumMapOverlay>
}
export interface WayfindingSettings {
    mapId: String;
    librarySettings: LibrarySettings;
    screenInfo: ScreenInfo;
}
export interface WayfindingResult {
}
export interface OnPoiSelectedResult {
    key: String;
    buildingId: String;
    buildingName: String;
    floorId: String;
    floorName: String;
    poiId: String;
    poiName: String;
}
export interface OnFloorChangeResult {
    key: String;
    buildingId: String;
    buildingName: String;
    fromFloorId: String;
    toFloorId: String;
    fromFloorName: String;
    toFloorName: String;
}
export interface CaptureTouchEvents {
    captureEvents: Boolean
}
export interface SitumWayfindingPlugin {
    // The real native call.
    internalLoad(settings: WayfindingSettings): Promise<WayfindingResult>;
    internalSetOverlays(overlays: SitumMapOverlays): Promise<any>;
    internalUnload(): Promise<any>;
    internalSetOnPoiSelectedListener(callback: (data: OnPoiSelectedResult) => void
    ): Promise<CallbackID>;
    internalSetOnFloorChangeListener(callback: (data: OnFloorChangeResult) => void
    ): Promise<CallbackID>;
    internalSetCaptureTouchEvents(options: CaptureTouchEvents): Promise<any>
}

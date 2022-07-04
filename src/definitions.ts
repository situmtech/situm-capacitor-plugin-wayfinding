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
    captureTouchEvents?: Boolean;
    useRemoteConfig?: Boolean;
    showPoiNames?: Boolean;
    lockCameraToBuilding?: Boolean;
    enablePoiClustering?: Boolean;
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
    buildingId: String;
    buildingName: String;
    floorId: String;
    floorName: String;
    poiId: String;
    poiName: String;
}
export interface OnPoiDeselectedResult {
    buildingId: String;
    buildingName: String;
}
export interface OnFloorChangeResult {
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
export interface Poi {
    id: String;
    buildingId: String
}
export interface Building {
    id: String;
}
export interface Point {
    buildingId: String
    floorId: String
    latitude: Number
    longitude: Number
}
export interface Error {
    code: Number
    message: String
}
export interface Destination {
    category: String
    identifier?: String
    name?: String
    point: Point
}
export interface Navigation {
    status: String
    destination: Destination
}
export interface OnNavigationResult{
    navigation: Navigation
    error?: Error
}
export interface SitumWayfindingPlugin {
    // The real native call.
    internalLoad(settings: WayfindingSettings): Promise<WayfindingResult>;
    internalSetOverlays(overlays: SitumMapOverlays): Promise<any>;
    internalUnload(): Promise<any>;
    internalOnPoiSelected(callback: (data: OnPoiSelectedResult) => void): Promise<CallbackID>;
    internalOnPoiDeselected(callback: (data: OnPoiDeselectedResult) => void): Promise<CallbackID>;
    internalOnFloorChange(callback: (data: OnFloorChangeResult) => void): Promise<CallbackID>;
    internalSetCaptureTouchEvents(options: CaptureTouchEvents): Promise<void>
    internalSelectBuilding(building: Building): Promise<void>;
    internalSelectPoi(poi: Poi): Promise<void>;
    internalNavigateToPoi(poi: Poi): Promise<void>;
    internalNavigateToLocation(location: Point): Promise<void>;
    internalStopPositioning(): Promise<void>;
    internalOnNavigationRequested(callback: (data: OnNavigationResult) => void): Promise<CallbackID>;
    internalOnNavigationFinished(callback: (data: OnNavigationResult) => void): Promise<CallbackID>;
    internalOnNavigationError(callback: (data: OnNavigationResult) => void): Promise<CallbackID>;
    internalStopNavigation(): Promise<any>;
}

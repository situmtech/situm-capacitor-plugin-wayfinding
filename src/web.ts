import { WebPlugin } from '@capacitor/core';

import { 
  SitumWayfindingPlugin,
  WayfindingSettings,
  WayfindingResult,
  LibrarySettings,
  SitumMapOverlays,
  OnPoiSelectedListener,
  OnFloorChangeListener
} from './definitions';

export class SitumWayfindingWeb extends WebPlugin implements SitumWayfindingPlugin {

  async load(element: any, librarySettings: LibrarySettings): Promise<WayfindingResult> {
    console.log(`SitumWayfindingPlugin#load() call with params: ${element}, ${librarySettings}`)
    throw this.unimplemented("Not implemented on web.");
  }

  async internalLoad(settings: WayfindingSettings): Promise<WayfindingResult> {
    console.log(`SitumWayfindingPlugin#internalLoad() call with params: ${settings}`)
    throw this.unimplemented("Not implemented on web.");
  }

  async internalSetOverlays(overlays: SitumMapOverlays): Promise<any> {
    console.log(`SitumWayfindingPlugin#internalSetOverlays() call with params: ${overlays}`)
    throw this.unimplemented("Not implemented on web.");
  }

  async internalUnload(): Promise<any> {
    console.log(`SitumWayfindingPlugin#unload() call.`)
    throw this.unimplemented("Not implemented on web.");
  }

  async internalSetOnPoiSelectedListener(callback: OnPoiSelectedListener): Promise<any> {
    console.log(`SitumWayfindingPlugin#setOnPoiSelectedListener() call with params: ${callback}.`)
    throw this.unimplemented("Not implemented on web.");
  }

  async internalSetOnFloorChangeListener(callback: OnFloorChangeListener): Promise<any> {
    console.log(`SitumWayfindingPlugin#setOnFloorSelectedListener() call with params: ${callback}.`)
    throw this.unimplemented("Not implemented on web.");
  }
}

import { WebPlugin } from '@capacitor/core';

import { 
  SitumWayfindingPlugin,
  WayfindingSettings,
  WayfindingResult,
  LibrarySettings,
  SitumMapOverlays,
  OnPoiSelectedResult,
  OnFloorChangeResult,
  CaptureTouchEvents
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

  internalOnPoiSelected(callback: (data: OnPoiSelectedResult) => void): Promise<string> {
    console.log(`SitumWayfindingPlugin#setOnPoiSelectedListener() call with params ${callback}.`)
    throw new Error('Method not implemented.');
  }

  internalOnFloorChange(callback: (data: OnFloorChangeResult) => void): Promise<string> {
    console.log(`SitumWayfindingPlugin#setOnFloorSelectedListener() call with params ${callback}.`)
    throw new Error('Method not implemented.');
  }

  internalSetCaptureTouchEvents(options: CaptureTouchEvents): Promise<any> {
    console.log(`SitumWayfindingPlugin#internalSetCaptureTouchEvents() call with params ${options}.`)
    throw new Error('Method not implemented.');
  }

}

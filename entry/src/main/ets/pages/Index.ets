import { geoLocationManager } from "@kit.LocationKit";
import { BusinessError } from "@kit.BasicServicesKit";
import LocationUtil from "../utils/LocationUtil";

@Entry
@Component
struct Index {
  @State message: string = 'Location Loading...';

  async aboutToAppear() {
    await this.handleLocationPermissions();

  }

  private getCurrentLocation(): Promise<LocationModel> {
    const request: geoLocationManager.SingleLocationRequest = {
      locatingPriority: geoLocationManager.LocatingPriority.PRIORITY_LOCATING_SPEED,
      locatingTimeoutMs: 10000
    };

    return geoLocationManager.getCurrentLocation(request)
      .then((result: geoLocationManager.Location): LocationModel => {
        return {
          lat: result.latitude,
          lon: result.longitude
        } as LocationModel;
      })
      .catch((error: BusinessError) => {
        throw (error instanceof Error ? error : new Error(JSON.stringify(error)));
      });
  }

  async showUserLocation(): Promise<void> {
    this.getCurrentLocation()
      .then(location => {
        this.message = `Lat: ${location.lat.toFixed(5)}\nLon: ${location.lon.toFixed(5)}`;
        console.error('tag', `Lat: ${location.lat.toFixed(5)}\nLon: ${location.lon.toFixed(5)}`)
      })
  }


  async handleLocationPermissions(): Promise<void> {
    try {
      const hasPermissions = await LocationUtil.checkLocationPermissions()

      if (hasPermissions) {
        await this.showUserLocation();
      } else {
        const granted = await LocationUtil.requestLocationPermissions();
        if (granted) {
          await this.showUserLocation();
        }
      }
    } catch (error) {
      console.error(`Error handling permissions: ${JSON.stringify(error)}`);
    }
  }

  build() {
    RelativeContainer() {
      Text(this.message)
        .id('LocationText')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .alignRules({
          center: { anchor: '__container__', align: VerticalAlign.Center },
          middle: { anchor: '__container__', align: HorizontalAlign.Center }
        })
    }
    .height('100%')
    .width('100%')
  }
}

export interface LocationModel {
  lat: number
  lon: number
} 
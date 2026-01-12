import { ble } from '@kit.ConnectivityKit'
import { hilog } from '@kit.PerformanceAnalysisKit'
import { BusinessError } from '@kit.BasicServicesKit'


export interface IBeaconData {
  uuid: string
  major: number
  minor: number
  txPower: number
  rssi: number
}

export class BleManager {
  private static instance: BleManager

  private scanning: boolean = false
  private beaconCallback?: (beacon: IBeaconData) => void

  private constructor() {}


  static getInstance(): BleManager {
    if (!BleManager.instance) {
      BleManager.instance = new BleManager()
    }
    return BleManager.instance
  }


  private readonly scanHandler = (results: Array<ble.ScanResult>): void => {
    results.forEach(result => {
      const beacon = this.parseIBeacon(result.data, result.rssi)
      if (beacon && this.beaconCallback) {
        this.beaconCallback(beacon)
      }
    })
  }


  startScan(): void {
    if (this.scanning) {
      hilog.warn(0, 'BleManager', 'Scan already running')
      return
    }

    ble.off('BLEDeviceFind')
    ble.on('BLEDeviceFind', this.scanHandler)

    const options: ble.ScanOptions = {
      interval: 0,
      dutyMode: ble.ScanDuty.SCAN_MODE_LOW_POWER,
      matchMode: ble.MatchMode.MATCH_MODE_AGGRESSIVE
    }

    try {
      ble.startBLEScan(
        [{ manufactureId: 0x004C }],
        options
      )
      this.scanning = true
      hilog.info(0, 'BleManager', 'BLE scan started')
    } catch (e) {
      this.scanning = false
      const err = e as BusinessError
      hilog.error(
        0,
        'BleManager',
        `BLE scan failed. code=${err.code}`
      )
    }
  }

  stopScan(): void {
    if (!this.scanning) {
      return
    }

    try {
      ble.stopBLEScan()
    } catch {}

    ble.off('BLEDeviceFind')
    this.scanning = false
    hilog.info(0, 'BleManager', 'BLE scan stopped')
  }

  setOnBeaconFoundCallback(
    callback: (beacon: IBeaconData) => void
  ): void {
    this.beaconCallback = callback
  }

  private parseIBeacon(
    buffer: ArrayBuffer,
    rssi: number
  ): IBeaconData | null {
    const data = new Uint8Array(buffer)
    if (data.length < 30) {
      return null
    }

    const isIBeacon =
      data[0] === 0x02 &&
        data[1] === 0x01 &&
        data[4] === 0xff &&
        data[5] === 0x4c &&
        data[6] === 0x00 &&
        data[7] === 0x02 &&
        data[8] === 0x15

    if (!isIBeacon) {
      return null
    }

    const uuid = [
      data.slice(9, 13),
      data.slice(13, 15),
      data.slice(15, 17),
      data.slice(17, 19),
      data.slice(19, 25)
    ]
      .map(part =>
      Array.from(part)
        .map(b => b.toString(16).padStart(2, '0'))
        .join('')
      )
      .join('-')

    const major = (data[25] << 8) | data[26]
    const minor = (data[27] << 8) | data[28]
    const txPower = data[29] << 24 >> 24

    return {
      uuid,
      major,
      minor,
      txPower,
      rssi
    }
  }

  measureDistance(rssi: number, txPower: number): number {
    return Math.pow(10, (txPower - rssi) / 30)
  }
}

export default BleManager

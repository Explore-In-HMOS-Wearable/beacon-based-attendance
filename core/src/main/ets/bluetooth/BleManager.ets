import { ble, bluetooth } from '@kit.ConnectivityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { LogManager } from '../logger/LogManager';

export interface IBeaconData {
  uuid: string;
  major: number;
  minor: number;
  txPower: number;
  rssi: number;
}

export class BleManager {
  private static instance: BleManager;
  private beaconCallback: ((beacon: IBeaconData) => void) | null = null;

  private constructor() {
  }

  public static async getInstance(): Promise<BleManager> {
    if (!BleManager.instance) {
      BleManager.instance = new BleManager();
      await BleManager.instance.init();
    }
    return BleManager.instance;
  }

  private async init(): Promise<void> {
  }

  public async enableBluetooth(): Promise<void> {
    try {
      bluetooth.enableBluetooth();
    } catch (e) {
      hilog.error(0, 'BLE', `Bluetooth enable error: ${JSON.stringify(e)}`);
    }
  }

  public async disableBluetooth(): Promise<void> {
    try {
      bluetooth.disableBluetooth();
    } catch (e) {
      hilog.error(0, 'BLE', `Bluetooth disable error: ${JSON.stringify(e)}`);
    }
  }

  public async startScan(): Promise<void> {
    const state = bluetooth.getState();
    if (state !== bluetooth.BluetoothState.STATE_ON) {
      hilog.error(0, 'BLE', 'Bluetooth is not enabled.');
      return;
    }

    ble.on('BLEDeviceFind', (results: Array<ble.ScanResult>) => {
      results.forEach((result) => {
        const beacon = this.parseIBeaconData(result.data, result.rssi);
        if (beacon && this.beaconCallback) {
          this.beaconCallback(beacon);
        }
      });
    });

    const scanOptions: ble.ScanOptions = {
      interval: 0,
      dutyMode: ble.ScanDuty.SCAN_MODE_LOW_POWER,
      matchMode: ble.MatchMode.MATCH_MODE_AGGRESSIVE,
    };

    try {
      ble.startBLEScan([{ manufactureId: 0x004C }], scanOptions);
      hilog.info(0, 'BLE', 'Scan started successfully.');
    } catch (err) {
      const code = (err as BusinessError).code;
      hilog.error(0, 'BLE', `Scan failed: ${code} - ${JSON.stringify(err)}`);
    }
  }

  public async stopScan(): Promise<void> {
    try {
      ble.stopBLEScan();
      hilog.info(0, 'BLE', 'Scan stopped.');
    } catch (err) {
      hilog.error(0, 'BLE', `Stop scan error: ${(err as BusinessError).code}`);
    }
  }

  public setOnBeaconFoundCallback(callback: (beacon: IBeaconData) => void): void {
    this.beaconCallback = callback;
  }

  private parseIBeaconData(buffer: ArrayBuffer, rssi: number): IBeaconData | null {
    const data = new Uint8Array(buffer);

    if (data.length < 30) {
      return null;
    }

    const isIBeacon =
      data[0] === 0x02 && data[1] === 0x01 &&
        data[4] === 0xFF && data[5] === 0x4C && data[6] === 0x00 &&
        data[7] === 0x02 && data[8] === 0x15;

    if (!isIBeacon) {
      return null;
    }

    const uuidParts: string[] = [];
    for (let i = 9; i < 25; i++) {
      uuidParts.push(data[i].toString(16).padStart(2, '0'));
    }

    const uuid = [
      uuidParts.slice(0, 4).join(''),
      uuidParts.slice(4, 6).join(''),
      uuidParts.slice(6, 8).join(''),
      uuidParts.slice(8, 10).join(''),
      uuidParts.slice(10, 16).join('')
    ].join('-');

    const major = (data[25] << 8) | data[26];
    const minor = (data[27] << 8) | data[28];
    const txPower = data[29] << 24 >> 24;

    return {
      uuid,
      major,
      minor,
      txPower,
      rssi
    };

  }

  measureDistance(rssi: number, txPower: number): number {
    const distance = Math.pow(10, (txPower - rssi) / (10 * 3));
    return distance
  }
}

export default BleManager;

import { PermissionManager, PermissionResult, PermissionType } from 'core/src/main/ets/permission/PermissionManager';
import { SplashState } from '../state/SplashState';
import { common } from '@kit.AbilityKit';
import { LogManager } from 'core/src/main/ets/logger/LogManager';
import { NavigationConstants } from '../constants/NavigationConstants';
import { NavigationManager } from 'core/src/main/ets/navigation/NavigationManager';
import { BleManager } from 'core/src/main/ets/bluetooth/BleManager'

export class SplashViewModel {
  private _state: SplashState = SplashState.initial();
  private listeners: Array<(state: SplashState) => void> = [];
  private readonly TAG = 'SplashViewModel';
  context = getContext(this) as common.UIAbilityContext;

  get state(): SplashState {
    return this._state;
  }

  set state(newState: SplashState) {
    this._state = newState;
    this.notifyListeners();
  }

  addListener(listener: (state: SplashState) => void): void {
    this.listeners.push(listener);
  }

  private notifyListeners(): void {
    this.listeners.forEach(listener => listener(this._state));
  }

  async init(): Promise<void> {
    this.state = this.state.with({ isLoading: true });

    try {
      const bluetoothGranted = await this.requestBluetoothPermission();
      LogManager.info(this.TAG,`bluetooth granted: ${bluetoothGranted}`)

      NavigationManager.getInstance().pageInfos.replacePath({ name: NavigationConstants.dashboard });

    } catch (e) {
      LogManager.error(this.TAG, `init() error: ${JSON.stringify(e)}`);
      this.state = this.state.with({ error: 'İzinler alınırken hata oluştu.' });
    } finally {
      this.state = this.state.with({ isLoading: false });
    }

  }

  private async requestBluetoothPermission(): Promise<PermissionResult> {
    const context = getContext(this) as common.UIAbilityContext;
    return await PermissionManager.getInstance().requestPermission(PermissionType.BLUETOOTH, context);
  }
}

import { PermissionManager, PermissionResult, PermissionType } from 'core/src/main/ets/permission/PermissionManager';
import { SplashState } from '../state/SplashState';
import { common } from '@kit.AbilityKit';
import { LogManager } from 'core/src/main/ets/logger/LogManager';
import { NavigationConstants } from '../constants/NavigationConstants';
import { NavigationManager } from 'core/src/main/ets/navigation/NavigationManager';

export class SplashViewModel {
  private _state: SplashState = SplashState.initial();
  private listeners: Array<(state: SplashState) => void> = [];
  private readonly TAG = 'SplashViewModel';
  context? : common.UIAbilityContext;

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

  async init(context? : common.UIAbilityContext): Promise<void> {
    this.state = this.state.with({ isLoading: true });

    try {
      const bluetoothGranted = await this.requestBluetoothPermission(context);
      LogManager.info(this.TAG, `bluetooth granted: ${bluetoothGranted}`)

      NavigationManager.getInstance().pageInfos.replacePath({ name: NavigationConstants.dashboard });

    } catch (e) {
      LogManager.error(this.TAG, `init() error: ${JSON.stringify(e)}`);
      this.state = this.state.with({ error: 'Permission error' });
    } finally {
      this.state = this.state.with({ isLoading: false });
    }

  }

  private async requestBluetoothPermission(context? : common.UIAbilityContext): Promise<PermissionResult> {
    return await PermissionManager.getInstance().requestPermission(PermissionType.BLUETOOTH, context!);
  }
}

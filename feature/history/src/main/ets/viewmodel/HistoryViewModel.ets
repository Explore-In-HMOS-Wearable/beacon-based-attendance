import { HistoryState } from '../state/HistoryState';
import { StorageManager } from 'core/src/main/ets/storage/StorageManager';
import { AttandanceListModel } from '../model/AttandanceListModel';
import { CacheConstants } from '../constants/CacheConstants';

export class HistoryViewModel {
  private _state: HistoryState = HistoryState.initial();
  private listeners: Array<(state: HistoryState) => void> = [];
  private readonly TAG = 'HistoryViewModel';

  get state(): HistoryState {
    return this._state;
  }

  set state(newState: HistoryState) {
    this._state = newState;
    this.notifyListeners();
  }

  addListener(listener: (state: HistoryState) => void): void {
    this.listeners.push(listener);
  }

  private notifyListeners(): void {
    this.listeners.forEach(listener => listener(this._state));
  }

  async init(): Promise<void> {
    this.state = this.state.with({ isLoading: true });

    const store = StorageManager.getInstance() as StorageManager
    const data = await store.getModelWithExpiry(CacheConstants.attandanceList,
      AttandanceListModel.fromJson) as AttandanceListModel
    this.state = this.state.with({attandanceList: data?.attandanceList})
    this.state = this.state.with({isLoading: false})

  }

}

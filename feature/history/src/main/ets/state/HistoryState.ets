import { AttandanceModel } from '../model/AttandanceModel';
import './IHistoryState'
import { IHistoryState } from './IHistoryState';

export class HistoryState {
  public isLoading: boolean;
  public readonly error?: string;
  public message?: string;
  public attandanceList?: AttandanceModel[];

  constructor(init: IHistoryState) {
    this.isLoading = init.isLoading ?? true;
    this.error = init.error === null ? undefined : init.error;
    this.message = init.message === null ? undefined : init.message;
    this.attandanceList = init.attandanceList ?? []
  }

  with(updates: IHistoryState): HistoryState {
    return new HistoryState({
      isLoading: updates.isLoading ?? this.isLoading,
      error: updates.error === null ? undefined : (updates.error ?? this.error),
      message: updates.message === null ? undefined : (updates.message ?? this.message),
      attandanceList: updates.attandanceList ?? this.attandanceList,
    });
  }

  static initial(): HistoryState {
    return new HistoryState({
      isLoading: false,
      error: null,
      message: '',
      attandanceList: []
    });
  }
}

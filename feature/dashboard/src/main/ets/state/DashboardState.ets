import { AttandanceModel } from '../model/AttandanceModel';
import './IDashboardState'
import { DashboardStateStatus, IDashboardState } from './IDashboardState';

export class DashboardState {
  public isLoading: boolean;
  public readonly error?: string;
  public message?: string;
  public todayAttandance?: AttandanceModel | null;
  public status?: DashboardStateStatus;

  constructor(init: IDashboardState) {
    this.isLoading = init.isLoading ?? true;
    this.error = init.error === null ? undefined : init.error;
    this.message = init.message === null ? undefined : init.message;
    this.todayAttandance = init.todayAttandance ?? null;
    this.status = init.status;
  }

  with(updates: IDashboardState): DashboardState {
    return new DashboardState({
      isLoading: updates.isLoading ?? this.isLoading,
      error: updates.error === null ? undefined : (updates.error ?? this.error),
      message: updates.message === null ? undefined : (updates.message ?? this.message),
      todayAttandance: updates.todayAttandance ?? this.todayAttandance,
      status: updates.status ?? this.status
    });
  }

  static initial(): DashboardState {
    return new DashboardState({
      isLoading: false,
      error: null,
      message: 'Touch',
      todayAttandance: null,
      status: DashboardStateStatus.initial
    });
  }
}

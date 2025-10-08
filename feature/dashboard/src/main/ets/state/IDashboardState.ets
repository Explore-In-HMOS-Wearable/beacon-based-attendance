import { AttandanceModel } from '../model/AttandanceModel';

export enum DashboardStateStatus {
  initial,loading,error,scanning,completed
}

export interface IDashboardState {
  isLoading?: boolean;
  error?: string | null;
  message?: string;
  todayAttandance?: AttandanceModel | null;
  status?: DashboardStateStatus;
}

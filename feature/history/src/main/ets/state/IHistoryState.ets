import { AttandanceModel } from '../model/AttandanceModel';

export interface IHistoryState {
  isLoading?: boolean;
  error?: string | null;
  message?: string;
  attandanceList?: AttandanceModel[]
}

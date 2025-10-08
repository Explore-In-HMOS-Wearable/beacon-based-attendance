import './ISplashState'
import { ISplashState } from './ISplashState';

export class SplashState {
  public isLoading: boolean;
  public readonly error?: string;
  public message?: string;

  constructor(init: ISplashState) {
    this.isLoading = init.isLoading ?? true;
    this.error = init.error === null ? undefined : init.error;
    this.message = init.message === null ? undefined : init.message;
  }

  with(updates: ISplashState): SplashState {
    return new SplashState({
      isLoading: updates.isLoading ?? this.isLoading,
      error: updates.error === null ? undefined : (updates.error ?? this.error),
      message: updates.message === null ? undefined : (updates.message ?? this.message),
    });
  }

  static initial(): SplashState {
    return new SplashState({
      isLoading: false,
      error: null,
      message: '',
    });
  }
}

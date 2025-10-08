import storage from '@ohos.data.storage';
import { BusinessError } from '@kit.BasicServicesKit';
import { BaseModel } from '../base/BaseModel';
import { Duration } from '../base/DurationModel';
import { hilog } from '@kit.PerformanceAnalysisKit';

export interface StorageDataExpiryModel<TJson> {
  data: TJson;
  expireAt: number;
}


interface StorageDataModel {
  data: object;
  expireAt: number;
}


export class StorageManager {
  private static instance: StorageManager;
  private storage?: storage.Storage;

  private constructor() {}

  static async getInstance(): Promise<StorageManager> {
    if (!StorageManager.instance) {
      StorageManager.instance = new StorageManager();
      await StorageManager.instance.init()
    }
    return StorageManager.instance;
  }

  //init
  private async init() {
    const context = getContext(this);
    const path = context.filesDir;
    try {
      this.storage = await storage.getStorage(path);
    } catch (err) {
      console.error('Storage init error:', err);
    }
  }

  async set(key: string, value: string): Promise<void> {
    if (!this.storage) {
      return;
    }
    await this.storage.put(key, value);
  }

  async get(key: string): Promise<string | null> {
    if (!this.storage) {
      return null;
    }

    return new Promise((resolve) => {
      this.storage!.get(key, '', (err: BusinessError | null, value: string) => {
        if (err) {
          console.error('Storage get error:', err.message);
          resolve(null);
        } else {
          resolve(value || null);
        }
      });
    });
  }

  async remove(key: string): Promise<void> {
    if (!this.storage) {
      return;
    }
    await this.storage.delete(key)
  }

  async clear(): Promise<void> {
    if (!this.storage) {
      return;
    }
    await this.storage.clear();
  }

  public async saveModel<T extends BaseModel>(
    key: string,
    model: T
  ): Promise<void> {
    const jsonString = JSON.stringify(model.toJson());

    return new Promise((resolve, reject) => {
      this.storage?.put(String(key), jsonString, (err) => {
        if (err) {
          console.error(`saveModel failed for key: ${key}`, err.message);
          reject(err);
        } else {
          resolve();
        }
      });
    });

  }

  public async saveModelWithExpiry<T extends BaseModel>(
    key: string,
    model: T,
    duration: Duration
  ): Promise<void> {
    const wrapper: StorageDataModel = {
      data: model.toJson(),
      expireAt: Date.now() + duration.inMilliseconds()
    };

    const jsonString = JSON.stringify(wrapper);


    return new Promise((resolve, reject) => {
      this.storage?.put(String(key), jsonString, (err) => {
        if (err) {
          reject(err);
        } else {
          resolve();
        }
      });
    });
  }

  public async getModelWithExpiry<TModel, TJson>(
    key: string,
    fromJson: (json: TJson) => TModel
  ): Promise<TModel | null> {
    return new Promise((resolve) => {
      this.storage?.get(String(key), '', async (err, value) => {
        if (err || !value || typeof value !== 'string') {
          resolve(null);
          return;
        }

        try {
          const parsed: StorageDataExpiryModel<TJson> = JSON.parse(value);
          hilog.info(0,'DashboardViewModel',`expireAt: ${parsed.expireAt} now: ${Date.now()}}`)
          if (Date.now() > parsed.expireAt) {
            //await this.storage?.deleteSync(key)
            resolve(null);
            return;
          }
          resolve(fromJson(parsed.data));

        } catch (e) {
          console.error(`getJson parse error for key: ${key}`, e);
          resolve(null);
        }
      });
    });
  }

  public async getModel<TModel, TJson>(
    key: string,
    fromJson: (json: TJson) => TModel
  ): Promise<TModel | null> {
    return new Promise((resolve) => {
      this.storage?.get(String(key), '', (err, value) => {
        if (err || !value || typeof value !== 'string') {
          resolve(null);
          return;
        }

        try {
          const parsed: TJson = JSON.parse(value);
          resolve(fromJson(parsed));
        } catch (e) {
          console.error(`getModel parse error for key: ${key}`, e);
          resolve(null);
        }
      });
    });
  }

  public async saveJson(key: string, json : object): Promise<void> {
    const jsonString = JSON.stringify(json);
    return new Promise((resolve, reject) => {
      this.storage?.put(key, jsonString, (err) => {
        if (err) {
          console.error(`saveJson failed for key: ${key}`, err.data);
          reject(err);
        } else {
          resolve();
        }
      });
    });
  }

  public async getJson<TModel, TJson>(
    key: string,
    fromJson: (json: TJson) => TModel
  ): Promise<TModel | null> {
    return new Promise((resolve) => {
      this.storage?.get(String(key), '', (err, value) => {
        if (err || !value || typeof value !== 'string') {
          resolve(null);
          return;
        }

        try {
          const parsed: TJson = JSON.parse(value);
          resolve(fromJson(parsed));
        } catch (e) {
          console.error(`getJson parse error for key: ${key}`, e);
          resolve(null);
        }
      });
    });
  }



}

export default StorageManager;

import { BaseModel } from 'core/src/main/ets/base/BaseModel';
import { AttandanceModel, AttandanceModelJson } from './AttandanceModel';

export interface AttandanceListModelJson {
  attandanceList: AttandanceModelJson[];
}

export class AttandanceListModel implements BaseModel {
  attandanceList: AttandanceModel[];

  constructor(attandanceList: AttandanceModel[]) {
    this.attandanceList = attandanceList;
  }

  toJson(): AttandanceListModelJson {
    return {
      attandanceList: this.attandanceList.map(attandanceList => attandanceList.toJson())
    };
  }

  static fromJson(json: AttandanceListModelJson): AttandanceListModel {
    const attandanceList = json.attandanceList.map(attandanceList => AttandanceModel.fromJson(attandanceList));
    return new AttandanceListModel(attandanceList);
  }
}
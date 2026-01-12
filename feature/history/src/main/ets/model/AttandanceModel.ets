import { BaseModel } from 'core/src/main/ets/base/BaseModel';

export interface AttandanceModelJson {
  beaconId: string,
  startDate: Date | null,
  endDate: Date | null
}

export class AttandanceModel implements BaseModel {
  beaconId: string
  startDate: Date | null
  endDate: Date | null

  constructor(
    beaconId: string,
    startDate: Date | null,
    endDate: Date | null,
  ) {
    this.beaconId = beaconId;
    this.startDate = startDate;
    this.endDate = endDate;
  }

  toJson(): AttandanceModelJson {
    return {
      beaconId: this.beaconId,
      startDate: this.startDate,
      endDate: this.endDate
    };
  }

  static fromJson(json: AttandanceModelJson): AttandanceModel {
    return new AttandanceModel(
      json.beaconId,
      json.startDate,
      json.endDate,
    );
  }
}
import { BleManager, IBeaconData } from 'core/src/main/ets/bluetooth/BleManager';
import { DashboardState } from '../state/DashboardState';
import { StorageManager } from 'core/src/main/ets/storage/StorageManager'
import { BusinessError, } from '@kit.BasicServicesKit';
import { common } from '@kit.AbilityKit';
import { CacheConstants } from '../utils/constants/CacheConstants';
import { AttandanceListModel } from '../model/AttandanceListModel';
import { AttandanceModel } from '../model/AttandanceModel';
import { Duration } from 'core/src/main/ets/base/DurationModel';
import { DashboardStateStatus } from '../state/IDashboardState';
import { LogManager } from 'core/src/main/ets/logger/LogManager';


export class DashboardViewModel {
  private _state: DashboardState = DashboardState.initial()
  private listeners: Array<(state: DashboardState) => void> = []
  private readonly TAG: string = 'DashboardViewModel';
  context = getContext(this) as common.UIAbilityContext;

  get state(): DashboardState {
    return this._state
  }

  set state(newState: DashboardState) {
    this._state = newState
    this.notifyListeners()
  }

  addListener(listener: (state: DashboardState) => void) {
    this.listeners.push(listener)
  }

  private notifyListeners() {
    this.listeners.forEach(listener => listener(this._state))
  }

  async init(): Promise<void> {
    this.state = this.state.with({ isLoading: true })
    const storage = await StorageManager.getInstance()
    const currentDate = new Date(Date.now())
    const attandanceToday = await storage.getModelWithExpiry(CacheConstants.attandanceToday, AttandanceModel.fromJson)

    if (attandanceToday != null && attandanceToday.startDate != null &&
      (currentDate.getDay() > attandanceToday.startDate.getDay())) {
      await storage.remove(CacheConstants.attandanceToday)
      this.state = this.state.with({ todayAttandance: null })
    } else {
      this.state = this.state.with({ todayAttandance: attandanceToday })
    }

    this.state = this.state.with({ isLoading: false })
  }

  async onTouch(): Promise<void> {
    if (this.state.status === DashboardStateStatus.scanning) {
      return
    }

    const ble = await BleManager.getInstance()
    const storage = await StorageManager.getInstance()

    let resolved: boolean = false

    ble.setOnBeaconFoundCallback(async (beaconData: IBeaconData) => {
      if (resolved) {
        return
      }

      if (beaconData.uuid === '58304cb1-1df0-43f9-b9ee-4cd4271f8070') {
        resolved = true

        const currentDate = new Date(Date.now())

        const formatDate = (date: Date | string | number | null): string | null => {
          if (!date) {
            return null
          }

          let d: Date
          if (date instanceof Date) {
            d = date
          } else {
            d = new Date(date)
          }
          return `${d.getFullYear()}-${d.getMonth() + 1}-${d.getDate()}`
        }


        const todayKey = formatDate(currentDate)!

        let attandanceToday = await storage.getModelWithExpiry(
          CacheConstants.attandanceToday,
          AttandanceModel.fromJson
        )

        let history = await storage.getModelWithExpiry(
          CacheConstants.attandanceList,
          AttandanceListModel.fromJson
        )
        if (history === null) {

          history = new AttandanceListModel([])
        }
        let list = history.attandanceList ?? []

        // History'de bugüne ait kayıt ara
        let existing = list.find((item) =>
        item.beaconId === beaconData.uuid &&
          formatDate(item.startDate) === todayKey
        )

        LogManager.info(this.TAG, `attandance today beacon id:${attandanceToday?.beaconId}`)

        if (attandanceToday === null || attandanceToday.startDate === null) {

          const data = new AttandanceModel(beaconData.uuid, currentDate, null)

          this.state = this.state.with({
            todayAttandance: data,
            status: DashboardStateStatus.completed,
            message: 'Attendance started!'
          })

          await storage.saveModelWithExpiry(CacheConstants.attandanceToday, data, Duration.days(300))

          if (existing) {
            existing.startDate = currentDate
            existing.endDate = null
          } else {
            list.push(data)
          }
          history.attandanceList = list
          await storage.saveModelWithExpiry(CacheConstants.attandanceList, history, Duration.days(30))

          await ble.stopScan()
          return
        }

        const data = new AttandanceModel(beaconData.uuid, attandanceToday.startDate, currentDate)
        this.state = this.state.with({
          todayAttandance: data,
          status: DashboardStateStatus.completed,
          message: attandanceToday.endDate === null ? 'Attendance completed!' : 'Attendance updated!'
        })

        await storage.saveModelWithExpiry(CacheConstants.attandanceToday, data, Duration.days(1))
        if (existing) {
          existing.endDate = currentDate
        } else {
          list.push(data)
        }
        history.attandanceList = list
        await storage.saveModelWithExpiry(CacheConstants.attandanceList, history, Duration.days(30))

        await ble.stopScan()

        return
      }
    })

    await ble.startScan()
      .then(() => {
        this.state = this.state.with({
          status: DashboardStateStatus.scanning,
          message: 'Scanning'
        })

        setTimeout(() => {
          if (!resolved && this.state.status === DashboardStateStatus.scanning) {
            this.state = this.state.with({
              status: DashboardStateStatus.completed,
              message: 'Not in range',
              isLoading: false
            })
          }
        }, 15000)
      })
      .catch(async (e: BusinessError) => {
        this.state = this.state.with({
          status: DashboardStateStatus.error,
          error: `${e}`
        })
        LogManager.error(this.TAG, `start scan error ${e} / ${e.message}`)
        await ble.stopScan()
      })
  }
}

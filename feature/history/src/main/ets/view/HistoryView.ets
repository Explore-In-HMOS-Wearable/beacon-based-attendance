import { AttandanceModel } from '../model/AttandanceModel'
import { HistoryState } from '../state/HistoryState'
import { HistoryViewModel } from '../viewmodel/HistoryViewModel'

@Component
export struct HistoryView {

  private viewModel: HistoryViewModel = new HistoryViewModel()
  @State state: HistoryState = HistoryState.initial()

  aboutToAppear(): void {
    this.viewModel.addListener((newState: HistoryState) => {
      this.state = newState
    })
    this.viewModel.init()
  }

  private formatDate(date: Date | string | number | null): string {
    if (!date) {
      return '-'
    }

    const d: Date = date instanceof Date ? date : new Date(date)
    const day = d.getDate().toString().padStart(2, '0')
    const month = (d.getMonth() + 1).toString().padStart(2, '0')
    const year = d.getFullYear()
    return `${day}/${month}/${year}`
  }

  private formatTime(date: Date | string | number | null): string {
    if (!date) {
      return '-'
    }

    const d: Date = date instanceof Date ? date : new Date(date)
    const hours = d.getHours().toString().padStart(2, '0')
    const minutes = d.getMinutes().toString().padStart(2, '0')
    const seconds = d.getSeconds().toString().padStart(2, '0')
    return `${hours}:${minutes}:${seconds}`
  }

  build() {
    NavDestination() {
      Column() {
        if (this.state.isLoading) {
          LoadingProgress()
        } else {
          Text('History')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 20 })
            .fontColor(Color.White)

          List() {
            ForEach(this.state.attandanceList, (item: AttandanceModel) => {
              ListItem() {
                Column({ space: 4 }) {
                  Text(this.formatDate(item.startDate))
                    .fontSize(16)
                    .fontWeight(FontWeight.Bold)
                    .fontColor(Color.Red)

                  Text(`Start: ${this.formatTime(item.startDate)}`)
                    .fontSize(14)
                    .fontColor(Color.Black)

                  Text(`End:   ${this.formatTime(item.endDate)}`)
                    .fontSize(14)
                    .fontColor(Color.Black)
                }
                .width('100%')
                .backgroundColor(Color.White)
                .border({
                  width: 1,
                  color: Color.Gray,
                  radius: 12
                })
                .shadow({
                  radius: 8,
                  color: Color.Black,
                  offsetX: 0,
                  offsetY: 2
                })
                .padding(12)
                .margin({ bottom: 12 })
              }
            }, (item: AttandanceModel) => item.startDate?.toString() ?? Date.now().toString())
          }
          .width('100%')
          .height('100%')

        }
      }
      .width('100%')
      .height('100%')
      .padding(20)
      .backgroundColor(Color.Black)
    }
    .hideBackButton(true)
  }
}

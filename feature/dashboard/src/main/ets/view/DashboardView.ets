import { NavigationManager } from 'core/src/main/ets/navigation/NavigationManager'
import { NavigationConstants } from '../utils/constants/NavigationConstants'
import { DashboardState } from '../state/DashboardState'
import { DashboardStateStatus } from '../state/IDashboardState'
import { DashboardViewModel } from '../viewmodel/DashboardViewModel'

@Component
export struct DashboardView {
  private viewModel: DashboardViewModel = new DashboardViewModel()
  @State state: DashboardState = DashboardState.initial()

  aboutToAppear(): void {
    this.viewModel.addListener((newState: DashboardState) => {
      this.state = newState
    })
    this.viewModel.init()
  }

  build() {
    NavDestination() {
      Column() {
        Stack({ alignContent: Alignment.Center }) {
          if (this.state.status === DashboardStateStatus.scanning) {
            Circle()
              .width(190)
              .height(190)
              .strokeWidth(6)
              .stroke(Color.Blue)
              .rotate({ angle: 0 })
              .animation({
                duration: 1000,
                iterations: -1,
                curve: Curve.Linear
              })
          } else {
            Column() {
              Button() {
                Image($r('sys.media.ohos_ic_window_menu_waterfall'))
                  .width(24)
                  .height(24)
              }
              .backgroundColor(Color.White)
              .onClick(() => {
                NavigationManager.getInstance().pageInfos.pushPath({ name: 'history' })
              })
              .margin({ bottom: 14 })
            }

            .width('100%')
            .height('100%')
            .justifyContent(FlexAlign.End)
            .alignItems(HorizontalAlign.Center)
          }

          Button() {
            Text(this.state.message)
              .fontSize(14)
              .fontColor(Color.White)
              .maxLines(3)
              .textAlign(TextAlign.Center)
          }
          .width(150)
          .height(150)
          .backgroundColor(
            this.state.status === DashboardStateStatus.initial ?
            Color.Grey :
              this.state.status === DashboardStateStatus.scanning ?
              Color.Blue :
                this.state.status === DashboardStateStatus.completed ?
                Color.Green :
                  this.state.status === DashboardStateStatus.error ?
                  Color.Red :
                  Color.Red
          )
          .borderRadius(75)
          .onClick(() => {
            if (!(this.state.status === DashboardStateStatus.scanning)) {
              this.viewModel.onTouch()
            }
          })

        }
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor(Color.Black)
    }
    .hideBackButton(true)

  }
}
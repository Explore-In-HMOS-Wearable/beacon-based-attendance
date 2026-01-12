import { SplashState } from '../state/SplashState'
import { SplashViewModel } from '../viewmodel/SplashViewModel'
import { common } from '@kit.AbilityKit'


@Component
export struct SplashView {

  private viewModel : SplashViewModel = new SplashViewModel()
  @State state : SplashState = SplashState.initial()

  aboutToAppear(): void {
    this.viewModel.addListener((newState : SplashState) => {
      this.state = newState
    })
    const uiContext = globalThis.getUIContext?.() as common.UIAbilityContext;

    this.viewModel.init(uiContext)
  }

  build() {
    NavDestination() {
      Column() {
        if (this.state.isLoading) {
          LoadingProgress()
        } else if (this.state.error) {
          Text(this.state.error)
            .fontColor(Color.Red)
            .fontSize(16)
            .textAlign(TextAlign.Center)
            .margin({ top: 20, left: 12, right: 12 })
        } else {
          Text('SmartAd Beacon')
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: 20 })
        }
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .padding({ top: 24, bottom: 24 })
    }.hideBackButton(true)
  }

}
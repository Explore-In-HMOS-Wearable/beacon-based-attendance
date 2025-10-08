import { NavigationManager } from 'core/src/main/ets/navigation/NavigationManager'
import { DashboardView } from 'dashboard/src/main/ets/view/DashboardView'
import { HistoryView } from 'history/src/main/ets/view/HistoryView'
import { SplashView } from 'splash/src/main/ets/view/SplashView'


@Entry
@Component
struct Index {
  @Builder
  routeMap(name: string) {
    if (name === 'splash') {
      SplashView()
    } else if (name === 'dashboard') {
      DashboardView()
    } else if (name === 'history') {
      HistoryView()
    } else {
      HistoryView()
    }
  }

  build() {
    Navigation(NavigationManager.getInstance().pageInfos) {
      SplashView()
    }
    .navDestination(this.routeMap)
    .ignoreLayoutSafeArea()
    .hideTitleBar(true)
    .width('100%')
    .height('100%')
  }
}


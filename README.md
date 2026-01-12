> **Note:** To access all shared projects, get information about environment setup, and view other guides, please visit [Explore-In-HMOS-Wearable Index](https://github.com/Explore-In-HMOS-Wearable/hmos-index).

# Beacon Based Attendance

Beacon Based Attendance is a smartwatch application built with ArkTS and ArkUI on HarmonyOS.  
It enables automatic attendance tracking using beacon technology. When a user approaches a registered beacon, the watch app detects it and records the attendance entry seamlessly.

The app is designed for schools, universities, and workplaces where manual check-ins are replaced with a contactless, secure, and background-enabled attendance system.

# Preview

<div>
  <img src="screenshots/attendance_not_in_range.png" width="24%">
  <img src="screenshots/attendance_scanning.png" width="24%">
  <img src="screenshots/attendance_completed.png" width="24%">
  <img src="screenshots/attendance_history.png" width="24%">
</div>

# Use Cases

1. **School Attendance**: Students can check in automatically when they enter the classroom with their smartwatch.
2. **Workplace Check-in**: Employees’ attendance is recorded by detecting beacon devices installed at office entrances.
3. **Event Management**: Participants automatically register when entering a conference or event hall.
4. **Background Tracking**: Even if the app is not active, beacon scanning can run in the background for reliable attendance.

# Tech Stack

- **Languages**: ArkTS
- **Frameworks**: ArkUI, HarmonyOS 5.1.0(18)
- **Kits Used**:
    - Connectivity Kit (BLE Scanning & Beacon detection)
    - Background Tasks Kit (Keep scanning alive in background)
    - Performance Analysis Kit (Logging with HiLog)
    - Basic Services Kit (Error handling with BusinessError)

# Directory Structure
```
├── core
│   ├── base
│   │     └── BaseModel
│   │     └── DurationModel
│   ├── bluetooth
│   │     └── BleManager
│   ├── logger
│   │     └── LogManager
│   ├── navigation
│   │     └── NavigationManager
│   ├── permission
│   │     └── PermissionManager
│   ├── storage
│   │     └── StorageManager
├── feature
│   ├── dashboard
│   │     └── model
│   │     │     └── AttendanceListModel
│   │     │     └── AttendanceModel
│   │     └── state
│   │     │     └── DashboardState
│   │     │     └── IDashboardState
│   │     └── utils
│   │     │     └── constants
│   │     │     │      └── CacheConstants
│   │     │     │      └── NavigationConstants
│   │     └── view
│   │     │     └── DashboardView
│   │     └── viewModel
│   │           └── DashboardViewModel
│   ├── history
│   │     └── model
│   │     │     └── AttendanceListModel
│   │     │     └── AttendanceModel
│   │     └── constants
│   │     │     └── CacheConstants
│   │     │     └── NavigationConstants
│   │     └── state
│   │     │     └── HistoryState
│   │     │     └── IHistoryState
│   │     └── view
│   │     │     └── HistoryView
│   │     └── viewModel
│   │           └── HistoryViewModel
│   ├── splash
│   │     └── constants
│   │     │     └── NavigationConstants
│   │     └── state
│   │     │     └── SplashState
│   │     │     └── ISplashState
│   │     └── view
│   │     │     └── SplashView
│   │     └── viewModel
│   │           └── SplashViewModel
│   ├─── pages
│   │   └─── Index.ets
```

# Constraints and Restrictions

- Beacon detection depends on **BLE signal strength** (RSSI) and environmental factors.
- The app requires **Bluetooth enabled** on the smartwatch.
- Continuous background scanning may affect **battery consumption**.
- Internet connection is optional; attendance can be stored locally and synced later.

## Supported Devices

- Huawei Watch 5

# License

Beacon Based Attendance is distributed under the terms of the MIT License.
See the [LICENSE](./LICENSE) for more information.

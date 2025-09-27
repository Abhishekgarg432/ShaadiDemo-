
# ShaadiDemo (Shaadi.com)

A SwiftUI demo app that fetches user profiles from the [RandomUser API](https://randomuser.me/),
displays them as cards, and allows the user to Accept or Decline.
Profiles are cached locally with Core Data for offline access.

## 🚀 Features

- SwiftUI UI with card-style profiles
- MVVM architecture with unidirectional data flow
- `async/await` networking (Swift Concurrency)
- Offline-first: Core Data persistence
- Real-time online/offline detection using `NWPathMonitor`
- Error handling with user-facing alerts
- Animated Accept / Decline actions

## 📂 Project Structure

ShaadiDemo/
├── ShaadiDemoApp.swift        # Entry point (@main)
├── ContentView.swift          # Root SwiftUI view
├── ProfileCardView.swift      # Card component
├── ProfilesViewModel.swift    # MVVM ViewModel (business logic)
├── NetworkService.swift       # API layer (RandomUser API)
├── Persistence.swift          # Core Data stack
├── ProfileDetailView.swift    # Destination view
└── README.md                  # This file

# Wafra — Food Surplus Sharing App

Wafra (وفرة) is an open source mobile app that connects restaurants with surplus food to individuals and food banks — at a discounted price, before it goes to waste.

## What is Wafra?

Every day, restaurants prepare more food than they can sell. Instead of throwing it away, Wafra lets them post surplus meals and ingredients at a reduced price. Individuals can browse and reserve nearby listings, and food banks can coordinate bulk pickups for large-scale distribution.

The name *Wafra* (وفرة) means "abundance" in Arabic — the idea being that there is already enough food; it just needs to reach the right people.

## Who is it for?

| Role | What they do |
|---|---|
| **Restaurant** | Post surplus food listings with price, quantity, and pickup window |
| **Individual** | Browse nearby listings and reserve discounted meals |
| **Food Bank** | Discover and bulk-reserve large quantities for distribution |

## Features (in progress)

- Onboarding flow with role selection
- Role-based profile setup (Restaurant, Individual, Food Bank)
- Food listing creation and management for restaurants
- Browsing and reserving surplus listings for individuals
- Bulk reservation for food banks
- Pickup coordination and notifications

## Tech Stack

- **Frontend:** Flutter (Android-first, cross-platform)
- **Language:** Dart
- **Fonts:** Inter via `google_fonts`
- **Min SDK:** Android (primary target)

## Project Structure

```
lib/
├── main.dart
└── screens/
    ├── splash_screen.dart
    ├── onboarding_screen.dart
    ├── signup_screen.dart
    ├── login_screen.dart
    ├── role_selection_screen.dart
    ├── restaurant_profile_screen.dart
    └── individual_profile_screen.dart
```

## Getting Started

### Prerequisites

- Flutter SDK `^3.11.4` — [install guide](https://docs.flutter.dev/get-started/install)
- Android Studio or VS Code with the Flutter extension

### Run the app

```bash
git clone https://github.com/your-username/wafra.git
cd wafra/wafra_frontend
flutter pub get
flutter run
```

## Contributing

Wafra is open source and contributions are welcome. If you want to report a bug, suggest a feature, or submit a pull request, please open an issue first to discuss the change.

## License

This project is open source. License TBD.

# Wafra — Food Surplus Sharing

Wafra (وفرة) is a mobile application that connects restaurants with surplus food to individuals and food banks, reducing food waste and supporting communities.

> The name means *abundance* in Arabic — the idea being that there is already enough food; it just needs to reach the right people.

---

## Roles

| Role | Description |
|---|---|
| **Restaurant** | Post surplus food listings, manage reservations, confirm pickups |
| **Individual** | Browse nearby listings and reserve meals |
| **Food Bank** | Reserve large quantities for bulk distribution |
| **Admin** | Manage users, listings, and support tickets |

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile | Flutter (Dart) |
| Backend | Node.js, Express.js |
| Database | PostgreSQL |
| Auth | JWT |
| Hosting | Railway |

---

## Getting Started

**Prerequisites:** Flutter 3.x and Android Studio or VS Code.

```bash
git clone <repo-url>
cd wafra/wafra_frontend
flutter pub get
flutter run
```

The app connects to a live backend — no local setup required.

**Build APK**

```bash
flutter build apk --release
```

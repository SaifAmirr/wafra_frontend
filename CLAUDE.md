# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.

---

## Project: Wafra — Food Sharing App

Flutter mobile app (food surplus sharing platform). Restaurants post surplus food; individuals and food banks can reserve and pick it up.

### Common Commands

```bash
flutter pub get          # install dependencies
flutter run              # run on connected device/emulator
flutter analyze          # lint (uses flutter_lints)
flutter test             # run tests (lib/test/)
flutter build apk        # build Android APK
```

### Architecture

**Entry point:** `lib/main.dart` → `SplashScreen` (2s delay) → `OnboardingScreen`

**Navigation pattern:** Imperative — `Navigator.pushReplacement` / `pushAndRemoveUntil`. No named routes, no router package. After login, the app calls `GET /users/me` to read `role` and `verification_status`, then pushes the appropriate screen.

**Role-based screens after login:**
- `restaurant` + `approved` → `RestaurantDashboardScreen`
- `food_bank` + `approved` → `FoodBankDashboardScreen`
- `individual` + `approved` → `ExploreScreen`
- `admin` → `AdminDashboardScreen`
- any role + `pending` → `PendingVerificationScreen`

**State management:** Plain `setState` throughout. No provider/bloc/riverpod.

**API layer:** `lib/services/api_service.dart` — singleton (`ApiService.instance`). All HTTP calls go through here. Auth is cookie-based: the token is extracted from the `set-cookie` response header and sent back as `Cookie: token=<value>`. Backend base URL is `http://10.0.2.2:5000` (Android emulator localhost pointing to the host machine).

**Model:** `lib/models/food_listing.dart` — `FoodListing.fromJson()` maps API responses to the UI model and derives visual properties (icon, colors) from the food category string.

**Key dependencies:**
- `google_fonts` — Inter font used throughout
- `http` — all API calls
- `flutter_lints` — lint rules in `analysis_options.yaml`

**Layout constraint:** `main.dart` clamps the app width to 430px via a `builder` wrapper so it looks like a phone on web/desktop.

**Assets:** `assets/images/` — declared in `pubspec.yaml`.

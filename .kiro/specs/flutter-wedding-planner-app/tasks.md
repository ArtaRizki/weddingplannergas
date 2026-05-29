# Implementation Plan: Flutter Wedding Planner App

## Overview

This plan implements a Flutter mobile application for Android that connects to the existing Laravel backend API. The implementation follows a bottom-up approach: first establishing the project structure and design system, then building the data/API layer, followed by feature modules (BLoCs, repositories, screens), and finally wiring everything together with navigation and integration testing.

## Tasks

- [x] 1. Set up Flutter project structure and core dependencies
  - [x] 1.1 Initialize Flutter project and configure dependencies
    - Create Flutter project with `flutter create` targeting Android
    - Configure `pubspec.yaml` with dependencies: `flutter_bloc`, `dio`, `go_router`, `flutter_secure_storage`, `json_serializable`, `build_runner`, `equatable`, `connectivity_plus`
    - Set up directory structure: `lib/core/`, `lib/data/`, `lib/domain/`, `lib/presentation/`, `lib/config/`
    - Configure Android `minSdkVersion: 21` in `android/app/build.gradle`
    - Set application ID and app name "Wedding Planner" in Android manifest
    - _Requirements: 13.1, 13.2, 13.3_

  - [x] 1.2 Implement Neobrutalist design system and theme
    - Create `lib/core/theme/app_theme.dart` with color constants (white #FFFFFF, pink #FF69B4, light pink #FFB6C1, black #000000, dark gray #333333)
    - Create `lib/core/theme/app_typography.dart` with bold sans-serif headings (weight 700+) and regular body text (min 14px)
    - Create `lib/core/widgets/neo_card.dart` — card with 2-4px black border, 3-5px bottom-right offset shadow, 8-12px border radius
    - Create `lib/core/widgets/neo_button.dart` — button with 2-4px black border, pink fill, 3-5px shadow that reduces to 0 on press
    - Create `lib/core/widgets/neo_text_field.dart` — text input with neobrutalist styling
    - Create `lib/core/widgets/neo_bottom_nav_bar.dart` — bottom navigation bar with neobrutalist styling
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5, 11.6, 11.7, 11.8_

  - [x] 1.3 Configure environment and API base URL
    - Create `lib/config/env.dart` with configurable base URL from environment variable
    - Set up Dio `ApiClient` in `lib/data/api/api_client.dart` with base URL, 30-second timeout
    - _Requirements: 1.2, 1.6_

- [x] 2. Implement data layer — models and serialization
  - [x] 2.1 Create Dart data models with JSON serialization
    - Create `lib/data/models/wedding.dart` — Wedding model with `fromJson`/`toJson`
    - Create `lib/data/models/dashboard_data.dart` — DashboardData model
    - Create `lib/data/models/budget.dart` — Budget model with computed remaining and percentage
    - Create `lib/data/models/guest.dart` — Guest model with side and status enums
    - Create `lib/data/models/phase.dart` — Phase model with progress fields
    - Create `lib/data/models/task.dart` — Task model with type, priority, completion fields
    - Create `lib/data/models/vendor.dart` — Vendor model
    - Create `lib/data/models/rundown.dart` — Rundown model
    - Create `lib/data/models/auth_token.dart` — AuthToken model
    - Use `@JsonSerializable()` and `@JsonKey(name:)` for snake_case mapping
    - Run `build_runner` to generate serialization code
    - _Requirements: 1.1_

  - [x]* 2.2 Write property test for model serialization round-trip
    - **Property 1: Model serialization round-trip**
    - **Validates: Requirements 1.1**

  - [x]* 2.3 Write property test for derived numeric computations
    - **Property 4: Derived numeric computations are correct**
    - **Validates: Requirements 3.2, 4.1**

- [x] 3. Implement API client and interceptors
  - [x] 3.1 Implement Auth interceptor and Error interceptor
    - Create `lib/data/api/interceptors/auth_interceptor.dart` — injects Bearer token from secure storage into every authenticated request
    - Create `lib/data/api/interceptors/error_interceptor.dart` — maps HTTP status codes (4xx, 5xx) to user-friendly error messages without exposing technical details, logs status code/endpoint/body to debug console
    - Handle 401 responses by clearing token and emitting unauthenticated status
    - Handle timeout by displaying connection timeout message
    - _Requirements: 1.3, 1.5, 1.6, 2.8_

  - [x]* 3.2 Write property test for HTTP error code mapping
    - **Property 2: HTTP error code to user-friendly message mapping**
    - **Validates: Requirements 1.3**

  - [x]* 3.3 Write property test for auth token injection
    - **Property 3: Auth token injection on authenticated requests**
    - **Validates: Requirements 1.5**

  - [x] 3.4 Implement connectivity monitoring
    - Create `lib/core/network/connectivity_service.dart` using `connectivity_plus`
    - Show offline indicator when no network, disable data submission controls
    - _Requirements: 1.4_

- [x] 4. Implement Authentication module
  - [x] 4.1 Implement AuthRepository and AuthBloc
    - Create `lib/data/repositories/auth_repository.dart` — login (POST `/api/login`), logout (POST `/api/logout`), token storage via `flutter_secure_storage`
    - Create `lib/domain/blocs/auth/auth_bloc.dart` — manages AuthStatus (authenticated/unauthenticated/unknown), handles login attempts, 5-attempt lockout with 60-second cooldown
    - Persist token across app restarts, clear on logout or 401
    - _Requirements: 2.2, 2.5, 2.6, 2.7, 2.8_

  - [x] 4.2 Implement Login screen UI
    - Create `lib/presentation/screens/auth/login_screen.dart`
    - Email input (max 255 chars, valid email format), password input (masked, min 8 chars)
    - Display error for invalid credentials without revealing which field is wrong
    - Retain email on network failure
    - Disable login button for 60s after 5 failed attempts with countdown display
    - Apply neobrutalist styling (NeoCard, NeoButton, NeoTextField)
    - _Requirements: 2.1, 2.3, 2.4, 2.5_

- [x] 5. Checkpoint - Ensure core infrastructure works
  - Ensure all tests pass, ask the user if questions arise.

- [x] 6. Implement Dashboard module
  - [x] 6.1 Implement DashboardRepository and DashboardBloc
    - Create `lib/data/repositories/dashboard_repository.dart` — GET `/api/dashboard`
    - Create `lib/domain/blocs/dashboard/dashboard_bloc.dart` — LoadDashboard event, states: loading/loaded/error
    - Retain previously displayed data on refresh failure
    - _Requirements: 3.1, 3.7, 3.8_

  - [x] 6.2 Implement Dashboard screen UI
    - Create `lib/presentation/screens/dashboard/dashboard_screen.dart`
    - Display groom name, bride name, wedding date (or placeholder if not set)
    - Display task completion percentage with progress bar (0% if no tasks)
    - Display total budget and total spent as formatted currency
    - Display total guest count and confirmed guest count
    - Display up to 5 upcoming execution tasks and 5 pending input tasks sorted by due date
    - Implement pull-to-refresh
    - Apply neobrutalist styling
    - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8_

- [x] 7. Implement Budget module
  - [x] 7.1 Implement BudgetRepository and BudgetBloc
    - Create `lib/data/repositories/budget_repository.dart` — CRUD operations (GET, POST, PUT, DELETE `/api/budgets`)
    - Create `lib/domain/blocs/budget/budget_bloc.dart` — events: Load, Add, Update, Delete; states: loading/loaded/error
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.7_

  - [x] 7.2 Implement Budget screen and forms UI
    - Create `lib/presentation/screens/budget/budget_screen.dart` — list with planned, actual, remaining, percentage per item; summary totals
    - Create `lib/presentation/screens/budget/budget_form_screen.dart` — add/edit form with category name (max 255), planned amount, actual amount
    - Validate non-numeric, negative, empty amounts and empty category name
    - Confirmation dialog for delete
    - Apply neobrutalist styling
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 4.6, 4.7_

  - [ ]* 7.3 Write property test for budget total aggregation
    - **Property 5: Budget total aggregation**
    - **Validates: Requirements 4.2**

- [x] 8. Implement Guest module
  - [x] 8.1 Implement GuestRepository and GuestBloc
    - Create `lib/data/repositories/guest_repository.dart` — GET, POST, DELETE `/api/guests`
    - Create `lib/domain/blocs/guest/guest_bloc.dart` — events: Load, Add, Delete; states: loading/loaded/error
    - _Requirements: 5.1, 5.3, 5.4, 5.6_

  - [x] 8.2 Implement Guest screen and forms UI
    - Create `lib/presentation/screens/guest/guest_screen.dart` — list with name, side, status; summary counts (total, confirmed, pending)
    - Create `lib/presentation/screens/guest/guest_form_screen.dart` — add form with name (max 255), side (Pria/Wanita/Keluarga), phone, email, status
    - Validate empty name and invalid side value
    - Confirmation dialog for delete
    - Apply neobrutalist styling
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 5.6_

  - [ ]* 8.3 Write property test for guest count filtering
    - **Property 6: Guest count filtering**
    - **Validates: Requirements 5.2**

- [x] 9. Implement Task module
  - [x] 9.1 Implement TaskRepository and TaskBloc
    - Create `lib/data/repositories/task_repository.dart` — GET, POST `/api/tasks`, PATCH `/api/tasks/{id}/toggle`, DELETE `/api/tasks/{id}`
    - Create `lib/domain/blocs/task/task_bloc.dart` — events: Load, Add, Toggle, Delete, FilterByPhase; states: loading/loaded/error
    - Optimistic update for toggle (revert on failure)
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6_

  - [x] 9.2 Implement Task screen and forms UI
    - Create `lib/presentation/screens/task/task_screen.dart` — list ordered by due date with title, type, priority, due date, phase name; filter by phase
    - Create `lib/presentation/screens/task/task_form_screen.dart` — add form with phase_id, title (1-255), type (input/execution), category, priority (rendah/sedang/tinggi), optional description, due_date, notes
    - Visually distinguish completed tasks (strikethrough/reduced opacity)
    - Visually indicate overdue tasks with distinct color/icon
    - Validate title not empty, phase selected, type and priority valid
    - Confirmation dialog for delete
    - Apply neobrutalist styling
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7, 7.8, 7.9_

  - [ ]* 9.3 Write property test for overdue task detection
    - **Property 8: Overdue task detection**
    - **Validates: Requirements 7.6**

- [x] 10. Checkpoint - Ensure feature modules work
  - Ensure all tests pass, ask the user if questions arise.

- [x] 11. Implement Phase module
  - [x] 11.1 Implement PhaseRepository and PhaseBloc
    - Create `lib/data/repositories/phase_repository.dart` — GET `/api/phases`, GET `/api/phases/{id}`
    - Create `lib/domain/blocs/phase/phase_bloc.dart` — events: LoadPhases, LoadPhaseDetail; states: loading/loaded/error
    - _Requirements: 6.1, 6.2_

  - [x] 11.2 Implement Phase screens UI
    - Create `lib/presentation/screens/phase/phase_screen.dart` — list sorted by order with name, icon, date range, progress percentage, task count "{completed}/{total}"
    - Create `lib/presentation/screens/phase/phase_detail_screen.dart` — tasks for selected phase ordered by sort order with title, priority, due date, completed status
    - Handle no tasks (0%, "0/0") and missing dates (omit date range)
    - Apply neobrutalist styling
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [x] 12. Implement Vendor module
  - [x] 12.1 Implement VendorRepository and VendorBloc
    - Create `lib/data/repositories/vendor_repository.dart` — GET, POST, DELETE `/api/vendors`
    - Create `lib/domain/blocs/vendor/vendor_bloc.dart` — events: Load, Add, Delete; states: loading/loaded/error
    - _Requirements: 8.1, 8.2, 8.3, 8.6_

  - [x] 12.2 Implement Vendor screen and forms UI
    - Create `lib/presentation/screens/vendor/vendor_screen.dart` — list with name, category, phone, email, cost (currency), status
    - Create `lib/presentation/screens/vendor/vendor_form_screen.dart` — add form with name (max 255), category, phone, email, cost
    - Validate empty name, empty category, non-numeric/negative cost
    - Confirmation dialog for delete
    - Apply neobrutalist styling
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5, 8.6_

- [x] 13. Implement Rundown module
  - [x] 13.1 Implement RundownRepository and RundownBloc
    - Create `lib/data/repositories/rundown_repository.dart` — GET, POST, DELETE `/api/rundowns`
    - Create `lib/domain/blocs/rundown/rundown_bloc.dart` — events: Load, Add, Delete; states: loading/loaded/error
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_

  - [x] 13.2 Implement Rundown screen and forms UI
    - Create `lib/presentation/screens/rundown/rundown_screen.dart` — list ordered by time with name, time, location (or empty), PIC (or empty)
    - Create `lib/presentation/screens/rundown/rundown_form_screen.dart` — add form with name (max 255), time, location, PIC, notes
    - Validate empty name and empty time
    - Retain form data on POST failure
    - Confirmation dialog for delete
    - Apply neobrutalist styling
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 9.6_

- [x] 14. Implement Settings module
  - [x] 14.1 Implement SettingsRepository and SettingsBloc
    - Create `lib/data/repositories/settings_repository.dart` — GET `/api/settings`, PUT `/api/settings`
    - Create `lib/domain/blocs/settings/settings_bloc.dart` — events: LoadSettings, UpdateSettings; states: loading/loaded/success/error
    - _Requirements: 10.1, 10.2, 10.5_

  - [x] 14.2 Implement Settings screen UI
    - Create `lib/presentation/screens/settings/settings_screen.dart` — form pre-filled with groom name, bride name, wedding date, location, total budget
    - Validate groom/bride name not empty (max 255), location max 255, budget numeric ≥ 0 and ≤ 9,999,999,999,999.99
    - Display success confirmation on save, error message on failure, retain user data on error
    - Apply neobrutalist styling
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5, 10.6_

- [x] 15. Implement navigation and app shell
  - [x] 15.1 Implement GoRouter navigation and bottom nav bar
    - Create `lib/config/router.dart` with GoRouter configuration for all routes
    - Create `lib/presentation/shell/app_shell.dart` — scaffold with NeoBottomNavBar (5 items: Dashboard, Tasks, Budget, Guests, More)
    - Implement "More" menu as popup/bottom sheet with Phases, Rundown, Vendors, Settings
    - Dismiss "More" on outside tap or back button
    - Highlight active nav item with pink accent; highlight "More" when viewing its sub-screens
    - Preserve scroll position and content state when switching tabs
    - _Requirements: 12.1, 12.2, 12.3, 12.4, 12.5, 12.6, 12.7_

  - [x] 15.2 Wire app entry point and auth flow
    - Create `lib/main.dart` — initialize app with BlocProviders, GoRouter, and auth state listener
    - Redirect to login screen when unauthenticated, to dashboard when authenticated
    - _Requirements: 2.6, 2.7, 2.8_

- [x] 16. Implement form validation utilities
  - [x] 16.1 Create shared form validators
    - Create `lib/core/validators/form_validators.dart` — required field, email format, max length, numeric, non-negative, side enum, type enum, priority enum validators
    - Reuse across all form screens
    - _Requirements: 4.6, 5.5, 7.9, 8.4, 8.5, 9.6, 10.3, 10.4, 10.6_

  - [ ]* 16.2 Write property test for form validation
    - **Property 7: Form validation rejects invalid input and accepts valid input**
    - **Validates: Requirements 4.6, 5.5, 7.9, 8.4, 9.6, 10.3**

- [x] 17. Configure Android build and launcher icon
  - [x] 17.1 Configure Android build settings and launcher icon
    - Set `minSdkVersion 21` and compile SDK in `android/app/build.gradle`
    - Set unique application ID in reverse domain format
    - Configure app name "Wedding Planner" in `AndroidManifest.xml`
    - Add custom adaptive launcher icon using `flutter_launcher_icons` package (replace default Flutter icon)
    - Verify `flutter build apk` produces release APK
    - _Requirements: 13.1, 13.2, 13.3, 13.4, 13.5_

- [x] 18. Add Laravel API endpoints
  - [x] 18.1 Add API routes and controllers to Laravel backend
    - Create `routes/api.php` with all API routes (login, logout, dashboard, budgets, guests, phases, tasks, vendors, rundowns, settings)
    - Add API Resource classes for JSON response formatting
    - Add Sanctum/token-based authentication to API routes
    - Ensure all endpoints return JSON envelope format `{ success, data, message }`
    - _Requirements: 1.1, 1.5, 2.2_

- [x] 19. Final checkpoint - Full integration verification
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties from the design document
- Unit tests validate specific examples and edge cases
- The Laravel API endpoints (task 18) can be developed in parallel with Flutter UI modules
- The design system (task 1.2) should be completed early as all screens depend on it

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "1.3"] },
    { "id": 1, "tasks": ["1.2", "2.1", "18.1"] },
    { "id": 2, "tasks": ["2.2", "2.3", "3.1", "16.1"] },
    { "id": 3, "tasks": ["3.2", "3.3", "3.4", "4.1"] },
    { "id": 4, "tasks": ["4.2", "6.1", "16.2"] },
    { "id": 5, "tasks": ["6.2", "7.1", "8.1", "9.1"] },
    { "id": 6, "tasks": ["7.2", "7.3", "8.2", "8.3", "9.2", "9.3"] },
    { "id": 7, "tasks": ["11.1", "12.1", "13.1", "14.1"] },
    { "id": 8, "tasks": ["11.2", "12.2", "13.2", "14.2"] },
    { "id": 9, "tasks": ["15.1", "15.2"] },
    { "id": 10, "tasks": ["17.1"] }
  ]
}
```

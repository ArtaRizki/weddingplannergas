# Requirements Document

## Introduction

A Flutter mobile application for Android that serves as a wedding planner, connecting to an existing Laravel backend API. The app provides comprehensive wedding planning features including dashboard overview, budget tracking, guest management, phase/timeline tracking, day-of rundown, task management, and vendor coordination. The UI follows a retro/game-inspired neobrutalist design style with a white and pink color palette, featuring bold borders, card-based layouts, chunky buttons, and playful typography.

## Glossary

- **Flutter_App**: The Flutter mobile application targeting Android APK builds (Flutter 3.41.5)
- **Laravel_API**: The existing Laravel backend exposing RESTful JSON endpoints for wedding planner data
- **Dashboard_Screen**: The main overview screen displaying wedding progress, budget summary, guest count, and upcoming tasks
- **Budget_Module**: The module for managing budget categories with planned and actual amounts
- **Guest_Module**: The module for managing wedding guest list with invitation status tracking
- **Phase_Module**: The module for viewing wedding planning phases/timeline with associated tasks
- **Rundown_Module**: The module for managing the wedding day schedule/rundown
- **Task_Module**: The module for managing planning tasks categorized by type, priority, and phase
- **Vendor_Module**: The module for managing wedding vendors with contact and cost information
- **Settings_Module**: The module for managing wedding details (names, date, location, budget, colors)
- **Neobrutalist_UI**: A design style characterized by bold black borders (2-4px), card-based layouts with visible shadows, chunky interactive buttons, and playful retro typography
- **Auth_Module**: The authentication module handling user login and token-based API access

## Requirements

### Requirement 1: API Integration Layer

**User Story:** As a developer, I want the Flutter app to communicate with the Laravel backend via RESTful API, so that all wedding data is synchronized between mobile and server.

#### Acceptance Criteria

1. THE Flutter_App SHALL communicate with the Laravel_API using HTTP REST calls with JSON request and response bodies
2. THE Flutter_App SHALL store the base URL of the Laravel_API in a configurable environment variable
3. WHEN the Laravel_API returns an HTTP error status code (4xx or 5xx), THE Flutter_App SHALL display an error message indicating the nature of the failure (e.g., network issue, invalid input, or server error) without exposing technical details, and log the HTTP status code, endpoint, and response body to the device's debug console
4. WHEN the device has no network connectivity, THE Flutter_App SHALL display a visible offline indicator and disable all data submission controls until connectivity is restored
5. THE Flutter_App SHALL include the authorization token in the "Authorization" header using the Bearer scheme for every authenticated API request
6. IF an API request does not receive a response within 30 seconds, THEN THE Flutter_App SHALL cancel the request and display an error message indicating a connection timeout

### Requirement 2: Authentication

**User Story:** As a user, I want to log in with my credentials, so that I can securely access my wedding planning data.

#### Acceptance Criteria

1. THE Auth_Module SHALL provide a login screen with an email input field that accepts a valid email format (maximum 255 characters) and a password input field that masks entered characters (minimum 8 characters)
2. WHEN valid credentials are submitted, THE Auth_Module SHALL send a POST request to the Laravel_API login endpoint within 15 seconds and store the returned authentication token in the device's secure storage
3. WHEN invalid credentials are submitted, THE Auth_Module SHALL display an error message indicating incorrect email or password without revealing which field is incorrect
4. IF the login POST request fails due to network unavailability or server error, THEN THE Auth_Module SHALL display an error message indicating the connection failure and retain the entered email address in the input field
5. IF the user submits invalid credentials 5 consecutive times, THEN THE Auth_Module SHALL disable the login button for 60 seconds, display a lockout message explaining why the button is disabled, and display the remaining wait time
6. THE Auth_Module SHALL persist the authentication token across app restarts only after a successful authentication, until the user explicitly logs out or the token expires
7. WHEN the user taps the logout button, THE Auth_Module SHALL clear the stored authentication token and navigate to the login screen
8. WHEN the Auth_Module receives an authentication error response (HTTP 401) from the Laravel_API during any request, THE Auth_Module SHALL clear the stored token and redirect the user to the login screen

### Requirement 3: Dashboard

**User Story:** As a wedding planner user, I want to see an overview of my wedding progress on the main screen, so that I can quickly assess the overall planning status.

#### Acceptance Criteria

1. WHEN the user navigates to the Dashboard_Screen, THE Flutter_App SHALL display the groom name, bride name, and wedding date retrieved from the Laravel_API. IF the wedding date has not been set, THEN THE Dashboard_Screen SHALL display a placeholder text indicating no date is configured.
2. WHEN the Dashboard_Screen loads, THE Dashboard_Screen SHALL display the overall task completion progress as a numeric percentage (completed tasks divided by total tasks, rounded to one decimal place) together with a progress bar reflecting that percentage. IF no tasks exist, THEN THE Dashboard_Screen SHALL display 0% progress.
3. THE Dashboard_Screen SHALL display the total budget amount (sum of all budget item planned amounts) and total spent amount (sum of all budget item actual amounts) retrieved from the Laravel_API, formatted as numeric currency values.
4. THE Dashboard_Screen SHALL display the total guest count and confirmed guest count (guests with status "Konfirmasi" or "Hadir").
5. THE Dashboard_Screen SHALL display up to 5 upcoming execution tasks that are not completed and have a due date, sorted by due date in ascending order, showing each task's title and due date.
6. THE Dashboard_Screen SHALL display up to 5 pending input tasks that are not completed and have a due date, sorted by due date in ascending order, showing each task's title and due date.
7. WHEN the user pulls down on the Dashboard_Screen, THE Flutter_App SHALL refresh all dashboard data from the Laravel_API and update the displayed values within 10 seconds.
8. IF the Laravel_API request fails when loading or refreshing the Dashboard_Screen, THEN THE Flutter_App SHALL display an error message indicating the data could not be loaded and SHALL retain any previously displayed data.

### Requirement 4: Budget Management

**User Story:** As a wedding planner user, I want to track my wedding budget by category, so that I can monitor spending against planned amounts.

#### Acceptance Criteria

1. WHEN the user navigates to the Budget_Module, THE Flutter_App SHALL display a list of all budget categories with their planned amount, actual amount, remaining amount (planned minus actual), and percentage spent (actual divided by planned, displayed as a percentage rounded to one decimal place). IF actual spending exceeds the planned amount, THEN THE Budget_Module SHALL show the actual calculated percentage (which may exceed 100%)
2. WHEN the user navigates to the Budget_Module, THE Budget_Module SHALL display a summary showing total planned budget (sum of all planned amounts) and total actual spending (sum of all actual amounts)
3. WHEN the user submits the add budget form with a category name (maximum 255 characters), planned amount, and actual amount, THE Flutter_App SHALL send a POST request to the Laravel_API and add the new budget entry to the list
4. WHEN the user edits an existing budget entry and submits the updated category name, planned amount, or actual amount, THE Flutter_App SHALL send a PUT request to the Laravel_API and update the displayed values
5. WHEN the user confirms deletion of a budget entry via a confirmation dialog, THE Flutter_App SHALL send a DELETE request to the Laravel_API and remove the entry from the list
6. IF the user submits the budget form with a non-numeric, negative, or empty planned amount or actual amount, or with an empty category name, THEN THE Budget_Module SHALL prevent submission and display a validation error message indicating which field is invalid
7. IF the Laravel_API returns an error response when creating, updating, or deleting a budget entry, THEN THE Flutter_App SHALL display an error message indicating the operation failed and preserve the user's current data on screen

### Requirement 5: Guest Management

**User Story:** As a wedding planner user, I want to manage my guest list with invitation status tracking, so that I can organize attendees by side and monitor RSVPs.

#### Acceptance Criteria

1. WHEN the user navigates to the Guest_Module, THE Flutter_App SHALL display a list of all guests with their name, side (Pria/Wanita/Keluarga), and invitation status (Belum Diundang/Diundang/Konfirmasi/Hadir)
2. THE Guest_Module SHALL display summary counts for total guests, confirmed guests (status "Konfirmasi" or "Hadir"), and pending guests (status "Belum Diundang" or "Diundang")
3. WHEN the user submits the add guest form with name (maximum 255 characters), side, phone, email, and status, THE Flutter_App SHALL send a POST request to the Laravel_API and add the new guest to the list
4. WHEN the user confirms deletion of a guest via a confirmation dialog, THE Flutter_App SHALL send a DELETE request to the Laravel_API and, only upon a successful response, remove the guest from the displayed list
5. IF the user submits the guest form with an empty name or an invalid side value (not one of "Pria", "Wanita", or "Keluarga"), THEN THE Guest_Module SHALL prevent submission and display a validation error message indicating which field is invalid
6. IF the Laravel_API returns an error response when creating or deleting a guest, THEN THE Flutter_App SHALL display an error message indicating the operation failed and preserve the current guest list on screen

### Requirement 6: Phase and Timeline Management

**User Story:** As a wedding planner user, I want to view my wedding planning phases with their associated tasks, so that I can track progress through each planning stage.

#### Acceptance Criteria

1. WHEN the user navigates to the Phase_Module, THE Flutter_App SHALL display a list of all phases sorted by their defined sort order, showing for each phase: name, icon, date range (start date and end date), and completion progress as a percentage rounded to one decimal place
2. WHEN the user taps on a phase, THE Flutter_App SHALL navigate to a detail screen showing all tasks belonging to that phase ordered by their sort order, displaying for each task: title, priority, due date, and completed status
3. THE Phase_Module SHALL display the number of completed tasks versus total tasks for each phase in the format "{completed}/{total}"
4. IF a phase has no tasks, THEN THE Phase_Module SHALL display a completion progress of 0% and a task count of "0/0"
5. IF a phase has neither start date nor end date defined, THEN THE Phase_Module SHALL omit the date range from that phase's display. IF only one date is available (start or end), THEN THE Phase_Module SHALL display a partial date range (e.g., "Starts: Jan 10" or "Ends: Dec 15")

### Requirement 7: Task Management

**User Story:** As a wedding planner user, I want to manage my planning tasks with priorities and due dates, so that I can stay organized and meet deadlines.

#### Acceptance Criteria

1. WHEN the user navigates to the Task_Module, THE Flutter_App SHALL display a list of all tasks ordered by due date, showing each task's title, type (input/execution), priority (rendah/sedang/tinggi), due date, and associated phase name, with the ability to filter tasks by phase
2. WHEN the user submits the add task form with valid phase_id, title (1–255 characters), type (input or execution), category, priority (rendah/sedang/tinggi), and optional description, due_date, and notes, THE Flutter_App SHALL send a POST request to the Laravel_API and append the new task to the list upon a successful response
3. IF the Laravel_API returns a validation error on task creation, THEN THE Flutter_App SHALL display the error message indicating which fields failed validation and preserve the user's entered form data
4. WHEN the user taps the toggle button on a task, THE Flutter_App SHALL send a PATCH request to the Laravel_API to toggle the task completion status, and upon success update the task's visual state to reflect completed (with completed_at timestamp) or incomplete
5. WHEN the user confirms deletion of a task, THE Flutter_App SHALL send a DELETE request to the Laravel_API and remove the task from the displayed list upon a successful response
6. IF a Laravel_API request for toggle or delete fails, THEN THE Flutter_App SHALL display an error message indicating the operation failed and retain the task's previous state in the list
7. THE Task_Module SHALL visually distinguish completed tasks from incomplete tasks by applying a strikethrough or reduced-opacity style to completed task titles
8. THE Task_Module SHALL visually indicate overdue tasks (where due_date is before the current date and the task is not completed) using a distinct color or icon differentiating them from on-time tasks
9. THE Task_Module SHALL validate that title is not empty (1–255 characters), phase is selected, type is one of (input/execution), and priority is one of (rendah/sedang/tinggi) before enabling form submission, and display inline error indicators for each invalid field. WHEN all fields become valid, THE Task_Module SHALL automatically remove the error indicators

### Requirement 8: Vendor Management

**User Story:** As a wedding planner user, I want to manage my wedding vendors with contact details and costs, so that I can coordinate with service providers and track expenses.

#### Acceptance Criteria

1. WHEN the user navigates to the Vendor_Module, THE Flutter_App SHALL display a list of all vendors with their name, category, phone, email, cost (formatted as currency), and status (default "Aktif")
2. WHEN the user submits the add vendor form with name (maximum 255 characters), category, phone, email, and cost, THE Flutter_App SHALL send a POST request to the Laravel_API and add the new vendor to the list
3. WHEN the user confirms deletion of a vendor via a confirmation dialog, THE Flutter_App SHALL send a DELETE request to the Laravel_API and remove the vendor from the list
4. IF the user submits the vendor form with an empty name or empty category, THEN THE Vendor_Module SHALL prevent submission and display a validation error message indicating which required fields are missing. Validation errors SHALL only appear during form submission attempts
5. IF the cost field contains a non-numeric or negative value during form submission, THEN THE Vendor_Module SHALL prevent submission and display a validation error message for the cost field
6. IF the Laravel_API returns an error response when creating or deleting a vendor, THEN THE Flutter_App SHALL display an error message indicating the operation failed and preserve the current vendor list on screen

### Requirement 9: Rundown Management

**User Story:** As a wedding planner user, I want to manage the wedding day schedule, so that I can plan the timeline of events for the ceremony and reception.

#### Acceptance Criteria

1. WHEN the user navigates to the Rundown_Module, THE Flutter_App SHALL display a list of all rundown items ordered by time in ascending order, showing name, time, location (or empty if not set), and person in charge (PIC) (or empty if not set)
2. WHEN the user submits the add rundown form with valid name (maximum 255 characters), time, location, PIC, and notes, THE Flutter_App SHALL send a POST request to the Laravel_API and add the new rundown item to the list
3. IF the POST request to add a rundown item fails, THEN THE Flutter_App SHALL display an error message indicating the item was not saved and SHALL retain the user's entered form data
4. WHEN the user confirms deletion of a rundown item via a confirmation dialog, THE Flutter_App SHALL send a DELETE request to the Laravel_API and remove the item from the list
5. IF the DELETE request fails, THEN THE Flutter_App SHALL display an error message indicating the item was not deleted and SHALL keep the item visible in the list
6. IF the user submits the add rundown form with an empty name or empty time field, THEN THE Rundown_Module SHALL prevent submission and display a validation message indicating which required fields are missing. THE Rundown_Module SHALL only prevent submission and show validation messages when name or time fields are actually empty or invalid. Both the prevention and the validation message display SHALL succeed together; if either mechanism fails, THE Rundown_Module SHALL allow submission to proceed

### Requirement 10: Wedding Settings

**User Story:** As a wedding planner user, I want to update my wedding details such as names, date, and location, so that the app reflects accurate wedding information.

#### Acceptance Criteria

1. WHEN the user navigates to the Settings_Module, THE Flutter_App SHALL display a form pre-filled with the current wedding details (groom name, bride name, wedding date, location, total budget)
2. WHEN the user submits the updated settings with valid data, THE Flutter_App SHALL send a PUT request to the Laravel_API, update the stored wedding information, and display a success confirmation message
3. IF the groom name or bride name field is empty, THEN THE Settings_Module SHALL immediately display a validation error message indicating that both name fields are required and prevent submission
4. IF the total budget value is provided, THEN THE Settings_Module SHALL validate that it is a numeric value greater than or equal to 0 and does not exceed 9,999,999,999,999.99 before submission
5. IF the Laravel_API returns an error response when saving settings, THEN THE Flutter_App SHALL display an error message indicating the update failed and retain the user-entered data in the form
6. THE Settings_Module SHALL enforce a maximum length of 255 characters for groom name, bride name, and location fields

### Requirement 11: Neobrutalist UI Design System

**User Story:** As a user, I want the app to have a visually distinctive retro/game-inspired design with white and pink colors, so that the wedding planner feels fun and modern.

#### Acceptance Criteria

1. THE Flutter_App SHALL use a white (#FFFFFF) background as the primary surface color across all screens
2. THE Flutter_App SHALL use pink (#FF69B4) as the primary accent color for buttons, highlights, and active elements
3. THE Flutter_App SHALL use light pink (#FFB6C1) as the secondary color for card backgrounds and inactive UI element fills
4. THE Flutter_App SHALL render all card components with black (#000000) borders of strictly 2-4 pixel width (no exceptions) and a solid black offset shadow of 3-5 pixels to the bottom-right
5. THE Flutter_App SHALL render all primary action buttons with black (#000000) borders of 2-4 pixel width, a solid pink (#FF69B4) fill, and a black offset shadow of 3-5 pixels that visually reduces to 0 pixels on press to simulate a pushed-in effect
6. THE Flutter_App SHALL use a bold sans-serif font family with a minimum weight of 700 for headings and a regular-weight sans-serif font with a minimum size of 14 logical pixels for body text
7. THE Flutter_App SHALL apply consistent border-radius values between 8-12 pixels for cards and buttons to maintain the neobrutalist aesthetic
8. THE Flutter_App SHALL use black (#000000) as the primary text color for headings and body content, and dark gray (#333333) for secondary or supporting text

### Requirement 12: Navigation and App Structure

**User Story:** As a user, I want to navigate between app sections easily, so that I can access all wedding planning features without confusion.

#### Acceptance Criteria

1. THE Flutter_App SHALL provide a bottom navigation bar with icons and labels for exactly 5 items: Dashboard, Tasks, Budget, Guests, and a "More" menu
2. WHEN the user taps the "More" menu item, THE Flutter_App SHALL display a popup menu or bottom sheet overlay containing navigation options for Phases, Rundown, Vendors, and Settings
3. WHEN the user taps a navigation option from the "More" menu, THE Flutter_App SHALL navigate to the selected screen and dismiss the "More" overlay
4. IF the user taps outside the "More" menu overlay or presses the back button, THEN THE Flutter_App SHALL dismiss the overlay without navigating. IF the user simultaneously taps a menu option and taps outside the overlay, THEN THE Flutter_App SHALL dismiss the overlay without navigating (outside tap takes precedence)
5. THE Flutter_App SHALL highlight the currently active navigation item in the bottom navigation bar using the primary accent color
6. WHILE the user is viewing a screen accessed via the "More" menu (Phases, Rundown, Vendors, or Settings), THE Flutter_App SHALL highlight the "More" item in the bottom navigation bar as the active item
7. THE Flutter_App SHALL maintain navigation state within a single app session so that returning to a previously visited tab preserves the previous scroll position and content state

### Requirement 13: Android Build Target

**User Story:** As a developer, I want the app to build as an Android APK, so that it can be distributed and installed on Android devices.

#### Acceptance Criteria

1. THE Flutter_App SHALL target Android SDK version 21 as the minimum SDK and the Flutter default compile SDK version as the compile target
2. THE Flutter_App SHALL produce a single release APK file when the `flutter build apk` command is executed successfully, with a unique application ID in reverse domain format. IF the build process fails due to signing or other configuration issues, THEN THE build system SHALL NOT produce an APK file and SHALL output an error message indicating the failure
3. WHEN the Flutter_App is installed on an Android device, THE Flutter_App SHALL display the app name "Wedding Planner" beneath the launcher icon on the home screen
4. WHEN the Flutter_App is installed on an Android device, THE Flutter_App SHALL display a project-specific launcher icon that is distinct from the default Flutter placeholder icon and is provided in adaptive icon format
5. IF the release APK build process fails due to missing signing configuration, THEN THE Flutter_App build system SHALL output an error message indicating the signing issue and SHALL NOT produce an APK file

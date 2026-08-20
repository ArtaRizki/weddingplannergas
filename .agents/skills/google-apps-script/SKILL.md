---
name: google-apps-script
description: Best practices, patterns, and workflows for Google Apps Script (GAS), Google Sheets integration, HTML Service web apps, and wedding planner spreadsheet synchronization. Use when modifying or debugging .gs files, doGet/doPost web app endpoints, SpreadsheetApp manipulation, or GAS-to-web data exchange.
---

# Google Apps Script (GAS) & Google Sheets Integration

This skill provides domain guidelines and patterns for developing, debugging, and maintaining Google Apps Script (GAS) code, specifically tailored for Google Sheets automation, HTML Service web applications, and data synchronizers.

## Core Capabilities & Patterns

### 1. SpreadsheetApp Best Practices
- **Batch Operations**: Minimize calls to `SpreadsheetApp` (e.g., use `getValues()` and `setValues()` in bulk rather than cell-by-cell `getValue()` / `setValue()`).
- **Sheet Caching**: Store references to active sheets and ranges in memory.
- **Dynamic Ranges**: Compute last row/column dynamically using `sheet.getLastRow()` and `sheet.getLastColumn()`.

### 2. Web App Deployment (`doGet` & `doPost`)
- **HTML Service**: Serve HTML templates using `HtmlService.createHtmlOutputFromFile('GAS_Index')` or `HtmlService.createTemplateFromFile()`.
- **CORS & JSON Responses**: When serving API data, return `ContentService.createTextOutput(JSON.stringify(data)).setMimeType(ContentService.MimeType.JSON)`.
- **X-Frame-Options**: Use `.setXFrameOptionsMode(HtmlService.XFrameOptionsMode.ALLOWALL)` when embedding in iframe or Google Sites.

### 3. Color Palette & Theme Engine
- Maintain dynamic color rules (Primary, Secondary, Accent).
- Update cell backgrounds and fonts harmoniously using hex color codes (e.g., `#FF69B4`, `#FFB6C1`, `#FFD700`).

### 4. Data Synchronization (Web <-> Sheets)
- Support exporting and importing JSON schemas matching:
  - Weddings (metadata, couple names, date, location, budget)
  - Phases & Tasks (timeline, status, priority, due dates)
  - Budgets (categories, allocated, actual spend)
  - Vendors (contacts, categories, price)
  - Guests (attendance status, side, contact)
  - Rundown (timeslot, activity, PIC, notes)

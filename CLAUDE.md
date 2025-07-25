# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Warikan is a Flutter application for calculating bill splitting (warikan in Japanese) with two distinct calculation modes:
- **Normal**: Standard bill splitting with optional rounding controls
- **Keisha**: Advanced calculation with different contribution rates per person

## Development Commands

### Core Flutter Commands
```bash
# Install dependencies
flutter pub get

# Run code generation (for Isar, Riverpod, Freezed)
flutter packages pub run build_runner build

# Clean and rebuild generated files
flutter packages pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run

# Build for release
flutter build apk --release
flutter build ios --release

# Analyze code
flutter analyze

# Run tests
flutter test
```

### Code Generation
This project uses several code generation tools:
- **Isar**: Database models (generates `.g.dart` files)
- **Riverpod**: State management (generates providers)
- **Freezed**: Immutable data classes (generates `.freezed.dart` files)

Always run `flutter packages pub run build_runner build` after modifying files with annotations.

## Architecture Overview

### State Management
- **Riverpod**: Primary state management solution
- **Riverpod Generator**: Uses `@riverpod` annotations for provider generation
- Controllers use `AsyncNotifier` pattern for async state management

### Database
- **Isar**: Local NoSQL database for persistence
- Two main entity types:
  - `EventNormal`: Standard bill splitting events
  - `EventKeisha`: Advanced contribution-based events
- Database initialized in `main.dart` and passed through the widget tree

### Page Structure
```
lib/pages/
├── main_page.dart                    # Bottom navigation container
├── calculate_page.dart               # Mode selection page
├── normal_calculate_page/            # Standard calculation
│   ├── normal_calculate_page.dart
│   ├── normal_calculate_page_controller.dart
│   └── widgets/
├── keisha_calculate_page/           # Advanced calculation  
│   ├── keisha_calculate_page.dart
│   ├── keisha_calculate_page_controller.dart
│   └── widgets/
├── event_page/                     # Saved events list
└── setting_page.dart               # App settings
```

### Key Models
- `Event`: Base class for all events
- `EventNormal`: Extends Event, includes rounding options and difference calculation
- `EventKeisha`: Extends Event, includes group-based contribution calculations
- `KeishaGroup`: Defines contribution groups with different rates

### UI Patterns
- Uses Material Design 3 with custom color scheme
- Japanese font (Noto Sans JP) for proper Japanese text rendering
- Staggered animations for enhanced UX
- Auto-sizing text for responsive layouts
- Custom keyboard configuration for numeric inputs

## Development Guidelines

### File Naming Conventions
- Page files: `*_page.dart`
- Controller files: `*_controller.dart`
- Model files: descriptive names in `models/`
- Widget files: descriptive names in `widgets/` subdirectories

### State Management Patterns
- Use `@riverpod` annotation for provider generation
- Controllers extend `AsyncNotifier<T>` for async operations
- Expose state through computed properties when needed
- Handle loading, error, and success states explicitly

### Database Operations
- Always use async/await for Isar operations
- Pass Isar instance through constructor dependency injection
- Use proper transaction handling for complex operations
- Follow Isar naming conventions for collections

### Localization
- App is primarily in Japanese
- Comments in code are in Japanese for developer context
- UI text should maintain Japanese language consistency
- **All responses and implementations should be conducted in Japanese**
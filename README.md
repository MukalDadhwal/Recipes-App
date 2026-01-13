# Recipe Finder App

A Flutter application that showcases recipes using [TheMealDB](https://www.themealdb.com/) public API. Browse, search, filter, and save your favorite recipes with an elegant Material 3 design.

## Features

### 📋 Recipe List Page
- **Multiple View Modes**: Toggle between grid and list view
- **Advanced Search & Filtering**:
  - Search by recipe name (debounced 500ms)
  - Filter by category (Dessert, Seafood, Chicken, etc.)
  - Filter by cuisine area (American, Italian, Chinese, etc.)
  - Combined filters support
  - Clear all filters functionality
- **Sorting**: Sort recipes by name (A-Z, Z-A)
- **Loading States**: Shimmer effects for better UX
- **Recently Viewed**: Shows recently opened recipes when no filters applied
- **Hero Animations**: Smooth transitions to detail page

### 📖 Recipe Detail Page
- **Organized Content**: Tabbed interface (Overview, Ingredients, Instructions)
- **Complete Recipe Information**:
  - Recipe name, image, category, cuisine area
  - Full ingredients list with measurements
  - Step-by-step instructions
  - Tags (if available)
- **YouTube Integration**: Embedded video player for recipe tutorials
- **Interactive Image Viewer**: Zoom in/out on recipe images
- **Favorite Toggle**: Animated heart icon with persistence
- **Offline Support**: Previously viewed recipes accessible without internet

### ⭐ Favorites Page
- View all favorited recipes
- Remove favorites
- Persisted across app launches

## Architecture

This project follows **Clean Architecture** principles with **BLoC** state management:

```
lib/
├── core/
│   ├── constants/        # App-wide constants
│   ├── error/           # Error handling (exceptions)
│   ├── router/          # Navigation (GoRouter)
│   └── utils/           # Utility functions
├── features/
│   └── recipes/
│       ├── data/
│       │   ├── datasources/   # API & local data sources
│       │   ├── models/        # Data models
│       │   └── repositories/  # Repository implementations
│       ├── domain/
│       │   ├── entities/      # Business entities
│       │   ├── repositories/  # Repository contracts
│       │   └── usecases/      # Business logic use cases
│       └── presentation/
│           ├── bloc/          # State management
│           ├── pages/         # UI screens
│           └── widgets/       # Reusable widgets
└── injection.dart            # Dependency injection setup
```

### Layers

1. **Domain Layer**: Pure Dart business logic
   - Entities: Core business objects
   - Use Cases: Single responsibility business operations
   - Repository Interfaces: Contracts for data access

2. **Data Layer**: Data handling and sources
   - Models: Data transfer objects with JSON serialization
   - Data Sources: API service, local storage (Hive)
   - Repository Implementations: Concrete data access logic

3. **Presentation Layer**: UI and state management
   - BLoC: State management with flutter_bloc
   - Pages: Screen-level widgets
   - Widgets: Reusable UI components

## Tech Stack

### Core Dependencies
- **Flutter SDK**: ^3.10.7
- **Dart**: Latest stable

### State Management
- **flutter_bloc**: ^9.1.1 - BLoC pattern implementation
- **equatable**: ^2.0.8 - Value equality for models

### Networking
- **dio**: ^5.9.0 - HTTP client for API requests

### Local Storage
- **hive**: ^2.2.3 - NoSQL database
- **hive_flutter**: ^1.1.0 - Hive Flutter integration
- **path_provider**: ^2.1.5 - File system paths

### Navigation
- **go_router**: ^17.0.1 - Declarative routing

### Dependency Injection
- **get_it**: ^9.2.0 - Service locator

### UI Components
- **flutter_screenutil**: ^5.9.3 - Responsive sizing
- **cached_network_image**: ^3.4.1 - Image caching
- **shimmer**: ^3.0.0 - Loading effects
- **youtube_player_flutter**: ^9.1.3 - YouTube video playback
- **google_fonts**: ^6.2.1 - Custom fonts

### Testing
- **flutter_test**: SDK - Unit & widget tests
- **bloc_test**: ^10.0.0 - BLoC testing utilities
- **path_provider_platform_interface**: ^2.1.2 - Mock path provider

## Getting Started

### Prerequisites
- Flutter SDK ^3.10.7
- Dart SDK
- Android Studio / VS Code
- Android/iOS emulator or physical device

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd recipes_app
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Run the app**
```bash
flutter run
```

### Build for Production

**Android:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

## API Reference

This app uses [TheMealDB API](https://www.themealdb.com/api.php) (free tier):

- **Search by name**: `www.themealdb.com/api/json/v1/1/search.php?s={query}`
- **Lookup by ID**: `www.themealdb.com/api/json/v1/1/lookup.php?i={id}`
- **Random meal**: `www.themealdb.com/api/json/v1/1/random.php`
- **Filter by category**: `www.themealdb.com/api/json/v1/1/filter.php?c={category}`
- **Filter by area**: `www.themealdb.com/api/json/v1/1/filter.php?a={area}`
- **List categories**: `www.themealdb.com/api/json/v1/1/categories.php`
- **List areas**: `www.themealdb.com/api/json/v1/1/list.php?a=list`

## State Management

### BLoC Pattern

The app uses BLoC (Business Logic Component) for state management:

#### MealRecipeBloc
Handles recipe operations:
- **Events**: `ApplyFiltersEvent`, `SearchMealsByNameEvent`, `GetMealByIdEvent`, etc.
- **States**: `MealRecipeLoadingState`, `MealsLoadedState`, `MealDetailLoadedState`, etc.

#### FavoritesBloc
Manages favorite recipes:
- **Events**: `LoadFavoritesEvent`, `AddFavoriteEvent`, `RemoveFavoriteEvent`
- **States**: `FavoritesLoadedState`, `FavoriteAddedState`, `FavoriteRemovedState`

## Local Storage

### Hive Boxes

1. **meals_cache**: Stores recently viewed recipes
2. **favorites**: Stores user's favorite recipes

### Caching Strategy
- Meals are cached only when explicitly viewed in detail page
- Cache is checked before making API calls
- Recently viewed list built from cached meals

## Testing

Run all tests:
```bash
flutter test
```

Run tests with coverage:
```bash
flutter test --coverage
```

### Test Structure
```
test/
├── core/
│   └── utils/           # Utility function tests
└── features/
    └── recipes/
        ├── data/
        │   └── models/  # Model serialization tests
        └── presentation/
            ├── bloc/    # BLoC tests
            └── widgets/ # Widget tests
```

### Test Coverage
- Unit tests for models and utilities
- BLoC tests for state management
- Widget tests for UI components
- Target: >70% coverage for business logic


## License

This project is created for educational purposes.



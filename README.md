# News App

A modern Flutter news application that provides real-time news updates with a beautiful and responsive user interface. The app supports both English and Russian languages, features a dark/light theme, and allows users to save their favorite articles.

## Features

- 📰 Real-time news updates from various categories
- 🌓 Dark and Light theme support
- 🌐 Bilingual support (English/Russian)
- ⭐ Favorite articles functionality
- 📱 Responsive design for all screen sizes
- 🔄 Pull-to-refresh functionality
- 📄 Pagination support
- 🖼️ Image caching for better performance
- 🔍 Category-based news filtering

## Categories

- All
- Politics
- Economy
- Social
- Culture
- Sports
- Technology
- Health
- Science
- Entertainment

## Technical Details

### Dependencies

- `flutter`: The core Flutter framework
- `provider`: For state management
- `http`: For API calls
- `shared_preferences`: For local storage
- `cached_network_image`: For image caching
- `url_launcher`: For opening news articles in browser
- `intl`: For internationalization
- `sqflite`: For local database (available but not currently used)

### Architecture

The app follows a clean architecture pattern with:
- Models: Data structures and business logic
- Services: API and database interactions
- Providers: State management
- Screens: UI components
- Widgets: Reusable UI elements

### Data Storage

The app uses SharedPreferences for storing:
- User preferences (theme, language)
- Favorite articles
- App settings

## Getting Started

1. Clone the repository:
```bash
git clone https://github.com/Matthew-Likhachev/newsApp.git
```

2. Navigate to the project directory:
```bash
cd newsApp
```

3. Install dependencies:
```bash
flutter pub get
```

4. Run the app:
```bash
flutter run
```

## API Key

The app uses the News API. You'll need to replace the API key in `lib/services/news_service.dart` with your own key from [News API](https://newsapi.org/).

## Contributing

Feel free to submit issues and enhancement requests!

## License

This project is licensed under the MIT License - see the LICENSE file for details.

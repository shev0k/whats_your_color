
# What's Your Colour?

A gamified NFC-based app that allows users to share their favorite color with friends. If the colors match, a happy sound plays, and if they don’t, a sad sound plays. The app also includes a real-time statistics page displaying how many users are using the app and their selected colors.

## Table of Contents
1. [Project Overview](#project-overview)
2. [Features](#features)
3. [Technologies Used](#technologies-used)
4. [Setup and Installation](#setup-and-installation)
5. [Usage](#usage)
6. [Challenges and Solutions](#challenges-and-solutions)
7. [Contributing](#contributing)
8. [License](#license)

## Project Overview
**What's Your Colour** is an interactive app that combines NFC technology, color selection, and gamified sound effects to create a fun, personalized experience. Users select a color that represents their mood and then share it via NFC by tapping their phone with another user’s phone. The app plays a unique sound based on whether the colors match or not. It also displays real-time statistics of active users and their color choices.

This app was built as part of a **Tech Case** to demonstrate NFC integration, WebSocket communication, and real-time data visualization. The project reflects a balance of technical functionality and aesthetically pleasing UI/UX design.

## Features
- **NFC Color Sharing**: Share colors between two phones via NFC. If colors match, a happy sound plays; if not, a sad sound plays.
- **Real-Time Statistics**: View a live feed of how many users are using the app and their selected colors.
- **Custom Sound Effects**: Personalized sounds that are triggered when colors match or differ.
- **Aesthetic UI/UX Design**: Clean, engaging, and intuitive user interface with smooth animations and gesture-based navigation.
- **WebSocket Integration**: Real-time updates on the statistics screen powered by WebSockets.

## Technologies Used
- **Frontend**: 
  - [Flutter](https://flutter.dev/) for mobile app development.
  - Custom animations and gesture-based navigation for an enhanced user experience.
- **Backend**:
  - WebSocket server for real-time data synchronization and updates.
  - Server hosted on a remote platform for continuous data access.
- **NFC Integration**:
  - Custom NFC communication using Kotlin for Android-based devices. (Due to the deprecation of NFC features in Android 10+).
- **Real-Time Data**: 
  - [WebSockets](https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API) for real-time updates on the statistics page.

## Setup and Installation

### Prerequisites
- [Flutter](https://flutter.dev/docs/get-started/install) installed on your machine.
- Android SDK and Android Studio for Android development.
- Kotlin setup for NFC functionality (ensure it's set up in your Android project).

### Clone Repository
```bash
git clone https://github.com/shev0k/whats_your_color.git
cd whats_your_colour
```

### Install Dependencies
```bash
flutter pub get
```

### Run the App
To run the app on an Android device or emulator:
```bash
flutter run
```

### WebSocket Setup
Make sure your WebSocket server is running to handle real-time data for the statistics page.

## Usage
1. Open the app and register a username.
2. Select your favorite color that represents your current mood.
3. Hold your phone next to another user's phone (both running the app) to trigger the NFC functionality.
4. If colors match, a happy sound plays; otherwise, a sad sound plays.
5. View the statistics page to see how many users are using the app and the most popular colors.

## Challenges and Solutions
### NFC Integration
- **Problem**: The required NFC functionality was deprecated in Android 10 and removed in Android 11.
- **Solution**: Implemented custom Kotlin-based NFC handling using Host-based Card Emulation (HCE), allowing data exchange between phones.

### Real-Time Data Updates
- **Problem**: Synchronizing real-time data across multiple users required a robust and scalable solution.
- **Solution**: Used WebSockets for continuous, real-time data flow, ensuring the statistics page updates automatically without refreshing.

## Contributing
If you’d like to contribute to this project:
1. Fork the repository.
2. Create a feature branch (`git checkout -b feature/new-feature`).
3. Commit your changes (`git commit -m 'Add new feature'`).
4. Push to the branch (`git push origin feature/new-feature`).
5. Open a Pull Request.

## License
This project is licensed under the MIT License.

# Flutter Unraid

A Flutter app for managing an [Unraid](https://unraid.net/) server via its GraphQL API — monitor system health, control Docker containers, manage VMs, and browse shares, all from your phone.

## About This Project

I'm a senior Flutter developer who loves homelabbing and automation. This project is an experiment to see how well I can build a fully functional app **without writing any of the code manually** — using AI agents to do all the heavy lifting. Every line of code in this repo was generated through AI-assisted development.

## Features

- **System Dashboard** — Array status, memory usage, system info at a glance
- **Docker Management** — Start, stop, restart containers; view config, ports, and logs
- **VM Control** — Start, stop, pause, resume, reboot virtual machines
- **Share Browser** — View shares with usage stats and configuration details
- **Secure Connection** — API key authentication with secure local storage

## Tech Stack

- **Flutter** (Dart SDK ^3.10.7)
- **BLoC / Cubit** for state management
- **GraphQL** (`graphql` package) for API communication
- **GetIt** for dependency injection
- **Flutter Secure Storage** for credential persistence

## Getting Started

1. Clone the repo
2. Run `flutter pub get`
3. Launch with `flutter run`
4. Enter your Unraid server URL and API key to connect

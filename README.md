# Pokedex Gacha

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)

Pokedex Gacha is a mobile application built with Flutter that combines the excitement of a gacha system with the vast world of Pokémon. Users can collect Pokémon, view their details, manage their inventory, and interact with an in-game shop. The app leverages the [PokéAPI](https://pokeapi.co/) to fetch Pokémon data and utilizes [Supabase](https://supabase.com/) as a Backend-as-a-Service for secure user authentication and database management.

## 🌟 Features

*   **User Authentication:** Secure login and registration powered by Supabase.
*   **Gacha System:** A weighted Random Number Generation (RNG) system to draw and collect Pokémon of varying rarities.
*   **Pokédex:** Browse through a comprehensive list of Pokémon fetched directly from the PokéAPI.
*   **Pokémon Details:** View detailed statistics, types, abilities, and sprites of each Pokémon.
*   **Inventory Management:** Track your collected Pokémon in your personal inventory.
*   **Items & Berries:** Browse an extensive list of in-game items (Pokéballs) and berries, fully searchable and sortable.
*   **In-game Shop:** Purchase items or currency for the gacha system.
*   **User Profile:** Manage your account and view your collection progress.

## 🛠 Tech Stack

*   **Frontend:** [Flutter](https://flutter.dev/) & Dart
*   **Backend / BaaS:** [Supabase](https://supabase.com/) (Authentication & Postgres Database)
*   **External API:** [PokéAPI](https://pokeapi.co/)
*   **Key Packages:**
    *   `supabase_flutter`: For integrating Supabase services.
    *   `dio`: Fast and powerful HTTP client for interacting with PokéAPI.
    *   `json_annotation` & `json_serializable`: For data serialization and model generation.
    *   `google_fonts`: For customized typography.
    *   `cached_network_image`: For efficient loading and caching of Pokémon sprites.
    *   `flutter_dotenv`: For managing environment variables securely.

## 📂 Project Structure

The project follows a clean, modular MVC-like architecture to separate concerns:

```text
lib/
├── controllers/    # Business logic and state management (Auth, Gacha, Shop, etc.)
├── models/         # Data classes representing entities (User, Pokemon, Inventory)
├── services/       # External data fetching and backend communication (PokeAPI, Supabase)
├── utils/          # Utility functions, constants, and styling
├── views/          # UI screens (Home, Detail, Gacha, Login, Profile, Shop, etc.)
└── main.dart       # Application entry point
```

## 🚀 Getting Started

Follow these instructions to get a copy of the project up and running on your local machine.

### Prerequisites

*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.11.5 or higher recommended)
*   A [Supabase](https://supabase.com/) project setup with Authentication and Database enabled.

### Installation

1.  **Clone the repository:**
    ```bash
    git clone <your_repository_url>
    cd UAS-MOBILE-PRAKTIKUM
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Environment Setup:**
    *   Ensure you have a `.env` file in the root directory of the project.
    *   Add your Supabase credentials to the `.env` file:
        ```env
        SUPABASE_URL=your_supabase_project_url
        SUPABASE_ANON_KEY=your_supabase_anon_key
        ```

4.  **Run Code Generation (Optional - if modifying models):**
    If you make changes to the data models in `lib/models/`, run the build runner to regenerate the JSON serialization files:
    ```bash
    dart run build_runner build -d
    ```

5.  **Run the App:**
    ```bash
    flutter run
    ```

## 📝 License

This project is created for educational purposes (UAS Mobile Praktikum).
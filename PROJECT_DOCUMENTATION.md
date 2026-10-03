# Samagran User App — Project Documentation

> **Audience:** New developers joining the project.
> **Purpose:** Understand the complete architecture, codebase, navigation flow, API layer, and state management without needing to ask the original developer basic questions.

---

## Table of Contents

1. [Project Overview](#1-project-overview)
2. [Tech Stack and Dependencies](#2-tech-stack-and-dependencies)
3. [Project Structure](#3-project-structure)
4. [Architecture Overview](#4-architecture-overview)
5. [Navigation and Routing](#5-navigation-and-routing)
6. [State Management (Riverpod)](#6-state-management-riverpod)
7. [API Layer](#7-api-layer)
8. [Authentication Flow](#8-authentication-flow)
9. [Home Screen](#9-home-screen)
10. [Product System](#10-product-system)
11. [Cart System](#11-cart-system)
12. [Pandit Booking System](#12-pandit-booking-system)
13. [Customize Kit System](#13-customize-kit-system)
14. [Category Page](#14-category-page)
15. [Profile and Account Management](#15-profile-and-account-management)
16. [Wallet System](#16-wallet-system)
17. [Notification System](#17-notification-system)
18. [Location System](#18-location-system)
19. [Shared Utilities and Design System](#19-shared-utilities-and-design-system)
20. [Firebase Integration](#20-firebase-integration)
21. [Known Patterns and Conventions](#21-known-patterns-and-conventions)

---

## 1. Project Overview

**App Name:** Samagran (Flutter package name: `samagrah`)
**Platform:** Flutter (iOS + Android primary targets; macos, linux, windows, web also scaffolded)
**Version:** `1.0.0+6`
**Flutter SDK:** `^3.10.8`
**Base API URL:** `https://api.samagran.com/api`

Samagran is an e-commerce and services app focused on Hindu puja (worship) needs. It provides:

- **Product purchasing** — puja essentials, trending items, daily ritual products
- **Pandit booking** — book a priest for rituals online or at a temple/home
- **Customize Kit** — build a personalized festival puja kit
- **Wallet** — in-app wallet top-up and transaction management
- **Category browsing** — browse products filtered by category
- **Notifications** — push notifications via FCM with in-app management

---

## 2. Tech Stack and Dependencies

### Core Framework

| Package | Version | Purpose |
|---|---|---|
| `flutter` | SDK | UI framework |
| `flutter_riverpod` | `^3.3.1` | State management |
| `dio` | `^5.9.2` | HTTP client |
| `shared_preferences` | `^2.5.5` | Local key-value storage |

### UI / Rendering

| Package | Version | Purpose |
|---|---|---|
| `cached_network_image` | `^3.4.1` | Network image caching |
| `carousel_slider` | `^5.1.2` | Banner and image carousels |
| `smooth_page_indicator` | `^2.0.1` | Page dot indicators |
| `flutter_staggered_animations` | `^1.1.1` | Staggered list/grid animations |
| `flutter_svg` | `^2.2.4` | SVG rendering |
| `lottie` | `^3.3.3` | Lottie animation playback |
| `photo_view` | `^0.15.0` | Zoomable image viewer |
| `dotted_border` | `^3.1.0` | Dotted border decoration |
| `dotted_line` | `^3.2.3` | Dotted line widget |
| `font_awesome_flutter` | `^11.0.0` | FontAwesome icons |
| `skeletonizer` | `^2.1.3` | Skeleton loading placeholders |

### Platform / Services

| Package | Version | Purpose |
|---|---|---|
| `firebase_core` | `^4.7.0` | Firebase initialization |
| `firebase_messaging` | `^16.2.0` | FCM push notifications |
| `flutter_local_notifications` | `^21.0.0` | Local notification display |
| `permission_handler` | `^12.0.1` | Runtime permission requests |
| `geolocator` | `^14.0.2` | Device GPS location |
| `geocoding` | `^4.0.0` | Reverse geocoding |
| `image_picker` | `^1.2.1` | Pick images from camera/gallery |
| `url_launcher` | `^6.3.2` | Open external URLs |
| `razorpay_flutter` | `^1.4.4` | Razorpay payment gateway |
| `intl` | `^0.20.2` | Internationalization / date formatting |
| `path_provider` | `^2.1.5` | File system paths |
| `open_filex` | `^4.7.0` | Open files (e.g., PDF invoices) |

### Dev / Build

| Package | Purpose |
|---|---|
| `flutter_launcher_icons` | Generate app icons |
| `change_app_package_name` | Rename package name |
| `flutter_lints` | Dart lint rules |

### Fonts

The app exclusively uses **Poppins** (Regular, Medium 500, SemiBold 600, Bold 700), bundled locally in `assets/font/`.

---

## 3. Project Structure

```
lib/
├── main.dart                        # Entry point, MyApp, MyHomeScreen (bottom nav shell)
├── firebase_options.dart            # Auto-generated Firebase config
│
├── data/
│   ├── exception/
│   │   └── app_exception.dart       # Custom exception classes
│   └── network/
│       ├── base_api_service.dart    # Abstract API service contract
│       └── network_api_service.dart # Dio implementation with interceptors
│
├── model/
│   ├── request/
│   │   └── auth_models/
│   │       └── user_request_model.dart
│   └── response/
│       ├── auth_response/           # Login / OTP / register response models
│       ├── address_res/             # Address response models
│       ├── banner_res_model.dart    # Banner data
│       ├── complaint_res_model.dart
│       ├── coupon_res_model.dart
│       ├── kit_response/            # Customize kit response models
│       ├── notification_list_res.dart
│       ├── pandit_res/              # Pandit response models
│       ├── payment_res/             # Payment response models
│       ├── policy_res/              # Terms, Privacy, About Us, Refund
│       ├── product_booked_res/      # Order and review response models
│       ├── product_res/             # Product, Category, Cart, Wishlist models
│       └── wallet_res/              # Wallet response models
│
├── repo/                            # Repository layer (1 class per domain)
│   ├── auth_repo.dart
│   ├── product_repo.dart
│   ├── address_repo.dart
│   ├── booking_repo.dart
│   ├── complaint_repo.dart
│   ├── coupon_repo.dart
│   ├── customize_kit_repo.dart
│   ├── notification_repo.dart
│   ├── pandit_repo.dart
│   ├── payment_repo.dart
│   ├── policy_repo.dart
│   ├── profile_repo.dart
│   ├── wallet_repo.dart
│   └── wishlist_repo.dart
│
├── res/                             # Resources / constants
│   ├── app_colors.dart              # Color palette
│   ├── app_urls.dart                # All API endpoint URLs
│   ├── app_image.dart               # Asset path strings
│   └── app_string.dart              # String constants
│
├── routes/
│   ├── app_routes.dart              # Route name constants
│   └── app_pages.dart               # Route to Widget map
│
├── utils/
│   ├── textstyle.dart               # Text style helpers (text8 to text30)
│   ├── components.dart              # Reusable widget utilities
│   ├── custom_button.dart           # AppButton, CustomTextButton
│   ├── custom_textfields.dart       # AppTextField, NumberTextField
│   ├── custom_snackbar.dart         # AppSnackbar (success/error/warning)
│   ├── app_validation.dart          # Form validators
│   ├── localStogare_service/
│   │   ├── auth_localStorage_service.dart  # Token and user storage
│   │   └── location_storage.dart           # City/state/pincode storage
│   └── service/
│       ├── firebase_notification.dart  # FCM initialization and handling
│       ├── helper_methods.dart          # Utility functions (capitalizeWords, etc.)
│       └── location_checker.dart        # GPS permission checker
│
├── view_model/
│   ├── before_login_provider/
│   │   ├── auth_provider.dart       # Register / Login / OTP / Resend
│   │   ├── auth_state.dart          # AuthState model
│   │   └── profile_provider.dart    # Profile image picker provider
│   └── after_login_provider/
│       ├── account_provider.dart    # userProvider, updateProfile, deleteAccount
│       ├── home_provider/
│       │   ├── home_provider.dart          # productProvider, bannerProvider, bottomNavProvider
│       │   ├── product_state.dart          # ProductState model
│       │   ├── cart_provider.dart          # CartNotifier (offline-first + debounced sync)
│       │   ├── wishlist_provider.dart      # Wishlist with optimistic UI
│       │   ├── category_provider.dart      # categoryProvider (FutureProvider)
│       │   ├── brands_provider.dart        # brandsProvider
│       │   ├── sub_category_provider.dart  # subCategoryProvider
│       │   ├── notification_provider.dart  # NotificationNotifier + state
│       │   ├── pending_review_provider.dart
│       │   └── product_details_provider.dart
│       ├── checkout_providers/
│       ├── customize_kit_providers/
│       ├── order_provider/
│       ├── pandit_provider/
│       └── wallet_provider/
│
└── views/
    ├── before_login/
    │   ├── splash_screen.dart
    │   ├── login_page.dart
    │   ├── register_screen.dart
    │   └── otp_verfied_screen.dart
    ├── after_login/
    │   ├── home_screen.dart
    │   ├── category_page.dart
    │   ├── search_product_page.dart
    │   ├── notification_page.dart
    │   ├── product/
    │   │   ├── product_details.dart
    │   │   ├── my_cart_page.dart
    │   │   ├── daliy_pooja_essential_page.dart
    │   │   ├── product_image_viewer_page.dart
    │   │   └── checkout/
    │   │       ├── order_summary_page.dart
    │   │       ├── address_page.dart
    │   │       ├── payment_page.dart
    │   │       └── success_page.dart
    │   ├── pandit/
    │   │   ├── book_pandit_page.dart
    │   │   ├── book_retual_page.dart
    │   │   ├── pandit_details_page.dart
    │   │   ├── checkout_pandit/
    │   │   ├── bookings/
    │   │   └── pandit_recommended_kit_pages/
    │   ├── customize_kit/
    │   │   ├── customize_kit_search_page.dart
    │   │   ├── festival_kit_details.dart
    │   │   └── kit_order_summary_page.dart
    │   ├── order/
    │   │   ├── my_order_screen.dart
    │   │   ├── order_details_screen.dart
    │   │   └── track_order_screen.dart
    │   ├── profile/
    │   │   ├── my_profile_Page.dart
    │   │   ├── profile _edit_Page.dart
    │   │   ├── saved_address_page.dart
    │   │   ├── my_fav_products.dart
    │   │   ├── my_coupon_page.dart
    │   │   ├── help_support_page.dart
    │   │   ├── delete_account_page.dart
    │   │   └── policy/
    │   └── wallet/
    │       └── my_wallet_screen.dart
    ├── custom_widget/
    │   ├── Product_card.dart         # Reusable product card (grid and horizontal)
    │   ├── empty_data_widget.dart
    │   ├── pending_review_card.dart
    │   ├── product_image_slider.dart
    │   └── rating_summary_widget.dart
    ├── custom_loader.dart/
    │   └── product_loader.dart       # Skeleton loaders
    ├── global_widgets/
    │   ├── bottom_cart_bar.dart      # Floating cart bottom bar
    │   └── product_details_bottom_sheet.dart
    └── service_pages/
        ├── location_page.dart        # City/location selection
        └── location_provider.dart   # LocationModel and locationProvider
```

---

## 4. Architecture Overview

The app follows **MVVM with Repository pattern** layered as:

```
Views (Widgets)
    |
    | ref.watch / ref.read
    v
ViewModels (Riverpod Providers / Notifiers)
    |
    v
Repositories (Repo classes)
    |                  |
    v                  v
Network Layer     Local Storage
(Dio / NetworkApiService)    (SharedPreferences)
    |
    v
Remote API: https://api.samagran.com/api
```

**Key principles:**
- **Views** only consume providers via `ref.watch()` / `ref.read()`. No direct API calls in widgets.
- **Providers / Notifiers** orchestrate business logic and call repositories.
- **Repositories** are plain Dart classes that interact with the network or local storage.
- **Models** are pure data classes (fromJson / toJson).
- `NetworkApiService` (Dio) is the single HTTP client with a logging interceptor and centralised error handling.

---

## 5. Navigation and Routing

The app uses **Flutter named routes** defined in two files:

| File | Role |
|---|---|
| `app_routes.dart` | Static String route name constants |
| `app_pages.dart` | Map of route names to WidgetBuilders |

### All Routes

```
/splash          -> SplashScreen
/loginPage       -> LoginPage
/register        -> RegisterScreen
/otp             -> VerifyOtpScreen
/locationPage    -> LocationPage

/home            -> MyHomeScreen (bottom nav shell)
/notification    -> NotificationPage
/searchProduct   -> SearchProductPage

/productDetails  -> ProductDetails
/myCart          -> MyCartPage
/orderSummary    -> OrderSummaryScreen
/addressPage     -> AddressPage
/paymentPage     -> PaymentPage
/successPage     -> SuccessPage

/profile         -> ProfilePage
/editProfile     -> ProfileEditPage
/savedAddress    -> SavedAddressesScreen
/favProduct      -> MyFavProducts
/coupon          -> CouponPage
/myWallet        -> MyWalletScreen

/bookPandit      -> BookPanditPage
/panditDetails   -> PanditDetailsPage
/serviceSelection-> ServiceSelectionScreen
/timeSelection   -> TimeSlotSelectionScreen
/addressSelection-> AddressSelectionScreen
/bookingSummary  -> BookingSummaryScreen
/myBooking       -> MyBookingsPage
/myBookingDetails-> MyBookingDetails

/festivalKitDetails -> FestivalKitDetails
/kitOrderSummary -> KitOrderSummaryPage

/myOrder         -> MyOrdersPage
/orderDetails    -> OrderDetailsPage
/trackOrder      -> TrackOrderPage
```

### Bottom Navigation Shell — MyHomeScreen

`MyHomeScreen` in `main.dart` is the main post-login shell. It uses an `IndexedStack` controlled by `bottomNavProvider` (a `StateProvider<int>`) with 4 tabs:

| Index | Tab | Widget |
|---|---|---|
| 0 | Home | `HomeScreen` |
| 1 | Book Pandit | `BookRetualPage` |
| 2 | Customize Kit | `CustomizePoojaKitScreen` |
| 3 | Categories | `CategoryPage` |

The back button is intercepted via `PopScope` — if the current tab is not `0`, it navigates back to Home; otherwise it shows an "Exit App" dialog.

---

## 6. State Management (Riverpod)

The app uses **`flutter_riverpod ^3.3.1`** with both legacy (`StateNotifierProvider`, `StateProvider`) and modern (`AsyncNotifierProvider`) APIs.

### Provider Inventory

| Provider | Type | Location | Purpose |
|---|---|---|---|
| `bottomNavProvider` | `StateProvider<int>` | `home_provider.dart` | Current bottom nav index |
| `locationProvider` | `StateProvider<LocationModel?>` | `location_provider.dart` | Current city/state |
| `productProvider` | `AsyncNotifierProvider<ProductNotifier, ProductState>` | `home_provider.dart` | All products + sections |
| `bannerProvider` | `FutureProvider<BannerResModel>` | `home_provider.dart` | Home banners |
| `categoryProvider` | FutureProvider | `category_provider.dart` | Category list |
| `cartProvider` | `StateNotifierProvider<CartNotifier, CartState>` | `cart_provider.dart` | Cart items |
| `cartQuantityProvider` | `Provider.family<int, String>` | `cart_provider.dart` | Qty for a productId |
| `totalItemsProvider` | `Provider<int>` | `cart_provider.dart` | Total cart item count |
| `totalPriceProvider` | `Provider<double>` | `cart_provider.dart` | Total cart price |
| `wishlistProvider` | `StateNotifierProvider<WishlistNotifier, WishlistState>` | `wishlist_provider.dart` | Wishlist |
| `isWishlistedProvider` | `Provider.family<bool, String>` | `wishlist_provider.dart` | Is product wishlisted |
| `isWishlistTogglingProvider` | `Provider.family<bool, String>` | `wishlist_provider.dart` | Is toggling in progress |
| `notificationProvider` | `StateNotifierProvider<NotificationNotifier, NotificationState>` | `notification_provider.dart` | Notifications |
| `userProvider` | `FutureProvider<Map?>` | `account_provider.dart` | Logged-in user data |
| `updateProfileProvider` | `StateNotifierProvider` | `account_provider.dart` | Profile update state |
| `deleteAccountProvider` | `StateNotifierProvider` | `account_provider.dart` | Account deletion state |
| `authProvider` | `AsyncNotifierProvider<AuthNotifier, AuthState>` | `auth_provider.dart` | Auth state (login/register/OTP) |
| `phoneProvider` | `StateProvider<String>` | `auth_provider.dart` | Phone number shared between screens |
| `otpProvider` | `StateProvider<List<String>>` | `auth_provider.dart` | OTP digit list |
| `imageSliderIndexProvider` | `StateProvider.family<int, String>` | `home_provider.dart` | Product image carousel index |

### Global Keyboard Dismiss

The `GestureDetector` at the top of `MaterialApp.builder` in `main.dart` calls `FocusManager.instance.primaryFocus?.unfocus()` on any tap, and a `NotificationListener<ScrollStartNotification>` does the same on scroll. This ensures the keyboard is dismissed globally without needing per-screen code.

---

## 7. API Layer

### Base URL

```
https://api.samagran.com/api
```

### NetworkApiService — Methods

| Method | HTTP Verb | Notes |
|---|---|---|
| `getApi(url)` | GET | Auth token set via `setToken()` before call |
| `postApi(url, data)` | POST | |
| `pacthApi(url, data)` | PATCH | Note: typo in method name (should be patchApi) |
| `putApi(url, data)` | PUT | |
| `deleteApi(url, data)` | DELETE | |

### Error Handling

`NetworkApiService._handleDioError()` maps Dio exceptions to custom `AppException` subclasses:

| HTTP Status | Exception Class |
|---|---|
| Timeout | `FetchDataException` |
| 400 | `BadRequestException` |
| 401 / 403 | `UnauthorizedException` |
| 500+ | `FetchDataException` |
| No internet | `FetchDataException` |

In `HomeScreen`, `UnauthorizedException` triggers an auth error dialog that forces logout.

### API Endpoints Reference

| Category | Endpoint |
|---|---|
| Auth | `POST /auth/signup`, `POST /auth/send-otp`, `POST /auth/verify-otp`, `POST /auth/resend-otp`, `GET /auth/verify-token` |
| Products | `GET /user/items?city=&pincode=` |
| Product Detail | `GET /user/items/:id` |
| Banners | `GET /banners` |
| Categories | `GET /category?city=&pincode=` |
| Cart | `GET /cart`, `POST /cart/add`, `POST /cart/remove`, `DELETE /cart/:id` |
| Wishlist | `GET /wishlist/my`, `POST /wishlist/toggle` |
| Orders | `GET /order/my`, `GET /order/:id` |
| Address | `GET /order/addresses` |
| Payment (Products) | `POST /order/payment/razorpay/order`, `POST /order/place` |
| Pandit | `GET /pandit-bookings/pandits`, `GET /pandit-bookings/rituals`, `POST /pandit-bookings` |
| Wallet | `GET /user/wallet/transactions`, `POST /user/wallet/topup/razorpay/order` |
| Notifications | `GET /user/notifications`, `PATCH /user/notifications/:id/read` |
| Profile | `PUT /user`, `DELETE /user/delete-account` |
| Policy | `GET /legal/term`, `GET /legal/privacy`, `GET /legal/aboutus`, `GET /legal/refund` |

---

## 8. Authentication Flow

### Flow Diagram

```
App Start -> SplashScreen
               |
               v
         Token in SharedPreferences?
          No  |          | Yes
              v          v
         LoginPage   MyHomeScreen
              |
              v
         Enter Mobile Number
              |
              v
         AuthNotifier.login()
              |
         isNewUser?
          Yes |          | No
              v          v
         'Not registered'  VerifyOtpScreen
          warning             |
                              v
                         Enter 6-digit OTP
                              |
                              v
                         AuthNotifier.verifyOtp()
                              |
                         success?
                          Yes |          | No
                              v          v
                         Save token  Show error
                         + user      snackbar
                              |
                              v
                         LocationPage -> MyHomeScreen
```

### Register Flow

`RegisterScreen` -> fill name, email, address, phone, optional profile photo -> `AuthNotifier.register()` -> if `isNewUser == true` (new user successfully created), navigate to `VerifyOtpScreen`.

### Token Storage

`AuthLocalstorageService` (in `utils/localStogare_service/`) manages:
- `saveUser(token, userJson)` — stores token and user profile in SharedPreferences
- `getToken()` — retrieves JWT token
- `getUser()` — retrieves user profile map
- `clear()` — clears all auth data on logout

### Token Validity Check

On every `HomeScreen` init, `_checkTokenValidity()` calls `GET /auth/verify-token` with the stored token. If the response indicates `expired: true` or returns 401/403, an `_AuthErrorDialog` is shown that logs the user out.

---

## 9. Home Screen

`home_screen.dart` — `HomeScreen` (ConsumerStatefulWidget)

### Layout Structure

```
Stack
├── Container (background color)
│   └── Column
│       ├── Header (logo text + location + profile avatar)
│       ├── Search bar + Wallet icon + Notification icon (with unread badge)
│       ├── Pending Review Card (shown if user has pending product reviews)
│       ├── Category Chips (horizontal scrollable filter pills)
│       └── Expanded (products area)
│           ├── Loading -> ProductListingSkeleton
│           ├── Error -> "Something went wrong"
│           └── Data (two modes):
│               ├── Filtered mode (category chip selected) -> flat 3-column grid
│               └── Default mode (all categories, sectioned):
│                   ├── Banner carousel (CarouselSlider, height 120)
│                   ├── Most Trending -> _buildHorizontalScroll
│                   ├── Daily Rituals -> _buildHorizontalScroll
│                   ├── Popular -> _buildHorizontalScroll
│                   └── Puja Essentials -> _buildProductGrid (3-column)
└── BottomCartBar (floating, shown when cart is non-empty)
```

### Product Sections (Data Source)

Products are fetched once via `productProvider` which calls `ProductRepo.getProducts()`. The result is split into sections based on boolean flags on each product:

| Section | Product Flag |
|---|---|
| Most Trending | `product.isRecommended == true` |
| Daily Rituals | `product.isEveryDayRitual == true` |
| Popular | `product.isMostUsed == true` |
| Puja Essentials | `product.isMostPoojaEssentials == true` |

### _buildHorizontalScroll — Responsive Sizing

The horizontal scroll height is dynamically calculated based on screen width and font scale:

```dart
// Card width: ~36% of screen on phones, ~22% on tablets
final cardWidth = screenWidth > 600
    ? (screenWidth / 4.5).clamp(145.0, 185.0)
    : (screenWidth * 0.36).clamp(128.0, 155.0);

// Image height: 90% of inner card width, clamp 105 to 140
final imageHeight = (innerCardWidth * 0.90).clamp(105.0, 140.0);

// Info height: scales with system font scale, clamp 115 to 165
final infoHeight = (120.0 * textScale).clamp(115.0, 165.0);

// Total scroll container height = image + info + 14 padding
final scrollHeight = imageHeight + infoHeight + 14.0;
```

The `imageHeight` is passed explicitly to `ProductCard` to prevent the card from calculating a default using the full screen width.

### _buildProductGrid — Responsive 3-Column Grid

Uses `LayoutBuilder` to get constraints at runtime:

```dart
final cardWidth = (constraints.maxWidth - 16 - 12) / 3;
final imageHeight = cardWidth;  // square image
final dynamicInfoHeight = (120.0 * textScale).clamp(115.0, 160.0);
final ratio = cardWidth / (imageHeight + dynamicInfoHeight);
```

No hardcoded heights — always adapts to screen size.

---

## 10. Product System

### ProductCard Widget

`Product_card.dart` — `ProductCard` (ConsumerWidget)

A reusable card used in both horizontal scroll rows and 3-column grids.

**Constructor:**
```dart
ProductCard({
  required Product product,
  double? imageHeight,  // optional; calculated from card width if null
})
```

**Layout (when height is bounded — horizontal scroll):**

```
Container (white, rounded corners)
└── LayoutBuilder
    └── Column
        ├── SizedBox(height: effectiveImageHeight)    <- image section
        │   └── Stack
        │       ├── Product image (Carousel if multiple images, else single)
        │       ├── Wishlist heart icon (top-right overlay)
        │       ├── Page dots (bottom-left, only if multiple images)
        │       └── ADD button / Qty stepper (bottom-right overlay)
        │           OR "Out of Stock" semi-transparent strip
        └── Expanded -> SingleChildScrollView (non-scrollable)
            └── Padding -> Column
                ├── Brand name (if available)
                ├── Unit / quantity string (if available)
                ├── Current price (Rs. X)
                ├── Old price + discount percentage (if hasDiscount)
                └── Product title (max 2 lines, ellipsis overflow)
```

**When height is unbounded** (e.g., in a feed-style ListView), the info section uses `mainAxisSize: MainAxisSize.min` instead of `Expanded`.

### _QuantityControl

An `AnimatedSwitcher` that transitions between:
- **ADD button** (quantity == 0) — calls `CartNotifier.addItem()`
- **Quantity stepper** (minus / count / plus) — calls `increaseQuantity` / `decreaseQuantity`

### Product Detail Page

`product_details.dart` — full product page with:
- Multi-image carousel with pinch-to-zoom
- Product info, description, full specifications
- Reviews / ratings section
- Related products horizontal scroll
- Add to cart / wishlist

### TypeOfCategoryPage (Daily Pooja Essential Page)

`daliy_pooja_essential_page.dart` — a generic full-page product listing screen. Accepts a `categoryType` parameter to filter products. Used by "See All" and "View More" buttons throughout the app.

---

## 11. Cart System

`cart_provider.dart`

### Architecture: Offline-First with Debounced Sync

The cart is designed to be instant and resilient to network failures:

1. User taps ADD / +/-
2. State updates immediately in memory
3. Cart is saved to SharedPreferences immediately
4. An 800ms debounce timer starts
5. If user taps again, timer resets (prevents excessive API calls)
6. After 800ms of no taps, API call fires (POST /cart/add or POST /cart/remove)

On app start:
1. Load cart from SharedPreferences (instant display)
2. Fetch cart from server (GET /cart)
3. Server data wins — replace local cart with server cart

### Key Providers

- `cartProvider` — full `CartState` (items list + isLoading flag)
- `cartQuantityProvider(productId)` — `int` quantity for a specific product
- `totalItemsProvider` — `int` total quantity across all cart items  
- `totalPriceProvider` — `double` total price

### BottomCartBar

`bottom_cart_bar.dart` — A floating bottom bar that appears when the cart has items. Shows total item count, total price, and a "View Cart" button navigating to `/myCart`.

---

## 12. Pandit Booking System

`book_pandit_page.dart` — Pandit listing and search
`book_retual_page.dart` — Ritual type selection (accessed from bottom nav tab 1)

### Booking Flow

```
Book Pandit Tab (BookRetualPage)
    |
    v
Select ritual type
    |
    v
Browse pandits (BookPanditPage)
    |
    v
PanditDetailsPage
    |
    v
ServiceSelectionScreen
    |
    v
TimeSlotSelectionScreen
    |
    v (depending on ritual type)
AddressSelectionScreen
OR TempleSelectionScreen
OR OnlineBookingDetails
    |
    v
BookingSummaryScreen
    |
    v
Razorpay payment
    |
    v
PaymentSuccessScreen (/panditPayment)
```

### Pandit Booking Payment

1. `POST /pandit-bookings` — create booking order, receive Razorpay order ID
2. Open Razorpay SDK
3. On payment success → `POST /order/place` (verify and confirm)

---

## 13. Customize Kit System

Accessed from bottom nav tab 2 (`CustomizePoojaKitScreen`).

| Screen | Route | Purpose |
|---|---|---|
| `CustomizePoojaKitScreen` | (tab 2 direct) | Browse and search kit items |
| `FestivalKitDetails` | `/festivalKitDetails` | View festival kit, select items |
| `KitOrderSummaryPage` | `/kitOrderSummary` | Order summary before placing order |

Products are sourced from `productProvider` (same pool as home), filtered via `filterByCustKitCategory()` in `ProductNotifier`.

---

## 14. Category Page

`category_page.dart` — `CategoryPage` (ConsumerWidget)

Accessed from bottom nav tab 3. Shows all product categories as vertical sections. Each section contains:
- Category name + icon header row
- "View all >" button (navigates to `TypeOfCategoryPage` for that category)
- 3-column product grid showing up to 6 products

Products are filtered per section: `product.categoryId?.id == category.id`

---

## 15. Profile and Account Management

`my_profile_Page.dart` — `ProfilePage`

Profile screen shows user info (name, phone, email, address, avatar) and links to:

| Section | Route | Screen |
|---|---|---|
| Edit Profile | `/editProfile` | `ProfileEditPage` |
| Saved Addresses | `/savedAddress` | `SavedAddressesScreen` |
| My Orders | `/myOrder` | `MyOrdersPage` |
| My Bookings | `/myBooking` | `MyBookingsPage` |
| Favourites | `/favProduct` | `MyFavProducts` |
| My Coupons | `/coupon` | `CouponPage` |
| Wallet | `/myWallet` | `MyWalletScreen` |
| Help and Support | `/helpAndSupport` | `HelpPage` |
| About Us | `/aboutUs` | `AboutUsPage` |
| Refund Policy | `/refund` | `RefundPage` |
| Delete Account | `/accoundDelete` | `DeleteAccountScreen` |

### Profile Edit

`ProfileEditPage` uses `UpdateProfileNotifier` which calls `ProfileApi.updateProfile()` — a multipart PUT request that supports uploading a new profile image. On success, `userProvider` is invalidated to refresh the UI.

### Account Deletion

`DeleteAccountScreen` uses `DeleteAccountNotifier` which calls `PolicyRepo.deleteAccount(reason)`. On success, clears local storage and navigates to login screen.

---

## 16. Wallet System

`my_wallet_screen.dart`

- Displays wallet balance and transaction history
- Wallet top-up via Razorpay:
  1. `POST /user/wallet/topup/razorpay/order` → get Razorpay order ID
  2. Open Razorpay SDK
  3. On success → `POST /user/wallet/topup/confirm`

---

## 17. Notification System

`notification_provider.dart` — `NotificationNotifier`

### Features

- Paginated notification list (20 per page, loads more on scroll)
- Filter by All / Read / Unread
- Mark individual notification as read (optimistic update)
- Delete individual notification (optimistic)
- Clear all notifications

### Unread Badge

`notificationProvider` exposes `unreadCount` computed as:
```dart
int get unreadCount => notifications.where((n) => !n.isRead).length;
```
This is displayed as a red circle badge on the notification icon in `HomeScreen`.

### FCM Push Notifications

`FCMNotificationService` (in `utils/service/firebase_notification.dart`):
- Initializes Firebase Messaging
- Registers a background message handler
- FCM tokens are stored in SharedPreferences
- Token is sent to server via `POST /user/fcm-token` on every app launch

---

## 18. Location System

### LocationPage

`views/service_pages/location_page.dart` — shown when:
1. No city is saved (first launch after login)
2. User taps the location indicator in the home header to change city

Allows the user to search and select a city/state. Saves selection to `LocationStorage`.

### LocationStorage

`utils/localStogare_service/location_storage.dart` — persists:
- `city` (String)
- `state` (String)
- `pincode` (String, optional)

### locationProvider

`StateProvider<LocationModel?>` in `location_provider.dart`.  
Loaded from `LocationStorage` during `MyHomeScreen.initState()`.  
Used by:
- `HomeScreen` — to display current city in the header
- `ProductRepo` — to filter API results: `?city=...&pincode=...`

### GPS Permission Check

On every app start, `MyHomeScreen._handleLocationCheck()`:
1. If no city saved → navigates to `LocationPage`
2. If city saved but GPS permission not granted → shows non-blocking popup (user can skip)

---

## 19. Shared Utilities and Design System

### Colors — AppColors

| Name | Hex | Usage |
|---|---|---|
| `primary` | `#31181E` | Dark maroon — search field, brand color |
| `button` | `#CA1F48` | All CTA buttons, active chips, price highlights |
| `headerCard` | `#F3EFE6` | Header background (warm cream) |
| `background` | `#F6F6F6` | Page backgrounds |
| `white` | `#FFFFFF` | Cards, dialogs |
| `error` | `#EF4444` | Error states, out of stock |
| `success` | `#10B981` | Success states |
| `warning` | `#F59E0B` | Warning, discount badges |
| `textPrimary` | `#1A1A2E` | Main body text |
| `textSecondary` | `#6B7280` | Subtitles, hints |

### Text Styles — textstyle.dart

Helper functions return `TextStyle` using Poppins font family. All accept optional `fontWeight` and `color` params:

| Function | Font Size |
|---|---|
| `text8()` | 8px |
| `text10()` | 10px |
| `text11()` | 11px |
| `text12()` | 12px |
| `text13()` | 13px |
| `text14()` | 14px |
| `text15()` | 15px |
| `text16()` | 16px |
| `text18()` | 18px (bold default) |
| `text20()` | 20px (bold default) |
| `text24()` | 24px (bold default) |
| `text26()` | 26px (bold default) |
| `text30()` | 30px (bold default) |

### Reusable Widgets — components.dart

- `CustomCachedImage` — wrapper around `CachedNetworkImage` with error placeholder
- `capitalizeWords(String)` — capitalizes first letter of each word

### Custom Buttons — custom_button.dart

- `AppButton` — primary filled button with optional loading spinner
- `CustomTextButton` — text-only button (e.g., "Sign up", "Log in")

### Custom Text Fields — custom_textfields.dart

- `AppTextField` — standard text input with label, validators, capitalization support
- `NumberTextField` — numeric-only input (digits only formatter, max length, phone keyboard)

### Snackbar — custom_snackbar.dart

```dart
AppSnackbar.show(context, message: '...', type: SnackBarType.success);
// Types: .success, .error, .warning
```

---

## 20. Firebase Integration

| Feature | Package | Where Initialized |
|---|---|---|
| Firebase core | `firebase_core` | `Firebase.initializeApp()` in `main()` |
| FCM push notifications | `firebase_messaging` | `FCMNotificationService().initialize()` in `main()` |
| Local notification display | `flutter_local_notifications` | Inside `FCMNotificationService` |

### FCM Token Flow

1. `MyHomeScreen._handleLocationCheck()` reads stored FCM token from SharedPreferences
2. If no token found, calls `FirebaseMessaging.instance.getToken()`
3. Posts token to `POST /user/fcm-token`
4. Token is refreshed on subsequent launches if missing

---

## 21. Known Patterns and Conventions

### File Naming Inconsistencies (Original, Not Modified)

- `Product_card.dart` — capital P (should be lowercase)
- `profile _edit_Page.dart` — has a space in the filename
- `otp_verfied_screen.dart` — typo ("verfied" instead of "verified")

### Method Naming Issues (Original, Not Modified)

- `pacthApi()` in `NetworkApiService` — typo for `patchApi()`

### Cart Debounce Pattern

All cart mutations immediately update local state + SharedPreferences for instant UI feedback, then debounce API calls by 800ms. Multiple rapid taps = one API call.

### Optimistic UI Pattern

`WishlistNotifier` uses optimistic updates: UI reflects wishlist toggle immediately; reverts on API failure.

### Auth Error Guard

`_authErrorShown` boolean flag in `HomeScreen` ensures only one auth error dialog is shown, even if multiple providers return `UnauthorizedException` simultaneously.

### Location-Filtered API Calls

Products, categories, brands, and sub-categories all pass `?city=&pincode=` query parameters from `LocationStorage`.

### Keyboard Dismiss — Global

Handled at `MaterialApp.builder` level via:
- `GestureDetector.onTap` — dismisses keyboard on any tap outside a text field
- `NotificationListener<ScrollStartNotification>` — dismisses keyboard when scrolling begins

This means **no per-screen keyboard dismiss code is needed**.

### Text Capitalization

| Field Type | TextCapitalization Setting |
|---|---|
| Name fields | `TextCapitalization.words` |
| Email fields | `TextCapitalization.none` |
| Address fields | `TextCapitalization.sentences` |
| Mobile / numeric | Not applicable (numeric keyboard) |

### Pull-to-Refresh Pattern

Pages with product lists use `RefreshIndicator`. On refresh, the relevant providers are `invalidated` via `ref.invalidate()`, which triggers a fresh fetch automatically.

---

*Documentation generated from codebase analysis. Last updated: September 2026.*

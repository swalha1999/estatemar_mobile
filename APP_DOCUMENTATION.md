# Estatemar Mobile App - Complete Documentation

## 📱 App Overview

Estatemar is a comprehensive real estate mobile application built with Flutter that allows users to discover properties, manage their own properties, list properties for sale, and track their real estate portfolio.

### Core Features
- 🏠 Property Discovery & Search
- ❤️ Favorites Management
- 📊 Portfolio Management
- 💰 ROI & Investment Tracking
- 📝 Property Listing Requests
- 👤 User Profile & Authentication
- 📰 Real Estate News

---

## 🎨 Design System

### Font Family
**Primary Font:** Montserrat (All weights)

### Font Sizes
```
Small:   12px  - Captions, labels, small text
Medium:  14px  - Body text, buttons, form fields
Large:   16px  - Headings, important text
XLarge:  18px  - Large headings, titles
```

### Font Weights
```
Light:     300
Regular:   400
Medium:    500
SemiBold:  600
Bold:      700
```

### Color Palette

#### Primary Colors
```
Primary:       #027BFF (Blue)
Primary Light: #E1F0FF
Primary Dark:  #0056CC
```

#### Text Colors
```
Text Primary:    #363636 (Dark Gray)
Text Secondary:  #6B7280 (Medium Gray)
Text Tertiary:   #9CA3AF (Light Gray)
Text Light:      #D1D5DB (Very Light Gray)
```

#### Background Colors
```
Background:           #FFFFFF (White)
Background Secondary: #F9FAFB
Background Tertiary:  #F3F4F6
Background Card:      #F8FAFC
```

#### Status Colors
```
Success:       #10B981 (Green)
Success Light: #D1FAE5
Warning:       #F59E0B (Orange)
Warning Light: #FEF3C7
Error:         #EF4444 (Red)
Error Light:   #FEE2E2
Info:          #3B82F6 (Blue)
Info Light:    #DBEAFE
```

#### Accent Colors
```
Orange:      #FF9800 + #FFF3E0 (light)
Purple:      #8B5CF6 + #F3E8FF (light)
Green:       #4CAF50 + #E8F5E8 (light)
Blue:        #2196F3 + #E3F2FD (light)
Indigo:      #6366F1 + #EEF2FF (light)
```

#### Neutral Grays (50-900)
```
Grey 50:   #F9FAFB
Grey 100:  #F3F4F6
Grey 200:  #E5E7EB
Grey 300:  #D1D5DB
Grey 400:  #9CA3AF
Grey 500:  #6B7280
Grey 600:  #4B5563
Grey 700:  #374151
Grey 800:  #1F2937
Grey 900:  #111827
```

### Border & Spacing
```
Border Radius:
- Small:  4px
- Medium: 8px
- Large:  12px
- XLarge: 16px
- Round:  20px

Border Colors:
- Light:  #E5E7EB
- Medium: #D1D5DB
- Dark:   #9CA3AF

Spacing Scale:
4, 8, 12, 16, 24, 32, 48, 64
```

### Component Styles

#### Cards
```
Background: White (#FFFFFF)
Elevation: 2
Shadow: Black 10% opacity
Border Radius: 12px
Margin: 16px horizontal, 8px vertical
```

#### Buttons

**Elevated Button (Primary)**
```
Background: #027BFF
Text Color: White
Border Radius: 8px
Padding: 24px horizontal, 12px vertical
Font: Montserrat SemiBold 14px
Elevation: 2
```

**Outlined Button**
```
Border: #027BFF
Text Color: #027BFF
Border Radius: 8px
Padding: 24px horizontal, 12px vertical
Font: Montserrat SemiBold 14px
```

**Text Button**
```
Text Color: #027BFF
Padding: 16px horizontal, 8px vertical
Font: Montserrat Medium 14px
```

#### Input Fields
```
Fill Color: #F9FAFB
Border: #E5E7EB (1px)
Border Radius: 8px
Focused Border: #027BFF (2px)
Error Border: #EF4444
Padding: 16px horizontal, 12px vertical
Label Font: Montserrat Medium 12px, #6B7280
Input Font: Montserrat Regular 14px, #363636
```

#### App Bar
```
Background: White
Elevation: 0
Text: Montserrat SemiBold 16px, #363636
Icon Size: 24px
Center Title: true
```

#### Bottom Navigation
```
Background: White
Selected Color: #027BFF
Unselected Color: #9CA3AF
Elevation: 8
Label Font: Montserrat SemiBold 12px
Type: Fixed
```

---

## 📐 App Structure

### Navigation Architecture

```
MainNavigationScreen (Bottom Navigation)
├── 0. Discover (HomeScreen)
├── 1. Favorites (FavoritesScreen)
├── 2. My Properties (MyPropertiesScreen / LoginScreen)
├── 3. Sell (SellScreen / LoginScreen)
└── 4. Profile (ProfileScreen / LoginScreen)
```

### Authentication Flow
```
App Launch
├─ Check Auth Status
│  ├─ Logged In → Continue to MainNavigationScreen
│  └─ Not Logged In → Show Login on Auth-Required Pages
│
Login Flow
├─ LoginScreen
│  ├─ Enter Email/Password
│  ├─ Sign In → API Auth
│  │  ├─ Success → Check Profile Complete
│  │  │  ├─ New User (< 10min old) → ProfileSetupScreen
│  │  │  └─ Existing User → MainNavigationScreen
│  │  └─ Error → Show Error Message
│  └─ Sign Up → Create Account → ProfileSetupScreen
│
ProfileSetupScreen
├─ Enter Full Name
├─ Enter Phone Number (Optional)
└─ Complete → MainNavigationScreen
```

---

## 📱 Screens & Features

### 1. Home Screen (Discover)
**Route:** `HomeScreen`

#### Features
- **Animated Search Header**
  - Collapses on scroll
  - Search input field
  - Filter icon
  - Logo display

- **Property Type Tabs**
  - All Listings
  - Apartment
  - Villa
  - House
  - Condo
  - Each with icon

- **Sorting Options**
  - Price: Low to High
  - Price: High to Low
  - Reset sorting

- **Advanced Search/Filters**
  - Location filter
  - Property type
  - Price range slider
  - Bedrooms/Bathrooms
  - Applied filters shown as chips

- **Property List**
  - Scrollable list of property cards
  - Each card shows:
    - Property image
    - Title
    - Price
    - Location
    - Bedrooms/Bathrooms/Area
    - Favorite button
  - Tap to view details

- **Navigation**
  - Tap property → PropertyViewScreen
  - Filter icon → AdvancedSearchScreen
  - Search → Filter by text

#### Layout
```
┌─────────────────────────┐
│ [Logo]  [Search] [Filter]│ ← Animated Header
├─────────────────────────┤
│ [All][Apt][Villa][House]│ ← Tabs
├─────────────────────────┤
│ [Active Filters Chips] │ ← If filters applied
├─────────────────────────┤
│                         │
│  ╔═══════════════════╗  │
│  ║  Property Card    ║  │
│  ║  [Image]     [❤]  ║  │
│  ║  Title            ║  │
│  ║  $500,000         ║  │
│  ║  📍 Location      ║  │
│  ║  🛏 2 🛁 2 📐 1200 ║  │
│  ╚═══════════════════╝  │
│                         │
│  ╔═══════════════════╗  │
│  ║  Property Card    ║  │
│  ╚═══════════════════╝  │
│                         │
└─────────────────────────┘
```

---

### 2. Favorites Screen
**Route:** `FavoritesScreen`

#### Features
- **Favorites List**
  - Shows all favorited properties
  - Same card layout as Home Screen
  - Remove from favorites button
  - Empty state if no favorites

- **Filtering**
  - Filter by property type
  - Sort by price

- **Actions**
  - Tap property → PropertyViewScreen
  - Heart icon → Remove from favorites

#### Layout
```
┌─────────────────────────┐
│ ❤️  Favorites            │ ← Header
├─────────────────────────┤
│ [Sort] [Filter]         │ ← Actions
├─────────────────────────┤
│                         │
│  ╔═══════════════════╗  │
│  ║  Property Card    ║  │
│  ║  [Image]     [❤]  ║  │
│  ║  ...              ║  │
│  ╚═══════════════════╝  │
│                         │
└─────────────────────────┘
```

---

### 3. My Properties Screen
**Route:** `MyPropertiesScreen`
**Auth Required:** Yes

#### Features
- **Portfolio Overview**
  - Total properties count
  - Total investment value
  - Current portfolio value
  - Total profit/loss (+ percentage)
  - Total annual rent income
  - Average rental yield

- **Properties List**
  - User's owned properties
  - Each card shows:
    - Property name
    - Purchase price
    - Current market value
    - Profit/Loss (with color coding)
    - Monthly rent
    - Purchase date
    - Status badges (For Sale, For Rent)

- **Sorting & Filtering**
  - Sort by profit/loss
  - Sort by value
  - Filter by status

- **Actions**
  - Add Property button (FAB)
  - Edit property
  - Delete property
  - View property details
  - View analytics

- **Analytics Charts**
  - Portfolio value over time
  - ROI breakdown
  - Rental income trends

#### Layout
```
┌─────────────────────────┐
│ My Properties     [+]   │ ← Header with Add button
├─────────────────────────┤
│ ╔═════════════════════╗ │
│ ║ Portfolio Overview  ║ │
│ ║ 5 Properties        ║ │
│ ║ Total: $2.5M        ║ │
│ ║ Profit: +$250K      ║ │
│ ║ Yield: 5.2%         ║ │
│ ╚═════════════════════╝ │
├─────────────────────────┤
│ [Sort] [Filter]         │
├─────────────────────────┤
│                         │
│  ╔═══════════════════╗  │
│  ║  Property Name    ║  │
│  ║  Purchase: $500K  ║  │
│  ║  Current: $550K   ║  │
│  ║  📈 +$50K (+10%)  ║  │
│  ║  🏷️ For Sale       ║  │
│  ║  [Edit] [Delete]  ║  │
│  ╚═══════════════════╝  │
│                         │
└─────────────────────────┘
```

---

### 4. Add Property Screen
**Route:** `AddPropertyScreen`
**Auth Required:** Yes

#### Features
- **Property Information Form**
  - Property Name (required)
  - Address (required)
  - Purchase Price (required)
  - Current Market Value (optional)
  - Property Type dropdown
  - Bedrooms count
  - Bathrooms count
  - Area (sq ft)
  - Purchase Date picker
  - Monthly Rent
  - Description

- **Image Upload**
  - Multiple images support
  - Camera or gallery
  - Preview thumbnails
  - Remove images

- **Calculations (Auto)**
  - Profit/Loss
  - ROI percentage
  - Rental yield

- **Validation**
  - Required fields highlighted
  - Price formatting with commas
  - Date validation

- **Actions**
  - Save button
  - Cancel button

#### Layout
```
┌─────────────────────────┐
│ ← Add Property          │
├─────────────────────────┤
│                         │
│ Property Name *         │
│ ┌─────────────────────┐ │
│ │                     │ │
│ └─────────────────────┘ │
│                         │
│ Address *               │
│ ┌─────────────────────┐ │
│ │                     │ │
│ └─────────────────────┘ │
│                         │
│ Purchase Price *        │
│ ┌─────────────────────┐ │
│ │ $ 500,000          │ │
│ └─────────────────────┘ │
│                         │
│ Market Value            │
│ ┌─────────────────────┐ │
│ │ $ 550,000          │ │
│ └─────────────────────┘ │
│                         │
│ Property Type           │
│ ┌─────────────────────┐ │
│ │ House         [v]  │ │
│ └─────────────────────┘ │
│                         │
│ Bedrooms  Bathrooms     │
│ ┌────────┐ ┌─────────┐ │
│ │   3    │ │    2    │ │
│ └────────┘ └─────────┘ │
│                         │
│ Photos                  │
│ ┌───┐ ┌───┐ ┌───┐      │
│ │[+]│ │ 📷 │ │ 📷 │     │
│ └───┘ └───┘ └───┘      │
│                         │
│ [Cancel]     [Save]     │
│                         │
└─────────────────────────┘
```

---

### 5. Edit Property Screen
**Route:** `EditPropertyScreen`
**Auth Required:** Yes

#### Features
- Same as Add Property Screen but:
  - Pre-filled with existing data
  - Delete property option
  - Update button instead of Save
  - Track changes
  - Confirmation on delete

---

### 6. Property View Screen (Detail)
**Route:** `PropertyViewScreen`

#### Features
- **Image Gallery**
  - Full-width image carousel
  - Image indicators
  - Tap to view fullscreen
  - Swipe between images

- **Property Details**
  - Title
  - Price (large, prominent)
  - Location with map pin icon
  - Description
  - Property type badge
  - Features grid:
    - Bedrooms
    - Bathrooms
    - Area (sq ft)
    - Year built
    - Parking spots
    - Floors

- **Amenities Section**
  - List with checkmarks
  - Categories:
    - Basic (AC, Heating, etc.)
    - Security (Alarm, CCTV, etc.)
    - Lifestyle (Pool, Gym, etc.)

- **Location & Map**
  - Address
  - Embedded map view
  - Get directions button

- **Financial Information**
  - Price breakdown
  - Monthly payment estimate
  - HOA fees
  - Property taxes

- **Similar Properties**
  - Horizontal scrollable list
  - Mini property cards

- **Actions**
  - Favorite button (persistent)
  - Share button
  - Contact agent button
  - Schedule viewing button

- **3D View (if available)**
  - Interactive 3D model
  - Fullscreen option

#### Layout
```
┌─────────────────────────┐
│ [← Back]      [❤] [⋮]  │
│                         │
│ ╔═══════════════════╗   │
│ ║   [Property       ║   │
│ ║    Image]         ║   │
│ ║                   ║   │
│ ╚═══════════════════╝   │
│ ● ● ○ ○ ○              │ ← Image indicators
├─────────────────────────┤
│                         │
│ Modern Downtown Apt     │
│ $500,000               │
│ 📍 Downtown, City      │
│                         │
│ ┌─────────────────────┐ │
│ │ 🛏 2  🛁 2  📐 1200 │ │
│ └─────────────────────┘ │
│                         │
│ Description             │
│ Beautiful modern...     │
│                         │
│ Amenities               │
│ ✓ AC  ✓ Heating        │
│ ✓ Parking  ✓ Elevator  │
│                         │
│ Location                │
│ ┌─────────────────────┐ │
│ │     [Map View]      │ │
│ └─────────────────────┘ │
│                         │
│ Similar Properties      │
│ ← [Card] [Card] [Card] →│
│                         │
│ [Contact Agent]         │
│ [Schedule Viewing]      │
│                         │
└─────────────────────────┘
```

---

### 7. Property Search Screen
**Route:** `PropertySearchScreen`

#### Features
- **Search Bar**
  - Text input
  - Real-time search
  - Search history
  - Clear button

- **Quick Filters**
  - Property type chips
  - Price range chips
  - Bedrooms chips

- **Recent Searches**
  - Last 10 searches
  - Tap to search again
  - Clear history

- **Results List**
  - Filtered properties
  - Count indicator
  - Same card layout

#### Layout
```
┌─────────────────────────┐
│ ← Search Properties     │
├─────────────────────────┤
│ ┌─────────────────────┐ │
│ │ 🔍 Search...     [x]│ │
│ └─────────────────────┘ │
│                         │
│ Quick Filters           │
│ [Apartment] [Villa]     │
│ [$100K-$500K] [2+ Beds] │
│                         │
│ Recent Searches         │
│ • Downtown apartments   │
│ • Villa with pool       │
│ • Luxury condos         │
│                         │
│ Results (15)            │
│  ╔═══════════════════╗  │
│  ║  Property Card    ║  │
│  ╚═══════════════════╝  │
│                         │
└─────────────────────────┘
```

---

### 8. Advanced Search Screen
**Route:** `AdvancedSearchScreen`

#### Features
- **Location Filter**
  - Dropdown with all locations
  - "Any" option

- **Property Type**
  - All types as chips
  - Multiple selection

- **Price Range**
  - Dual slider
  - Min/Max labels
  - Current values display

- **Bedrooms & Bathrooms**
  - Number steppers
  - "Any" option

- **Area Range**
  - Min/Max inputs
  - Square feet unit

- **Listing Type**
  - For Sale
  - For Rent
  - Both

- **Additional Filters**
  - Year built range
  - Parking spaces
  - Pet friendly
  - Furnished

- **Actions**
  - Apply filters button
  - Reset all button
  - Active filter count badge

#### Layout
```
┌─────────────────────────┐
│ ← Advanced Search   [5] │ ← Active filter count
├─────────────────────────┤
│                         │
│ Location                │
│ ┌─────────────────────┐ │
│ │ Any Location    [v] │ │
│ └─────────────────────┘ │
│                         │
│ Property Type           │
│ [House] [Apartment]     │
│ [Villa] [Condo]         │
│                         │
│ Price Range             │
│ $100K ━━━━●━━━━ $1M     │
│ Min: $100K  Max: $1M    │
│                         │
│ Bedrooms                │
│ [-] 2 [+]               │
│                         │
│ Bathrooms               │
│ [-] 2 [+]               │
│                         │
│ Area (sq ft)            │
│ Min ┌────┐  Max ┌────┐  │
│     │1000│      │5000│  │
│     └────┘      └────┘  │
│                         │
│ Listing Type            │
│ ( ) For Sale            │
│ ( ) For Rent            │
│ (•) Both                │
│                         │
│ [Reset]  [Apply (5)]    │
│                         │
└─────────────────────────┘
```

---

### 9. Sell Screen
**Route:** `SellScreen`
**Auth Required:** Yes

#### Features
- **Header Section**
  - Title: "Sell Your Property"
  - Subtitle: "List your property with us"

- **Property Selection**
  - Dropdown of user's properties
  - "Select a property to list"

- **Selected Property Preview**
  - Property name
  - Current market value
  - Purchase price
  - Profit/loss indicator

- **Listing Details**
  - Asking price input
  - Auto-filled with market value
  - Price validation
  - Editable

- **Listing Requests List**
  - Show all user's listing requests
  - Status badges:
    - Pending (Orange)
    - Approved (Green)
    - Rejected (Red)
    - Cancelled (Gray)

- **Request Card Details**
  - Property name
  - Asking price
  - Status
  - Request date
  - Actions (Cancel if pending)

- **Actions**
  - Submit listing request
  - Cancel request
  - View request details

- **Empty State**
  - If no properties: "Add properties to list them"
  - Link to Add Property
  - Icon and message

#### Layout
```
┌─────────────────────────┐
│ Sell Your Property      │
├─────────────────────────┤
│                         │
│ Select Property         │
│ ┌─────────────────────┐ │
│ │ Choose property [v] │ │
│ └─────────────────────┘ │
│                         │
│ ╔═══════════════════╗   │
│ ║ Selected Property ║   │
│ ║ Modern House      ║   │
│ ║ Market: $550K     ║   │
│ ║ Purchase: $500K   ║   │
│ ║ 📈 +$50K (+10%)   ║   │
│ ╚═══════════════════╝   │
│                         │
│ Asking Price            │
│ ┌─────────────────────┐ │
│ │ $ 550,000          │ │
│ └─────────────────────┘ │
│                         │
│ [Submit Listing Request]│
│                         │
│ Your Listing Requests   │
│                         │
│ ╔═══════════════════╗   │
│ ║ Modern House      ║   │
│ ║ $550,000          ║   │
│ ║ [⏰ Pending]      ║   │
│ ║ Oct 3, 2025       ║   │
│ ║ [Cancel Request]  ║   │
│ ╚═══════════════════╝   │
│                         │
└─────────────────────────┘
```

---

### 10. Profile Screen
**Route:** `ProfileScreen`
**Auth Required:** Yes

#### Features
- **Profile Header**
  - Avatar (initials if no photo)
  - User name
  - Email address
  - Join date
  - Edit profile button

- **Statistics Cards**
  - Total Properties
  - Total Investment
  - Portfolio Value
  - Total Profit

- **Menu Items**
  - Edit Profile
  - My Listings
  - Favorites
  - Settings
  - Help & Support
  - About
  - Logout

- **Actions**
  - Tap Edit Profile → EditProfileScreen
  - Tap Logout → Confirmation → Logout

#### Layout
```
┌─────────────────────────┐
│ Profile                 │
├─────────────────────────┤
│                         │
│   ╔════════════════╗    │
│   ║   [Avatar]     ║    │
│   ║   John Doe     ║    │
│   ║ john@email.com ║    │
│   ║ Joined Oct 2025║    │
│   ╚════════════════╝    │
│   [Edit Profile]        │
│                         │
│ ╔═════╗ ╔═════╗         │
│ ║  5  ║ ║ $2M ║         │
│ ║Props║ ║Value║         │
│ ╚═════╝ ╚═════╝         │
│                         │
│ ─────────────────────   │
│ 👤 Edit Profile      >  │
│ ─────────────────────   │
│ 🏠 My Listings       >  │
│ ─────────────────────   │
│ ❤️  Favorites         >  │
│ ─────────────────────   │
│ ⚙️  Settings          >  │
│ ─────────────────────   │
│ ❓ Help & Support    >  │
│ ─────────────────────   │
│ ℹ️  About             >  │
│ ─────────────────────   │
│ 🚪 Logout                │
│ ─────────────────────   │
│                         │
└─────────────────────────┘
```

---

### 11. Edit Profile Screen
**Route:** `EditProfileScreen`
**Auth Required:** Yes

#### Features
- **Profile Photo**
  - Current photo preview
  - Change photo button
  - Camera or gallery option
  - Remove photo option

- **Form Fields**
  - Full Name (required)
  - Email (read-only)
  - Phone Number
  - Bio/About

- **Validation**
  - Name required
  - Phone format validation
  - Character limits

- **Actions**
  - Save button
  - Cancel button
  - Delete account (danger zone)

#### Layout
```
┌─────────────────────────┐
│ ← Edit Profile          │
├─────────────────────────┤
│                         │
│      ┌─────────┐        │
│      │ [Photo] │        │
│      └─────────┘        │
│    [Change Photo]       │
│                         │
│ Full Name *             │
│ ┌─────────────────────┐ │
│ │ John Doe           │ │
│ └─────────────────────┘ │
│                         │
│ Email                   │
│ ┌─────────────────────┐ │
│ │ john@email.com     │ │
│ └─────────────────────┘ │
│ (Cannot be changed)     │
│                         │
│ Phone Number            │
│ ┌─────────────────────┐ │
│ │ +1 234 567 8900    │ │
│ └─────────────────────┘ │
│                         │
│ Bio                     │
│ ┌─────────────────────┐ │
│ │                     │ │
│ │                     │ │
│ │                     │ │
│ └─────────────────────┘ │
│                         │
│ [Cancel]     [Save]     │
│                         │
└─────────────────────────┘
```

---

### 12. Login Screen
**Route:** `LoginScreen`

#### Features
- **Branding**
  - App logo
  - App name
  - Tagline/description

- **Login Form**
  - Email input
  - Password input (with show/hide)
  - Remember me checkbox
  - Form validation

- **Actions**
  - Login button
  - Forgot password link
  - Sign up link
  - Social login options (optional)

- **Error Handling**
  - Invalid credentials message
  - Network error message
  - Loading state

#### Layout
```
┌─────────────────────────┐
│                         │
│                         │
│      [Estatemar]        │
│      [Logo]             │
│                         │
│ Find Your Dream Home    │
│                         │
│ Email                   │
│ ┌─────────────────────┐ │
│ │ your@email.com     │ │
│ └─────────────────────┘ │
│                         │
│ Password                │
│ ┌─────────────────────┐ │
│ │ ••••••••••    [👁]  │ │
│ └─────────────────────┘ │
│                         │
│ ☐ Remember me           │
│      Forgot Password?   │
│                         │
│ [Sign In]               │
│                         │
│ Don't have an account?  │
│ Sign Up                 │
│                         │
└─────────────────────────┘
```

---

### 13. Profile Setup Screen
**Route:** `ProfileSetupScreen`
**Shown:** After signup or for new users

#### Features
- **Welcome Message**
  - Greeting
  - Brief instructions

- **Setup Form**
  - Full Name (required)
  - Phone Number (optional)
  - Profile photo (optional)

- **Progress Indicator**
  - Step 1 of 1 (or multi-step)

- **Actions**
  - Complete setup button
  - Skip for now (if optional)

#### Layout
```
┌─────────────────────────┐
│ Complete Your Profile   │
│ ━━━━━━━━━━━━━━━━━━━━━  │ ← Progress
├─────────────────────────┤
│                         │
│ Welcome to Estatemar!   │
│ Let's set up your       │
│ profile                 │
│                         │
│      ┌─────────┐        │
│      │  [+]    │        │
│      └─────────┘        │
│    Add Profile Photo    │
│                         │
│ Full Name *             │
│ ┌─────────────────────┐ │
│ │                     │ │
│ └─────────────────────┘ │
│                         │
│ Phone Number            │
│ ┌─────────────────────┐ │
│ │ +1                  │ │
│ └─────────────────────┘ │
│                         │
│                         │
│ [Skip]    [Complete]    │
│                         │
└─────────────────────────┘
```

---

### 14. News Screen
**Route:** `NewsScreen`

#### Features
- **News Feed**
  - Latest real estate news
  - Article cards with:
    - Featured image
    - Title
    - Summary/excerpt
    - Source
    - Publish date
    - Category badge

- **Categories**
  - Market Trends
  - Investment Tips
  - Local News
  - Regulations
  - Technology

- **Actions**
  - Tap article → Full article view
  - Share article
  - Bookmark article

- **Refresh**
  - Pull to refresh
  - Auto refresh indicator

#### Layout
```
┌─────────────────────────┐
│ News                    │
├─────────────────────────┤
│ [Market] [Tips] [Local] │ ← Categories
├─────────────────────────┤
│                         │
│ ╔═══════════════════╗   │
│ ║   [Article        ║   │
│ ║    Image]         ║   │
│ ║                   ║   │
│ ║ Article Title     ║   │
│ ║ Summary text...   ║   │
│ ║ Source • Oct 3    ║   │
│ ╚═══════════════════╝   │
│                         │
│ ╔═══════════════════╗   │
│ ║   [Article        ║   │
│ ║    Image]         ║   │
│ ╚═══════════════════╝   │
│                         │
└─────────────────────────┘
```

---

### 15. Property 3D Fullscreen
**Route:** `Property3DFullscreen`

#### Features
- **3D Model Viewer**
  - Interactive 3D property model
  - Rotate, zoom, pan gestures
  - Fullscreen view
  - Floor plan switch

- **Controls**
  - Rotation controls
  - Zoom in/out
  - Reset view
  - Floor selector
  - Tour mode

- **Exit**
  - Close button
  - Swipe down to dismiss

#### Layout
```
┌─────────────────────────┐
│ [X]              [⚙]   │
│                         │
│                         │
│                         │
│     ╔═══════════╗       │
│     ║           ║       │
│     ║    3D     ║       │
│     ║   Model   ║       │
│     ║           ║       │
│     ╚═══════════╝       │
│                         │
│                         │
│                         │
│ [↻] [+] [-] [⌂]        │
│                         │
│ Floor: [1] [2] [3]      │
│                         │
└─────────────────────────┘
```

---

## 🔄 User Flows

### 1. Property Discovery Flow
```
HomeScreen
  ├─ Browse properties
  ├─ Apply filters → AdvancedSearchScreen
  ├─ Search text
  ├─ Tap property → PropertyViewScreen
  │   ├─ View details
  │   ├─ Add to favorites
  │   ├─ View similar properties
  │   ├─ View 3D → Property3DFullscreen
  │   ├─ Contact agent
  │   └─ Share
  └─ Sort results
```

### 2. Favorites Management Flow
```
Any Screen with Property
  ├─ Tap heart icon
  ├─ Add to favorites
  └─ View in FavoritesScreen
      ├─ View all favorites
      ├─ Remove from favorites
      └─ Tap property → PropertyViewScreen
```

### 3. Property Management Flow
```
MyPropertiesScreen (Auth Required)
  ├─ View portfolio overview
  ├─ View property list
  ├─ Tap [+] → AddPropertyScreen
  │   ├─ Fill form
  │   ├─ Upload images
  │   ├─ Save property → API
  │   └─ Return to MyPropertiesScreen
  ├─ Tap property
  │   ├─ View details
  │   ├─ Edit → EditPropertyScreen
  │   │   ├─ Update details
  │   │   ├─ Save → API
  │   │   └─ Return
  │   └─ Delete (with confirmation)
  └─ View analytics
```

### 4. Listing Request Flow
```
SellScreen (Auth Required)
  ├─ Select property from dropdown
  ├─ Review property details
  ├─ Enter asking price
  ├─ Submit listing request → API
  ├─ View request status
  └─ Cancel request (if pending)
```

### 5. Authentication Flow
```
App Launch
  ├─ Check auth status
  └─ Access auth-required page
      ├─ Not logged in → LoginScreen
      │   ├─ Enter credentials
      │   ├─ Sign In → API
      │   │   ├─ New user (< 10min) → ProfileSetupScreen
      │   │   │   ├─ Complete profile
      │   │   │   └─ Save → API → MainNavigationScreen
      │   │   └─ Existing user → MainNavigationScreen
      │   └─ Sign Up
      │       ├─ Create account → API
      │       └─ ProfileSetupScreen
      └─ Logged in → Show page content
```

### 6. Profile Management Flow
```
ProfileScreen
  ├─ View profile info
  ├─ View statistics
  ├─ Tap Edit Profile → EditProfileScreen
  │   ├─ Update photo
  │   ├─ Update info
  │   ├─ Save → API
  │   └─ Return
  └─ Tap Logout
      ├─ Confirm logout
      ├─ Logout → API
      └─ Return to HomeScreen
```

### 7. Search & Filter Flow
```
HomeScreen
  ├─ Tap Filter icon → AdvancedSearchScreen
  │   ├─ Select location
  │   ├─ Select property type
  │   ├─ Set price range
  │   ├─ Set bedrooms/bathrooms
  │   ├─ Set area range
  │   ├─ Set listing type
  │   ├─ Apply filters
  │   └─ Return → HomeScreen (filtered)
  ├─ View filter chips
  ├─ Remove filter (tap X on chip)
  └─ Clear all filters
```

---

## 📊 Data Models

### User Model
```dart
class User {
  final String id;
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isProfileComplete;
}
```

### Property Model (Marketplace)
```dart
class Property {
  final String id;
  final String title;
  final String description;
  final double price;
  final String location;
  final String address;
  final int bedrooms;
  final int bathrooms;
  final double area; // sq ft
  final List<String> imageUrls;
  final PropertyType propertyType;
  final ListingType listingType;
  final bool isAvailable;
  final bool isFeatured;
  final List<String> amenities;
  final double? monthlyRent;
  final double? annualAppreciationRate;
  final DateTime createdAt;
}

enum PropertyType {
  house,
  apartment,
  condo,
  townhouse,
  villa,
  studio,
}

enum ListingType {
  sale,
  rent,
}
```

### UserProperty Model (User's Portfolio)
```dart
class UserProperty {
  final String id;
  final String userId;
  final String propertyName;
  final String address;
  final double purchasePrice;
  final double? marketValue;
  final String? description;
  final PropertyType? propertyType;
  final int? bedrooms;
  final int? bathrooms;
  final double? area;
  final DateTime? purchaseDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double? monthlyRent;
  final double? annualAppreciationRate;
  final List<String> imageUrls;
  final bool isForSale;
  final bool isForRent;
  
  // Calculated properties
  final double? profitLoss; // marketValue - purchasePrice
  final double? profitLossPercentage;
  final double? annualRent; // monthlyRent * 12
  final double? rentalYield; // (annualRent / purchasePrice) * 100
  final double? totalReturn;
  final double? totalReturnPercentage;
}
```

### ListingRequest Model
```dart
class ListingRequest {
  final String id;
  final String userId;
  final String propertyId;
  final String propertyName;
  final double askingPrice;
  final ListingRequestStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? notes;
}

enum ListingRequestStatus {
  pending,
  approved,
  rejected,
  cancelled,
}
```

---

## 🔌 API Integration

### Base URL
```
https://api.estatemar.com/api
```

### Authentication
All authenticated endpoints require:
```
Headers:
  Authorization: Bearer {token}
  Cookie: __Secure-better-auth.session_token={cookie}
```

### Key Endpoints

#### Auth Endpoints
- `POST /auth/sign-in/email` - Sign in
- `POST /auth/sign-up/email` - Sign up
- `POST /user/organization/getUserData` - Get user profile
- `POST /user/organization/addPhoneNumber` - Add phone number
- `PUT /auth/update-user` - Update user profile
- `GET /auth/get-session` - Get current session
- `POST /auth/sign-out` - Sign out

#### Property Endpoints (Marketplace)
- `GET /properties` - Get all properties (with filters)
- `GET /properties/{id}` - Get property by ID
- `GET /properties/search?q={query}` - Search properties

#### User Property Endpoints (Portfolio)
- `POST /user/properties` - Create user property
- `GET /user/properties` - Get user properties
- `PUT /user/properties/{id}` - Update user property
- `DELETE /user/properties/{id}` - Delete user property

#### Favorites Endpoints
- `POST /user/favorites` - Add to favorites
- `GET /user/favorites` - Get user favorites
- `DELETE /user/favorites/{id}` - Remove from favorites

---

## 🎯 Key Features & Implementation Notes

### 1. Offline-First Architecture
- Local caching with SharedPreferences
- API sync when online
- Fallback to cached data
- Sync queue for offline changes

### 2. Image Handling
- Multiple image upload support
- Image picker (camera/gallery)
- Image compression before upload
- Cached network images
- Placeholder images

### 3. Real-Time Calculations
- Auto-calculate profit/loss
- ROI percentages
- Rental yield
- Portfolio analytics
- Price formatting with commas

### 4. Form Validation
- Required field validation
- Email format validation
- Phone number formatting
- Price validation (positive numbers)
- Character limits

### 5. Search & Filtering
- Text search with debouncing
- Multiple filter criteria
- Price range slider
- Category filters
- Sort options
- Filter chips (removable)

### 6. Navigation
- Bottom navigation (5 tabs)
- Stack-based navigation
- Modal bottom sheets
- Full-screen overlays
- Back button handling

### 7. State Management
- StatefulWidget for local state
- Service classes for business logic
- SharedPreferences for persistence
- API service for network calls

### 8. Error Handling
- Try-catch blocks
- User-friendly error messages
- Network error handling
- Validation errors
- Loading states

### 9. Performance Optimizations
- ListView.builder for long lists
- Image caching
- Debounced search
- Lazy loading
- Pagination support

### 10. Responsive Design
- Adaptive layouts
- SafeArea for notches
- Keyboard handling
- ScrollControllers
- MediaQuery for screen sizes

---

## 📱 Component Library

### Custom Widgets

#### 1. PropertyCard
- Displays property summary
- Image with favorite button
- Title, price, location
- Features (beds, baths, area)
- Tap to view details

#### 2. AnimatedSearchHeader
- Collapses on scroll
- Search input
- Filter button
- Logo
- Smooth animations

#### 3. CustomBottomNavigationBar
- 5 navigation items
- Icons and labels
- Selected/unselected states
- Ripple effect

#### 4. FilterChip (Custom)
- Shows active filters
- Remove button
- Custom styling
- Rounded corners

#### 5. StatCard
- Shows statistics
- Icon, value, label
- Color-coded
- Compact layout

#### 6. ROIDisplayWidget
- Shows investment metrics
- Charts and graphs
- Profit/loss indicators
- Percentage displays

#### 7. SafeImage
- Network image with error handling
- Loading placeholder
- Error fallback
- Cached images

#### 8. PaymentPlanWidget
- Shows payment breakdown
- Monthly, annually
- Interest calculations
- Visual charts

---

## 🔒 Security Considerations

### 1. Authentication
- Token-based auth
- Cookie-based sessions
- Secure token storage
- Auto-refresh sessions

### 2. Data Protection
- No sensitive data in logs
- Encrypted storage (device level)
- HTTPS only
- Input sanitization

### 3. API Security
- Bearer token authentication
- Request timeouts
- Error message sanitization
- Rate limiting (server-side)

---

## 🚀 Getting Started (Recreating the App)

### 1. Setup Flutter Project
```bash
flutter create estatemar_mobile
cd estatemar_mobile
```

### 2. Add Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  http: ^1.1.0
  shared_preferences: ^2.2.0
  image_picker: ^1.0.0
  cached_network_image: ^3.3.0
  intl: ^0.18.0
```

### 3. Setup Folder Structure
```
lib/
├── main.dart
├── config/
│   └── app_config.dart
├── models/
│   ├── user.dart
│   ├── property.dart
│   ├── user_property.dart
│   └── listing_request.dart
├── screens/
│   ├── auth/
│   ├── home/
│   ├── properties/
│   ├── profile/
│   ├── sell/
│   └── main_navigation_screen.dart
├── services/
│   ├── api_service.dart
│   ├── auth_service.dart
│   ├── property_service.dart
│   └── user_property_service.dart
├── widgets/
│   ├── property_card.dart
│   ├── custom_bottom_navigation_bar.dart
│   └── ...
└── theme/
    ├── app_theme.dart
    └── colors.dart
```

### 4. Implement Theme
- Copy color palette from Design System section
- Implement AppTheme class
- Setup font (Montserrat)
- Create text styles
- Setup component themes

### 5. Implement Navigation
- Create MainNavigationScreen
- Setup bottom navigation
- Implement page switching
- Add auth checks

### 6. Implement Screens
- Start with simple screens (Home, Profile)
- Add authentication screens
- Implement property screens
- Add forms and validation

### 7. Integrate API
- Setup API service
- Implement auth service
- Add network calls
- Handle errors

### 8. Add Features
- Search & filters
- Favorites
- Property management
- Analytics
- Image upload

### 9. Test & Polish
- Test all flows
- Handle edge cases
- Add loading states
- Improve error messages
- Performance optimization

---

## 📝 Notes

### Font Installation
1. Download Montserrat font from Google Fonts
2. Add to `pubspec.yaml`:
```yaml
flutter:
  fonts:
    - family: Montserrat
      fonts:
        - asset: fonts/Montserrat-Regular.ttf
        - asset: fonts/Montserrat-Medium.ttf
          weight: 500
        - asset: fonts/Montserrat-SemiBold.ttf
          weight: 600
        - asset: fonts/Montserrat-Bold.ttf
          weight: 700
```

### Color Usage Guidelines
- Primary Blue: Main actions, links, selected states
- Success Green: Positive metrics, confirmations
- Error Red: Errors, destructive actions
- Warning Orange: Pending states, cautions
- Gray Scale: Text hierarchy, borders, backgrounds

### Spacing Consistency
Use multiples of 8:
- 8px: Tight spacing
- 16px: Standard spacing
- 24px: Medium spacing
- 32px: Large spacing
- 48px+: Section spacing

---

## 🎨 Design Principles

1. **Consistency**: Same patterns throughout
2. **Clarity**: Clear hierarchy and labels
3. **Efficiency**: Minimal taps to complete tasks
4. **Feedback**: Loading states, confirmations
5. **Accessibility**: Good contrast, readable text
6. **Performance**: Fast, responsive UI

---

## 📊 Success Metrics

- User sign-up rate
- Property views per session
- Favorites added
- Properties listed
- Time to complete actions
- App session duration
- User retention rate

---

**Last Updated:** October 3, 2025

This documentation provides a complete blueprint for recreating the Estatemar Mobile App. Follow the design system, implement the screens in order, and ensure all flows work as specified.


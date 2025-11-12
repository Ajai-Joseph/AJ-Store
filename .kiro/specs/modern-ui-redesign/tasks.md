# Implementation Plan

- [x] 1. Set up theme system and design foundation





  - Create a new file `lib/theme/app_theme.dart` with Material Design 3 theme configuration including color schemes, typography, and component themes
  - Create `lib/theme/app_colors.dart` with centralized color definitions for primary, secondary, surface, and status colors
  - Create `lib/theme/app_text_styles.dart` with typography definitions for headings, body text, and special styles
  - Create `lib/constants/app_spacing.dart` with spacing scale constants (xs, sm, md, lg, xl, xxl)
  - Update `lib/main.dart` to use the new theme system
  - _Requirements: 1.2, 1.3, 1.4, 9.1, 9.2, 9.3_

- [x] 2. Create reusable modern UI components





  - Create `lib/widgets/modern_button.dart` with elevated, outlined, and text button variants with gradient support and loading states
  - Create `lib/widgets/modern_card.dart` with consistent styling, elevation, and rounded corners
  - Create `lib/widgets/modern_text_field.dart` with floating labels, prefix/suffix icons, and validation styling
  - Create `lib/widgets/product_card.dart` with modern design including image, title, price, location, and favorite button
  - Create `lib/widgets/loading_shimmer.dart` for skeleton loading states
  - _Requirements: 1.5, 4.2, 4.3, 9.2_

- [x] 3. Redesign splash screen with modern animations





  - Update `lib/splashScreen.dart` with gradient background using theme colors
  - Add fade-in animation for app logo
  - Add slide-up animation for app name
  - Implement smooth transition to next screen
  - _Requirements: 1.1, 10.1, 10.3_
-

- [x] 4. Redesign authentication screens



  - [x] 4.1 Modernize login screen


    - Update `lib/login.dart` with modern layout: gradient top section and white card bottom section
    - Replace form fields with `ModernTextField` components
    - Update buttons to use `ModernButton` with gradient styling
    - Add smooth animations for form elements
    - Improve validation error display with modern styling
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_
  
  - [x] 4.2 Modernize signup screen


    - Update `lib/signUp.dart` with consistent modern layout matching login screen
    - Replace form fields with `ModernTextField` components
    - Update buttons to use `ModernButton` with gradient styling
    - Add form animations and validation feedback
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_
  
  - [x] 4.3 Modernize password reset screen


    - Update `lib/resetPassword.dart` with modern card layout
    - Replace form fields with `ModernTextField` components
    - Update buttons to use `ModernButton` styling
    - Add appropriate animations
    - _Requirements: 2.1, 2.2, 2.3, 2.4, 2.5_

- [x] 5. Redesign home screen and navigation






  - [x] 5.1 Modernize app bar

    - Update `lib/home.dart` app bar with gradient background from theme
    - Update title styling with modern typography
    - Add search and notification icons with proper styling
    - Remove elevation for seamless look
    - _Requirements: 3.3, 9.1_
  

  - [x] 5.2 Modernize bottom navigation

    - Update bottom navigation bar to Material Design 3 style
    - Implement active indicator with pill shape
    - Use outlined icons when inactive, filled when active
    - Add smooth transition animations between tabs
    - _Requirements: 3.1, 3.4, 3.5, 10.1_
  

  - [x] 5.3 Modernize navigation drawer

    - Update drawer header with gradient background and user avatar
    - Redesign menu items with modern icons and styling
    - Add active item highlighting with light primary background
    - Update footer section with better styling
    - Implement smooth open/close animations
    - _Requirements: 3.2, 3.3, 3.4, 9.1_

- [x] 6. Redesign product listing screens






  - [x] 6.1 Modernize Buy screen

    - Update `lib/Screens/buy.dart` with modern layout
    - Add search bar at top with filter icon
    - Add category chips with horizontal scroll
    - Implement grid/list view toggle functionality
    - Replace product display with `ProductCard` components in grid layout
    - Add shimmer loading effect while fetching products
    - Implement pull-to-refresh with modern indicator
    - Add empty state with illustration and message
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.5, 10.3_
  
  - [x] 6.2 Modernize Sell screen


    - Update `lib/Screens/sell.dart` with modern layout matching Buy screen
    - Display seller's products using `ProductCard` components
    - Add floating action button for adding new products
    - Implement shimmer loading and empty states
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 10.3_
  
  - [x] 6.3 Modernize category-wise products screen


    - Update `lib/categoryWiseProducts.dart` with modern grid layout
    - Use `ProductCard` components for product display
    - Add modern app bar with category name
    - Implement loading and empty states
    - _Requirements: 4.1, 4.2, 4.3, 4.4_

- [x] 7. Redesign product detail screens




  - [x] 7.1 Modernize customer product details screen


    - Update `lib/customerProductDetails.dart` with modern layout
    - Implement image carousel at top with page indicators and swipe gestures
    - Add floating back and favorite buttons with modern styling
    - Redesign content section with modern typography and spacing
    - Create modern seller info card with avatar and contact button
    - Update bottom action bar with modern chat and contact buttons
    - Add smooth scrolling with parallax effect for image header
    - Implement hero animation for product image transition
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5, 10.4_
  

  - [x] 7.2 Modernize seller product details screen

    - Update `lib/sellerProductDetails.dart` with modern layout similar to customer view
    - Add edit and delete action buttons with modern styling
    - Display buyer inquiries in modern list format
    - Implement smooth animations for actions
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [x] 8. Redesign product management screens






  - [x] 8.1 Modernize add product screen

    - Update `lib/addProduct.dart` with modern scrollable form layout
    - Create modern image upload section with dashed border and add photo UI
    - Display selected images in horizontal scroll with modern thumbnails and delete icons
    - Replace all form fields with `ModernTextField` components
    - Modernize category selector with dropdown and icons
    - Update additional details dialog with modern styling and animations
    - Update bottom action bar with modern cancel and post buttons
    - Add upload progress indicator with modern loading UI
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5, 10.3_
  

  - [x] 8.2 Modernize edit product screen

    - Update `lib/editProductDetails.dart` with modern form layout
    - Pre-populate fields with existing data using `ModernTextField` components
    - Add modern image management with ability to add/remove images
    - Update save button with modern styling and loading state
    - _Requirements: 5.1, 5.2, 5.3, 5.4_

- [x] 9. Redesign chat interface





  - [x] 9.1 Modernize buy chat screen


    - Update `lib/buyChatScreen.dart` with modern message bubble design
    - Style sent messages with primary color, right-aligned
    - Style received messages with light gray, left-aligned
    - Add timestamps below bubbles with caption styling
    - Modernize input bar with rounded text field and send button
    - Implement smooth scrolling and message animations
    - Update app bar with user info and product thumbnail
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 10.5_
  
  - [x] 9.2 Modernize sell chat screen


    - Update `lib/sellChatScreen.dart` with modern message bubble design matching buy chat
    - Implement consistent styling for sent and received messages
    - Modernize input bar and app bar
    - Add smooth animations for messages
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 10.5_
  
  - [x] 9.3 Modernize chat list screens


    - Update `lib/Pages/buyChats.dart` with modern conversation list items
    - Update `lib/Pages/sellChats.dart` with modern conversation list items
    - Add avatars, last message preview, timestamps, and unread badges
    - Add product thumbnails to each conversation item
    - Implement swipe actions for delete/archive
    - Add empty state for no conversations
    - _Requirements: 7.2, 7.4, 10.5_

- [x] 10. Redesign profile and account screens




  - [x] 10.1 Modernize profile screen


    - Update `lib/profile.dart` with modern layout
    - Create gradient header section with large avatar and user info
    - Design modern info cards for personal information and statistics
    - Add modern action buttons for edit profile and settings
    - Display listed products in grid using `ProductCard` components
    - Implement smooth transitions to edit mode
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_
  
  - [x] 10.2 Modernize update profile screen


    - Update `lib/updateProfile.dart` with modern form layout
    - Replace form fields with `ModernTextField` components
    - Add avatar upload/change functionality with modern UI
    - Update save button with modern styling and loading state
    - Add form validation with modern error display
    - _Requirements: 8.1, 8.2, 8.3, 8.5_

- [x] 11. Modernize category selection screen





  - Update `lib/selectCategory.dart` with modern grid layout
  - Create modern category cards with icons and labels
  - Add hover/press effects on category cards
  - Implement smooth navigation animations
  - Add search functionality for categories
  - _Requirements: 3.3, 9.2, 10.2_

- [x] 12. Implement modern product list pages






  - [x] 12.1 Modernize buy products page

    - Update `lib/Pages/buyProducts.dart` with modern grid layout
    - Use `ProductCard` components for all products
    - Add filtering and sorting options with modern UI
    - Implement shimmer loading effect
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 10.3_
  

  - [x] 12.2 Modernize sell products page

    - Update `lib/Pages/sellProducts.dart` with modern grid layout
    - Use `ProductCard` components for seller's products
    - Add quick action buttons on cards (edit, delete)
    - Implement loading and empty states
    - _Requirements: 4.1, 4.2, 4.3, 4.4, 10.3_

- [x] 13. Add global animations and transitions





  - Create `lib/utils/page_transitions.dart` with custom page route transitions
  - Implement fade + slide transition for all screen navigations
  - Add hero animations for product images between list and detail screens
  - Create `lib/utils/animation_utils.dart` with reusable animation utilities
  - Implement ripple effects on all tappable items
  - Add scale animations for button presses
  - Implement staggered animations for list items
  - _Requirements: 10.1, 10.2, 10.4, 10.5, 9.4_



- [x] 14. Implement error and empty states



  - Create `lib/widgets/error_state_widget.dart` for network and general errors
  - Create `lib/widgets/empty_state_widget.dart` for empty lists and no data scenarios
  - Add retry functionality to error states
  - Implement modern snackbar styling for error messages
  - Add shake animation for form validation errors
  - _Requirements: 1.1, 4.4, 10.1_

- [x] 15. Polish and optimize





  - Review all screens for consistent spacing using app_spacing constants
  - Verify all colors are using theme colors from app_colors
  - Ensure all text uses styles from app_text_styles
  - Test animations for 60fps performance
  - Optimize image loading and caching
  - Add loading states to all async operations
  - Fix any remaining linting issues
  - Test on different screen sizes and orientations
  - _Requirements: 1.4, 9.1, 9.2, 9.3, 9.4, 9.5_

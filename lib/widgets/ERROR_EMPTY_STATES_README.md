# Error and Empty States Documentation

This document provides comprehensive documentation for the error and empty state widgets implemented in the AJ Store app.

## Components Overview

### 1. ErrorStateWidget
A reusable widget for displaying error states with retry functionality.

**Location:** `lib/widgets/error_state_widget.dart`

**Features:**
- Multiple factory constructors for common error types
- Customizable icon, title, and message
- Optional retry button with callback
- Modern, consistent styling

**Usage:**

```dart
// Network error
ErrorStateWidget.network(
  onRetry: () {
    // Retry logic
  },
)

// General error
ErrorStateWidget.general(
  title: 'Custom Title',
  message: 'Custom error message',
  onRetry: () {
    // Retry logic
  },
)

// Not found error
ErrorStateWidget.notFound(
  title: 'Product Not Found',
  message: 'The product you are looking for does not exist.',
)

// Permission error
ErrorStateWidget.permission(
  message: 'You need to be logged in to view this content.',
)
```

### 2. EmptyStateWidget
A reusable widget for displaying empty states in lists and no data scenarios.

**Location:** `lib/widgets/empty_state_widget.dart`

**Features:**
- Multiple factory constructors for common empty states
- Customizable icon, title, and message
- Optional action button with callback
- Support for custom illustrations
- Modern, friendly design

**Usage:**

```dart
// Empty product list
EmptyStateWidget.noProducts(
  onAction: () {
    // Navigate or refresh
  },
  actionButtonText: 'Refresh',
)

// Empty search results
EmptyStateWidget.noSearchResults(
  searchQuery: 'iPhone',
  onAction: () {
    // Clear filters
  },
)

// Empty chat list
EmptyStateWidget.noChats(
  onAction: () {
    // Navigate to products
  },
)

// Empty favorites
EmptyStateWidget.noFavorites(
  onAction: () {
    // Navigate to browse
  },
)

// Empty seller products
EmptyStateWidget.noSellerProducts(
  onAction: () {
    // Navigate to add product
  },
)

// Empty category
EmptyStateWidget.emptyCategory(
  categoryName: 'Electronics',
  onAction: () {
    // Browse all categories
  },
)
```

### 3. ShakeErrorWidget
A wrapper widget that adds shake animation to its child when an error occurs.

**Location:** `lib/widgets/shake_error_widget.dart`

**Features:**
- Automatic shake animation on error state change
- Manual shake trigger via state key
- Customizable duration and offset
- Perfect for form validation errors

**Usage:**

```dart
// Basic usage with automatic shake
ShakeErrorWidget(
  hasError: _hasValidationError,
  child: TextField(
    decoration: InputDecoration(
      labelText: 'Email',
      errorText: _errorText,
    ),
  ),
)

// Manual shake trigger
final _shakeKey = GlobalKey<ShakeErrorWidgetState>();

ShakeErrorWidget(
  key: _shakeKey,
  hasError: false,
  child: YourWidget(),
)

// Trigger shake manually
_shakeKey.currentState?.shake();
```

### 4. SnackbarUtils
A utility class for showing modern styled snackbars.

**Location:** `lib/utils/snackbar_utils.dart`

**Features:**
- Pre-styled snackbars for success, error, warning, and info
- Custom snackbar support
- Loading snackbar with infinite duration
- Consistent modern styling with icons
- Floating behavior with rounded corners

**Usage:**

```dart
// Success message
SnackbarUtils.showSuccess(context, 'Product added successfully!');

// Error message
SnackbarUtils.showError(context, 'Failed to load products');

// Warning message
SnackbarUtils.showWarning(context, 'Please fill all required fields');

// Info message
SnackbarUtils.showInfo(context, 'New features available!');

// Loading indicator
final controller = SnackbarUtils.showLoading(context, 'Uploading...');
// Later, hide it
controller.close();
// or
SnackbarUtils.hide(context);

// Custom snackbar
SnackbarUtils.showCustom(
  context,
  message: 'Custom message',
  backgroundColor: Colors.purple,
  icon: Icons.star,
  duration: Duration(seconds: 5),
);
```

### 5. ErrorHandlingUtils
A utility class for handling errors consistently across the app.

**Location:** `lib/utils/error_handling_utils.dart`

**Features:**
- Firebase error handling
- User-friendly error messages
- Error type detection (network, permission, etc.)
- Consistent error display

**Usage:**

```dart
try {
  // Your Firebase operation
  await firestore.collection('products').get();
} catch (e) {
  ErrorHandlingUtils.handleFirebaseError(context, e);
}

// Check error type
if (ErrorHandlingUtils.isNetworkError(error)) {
  // Handle network error
}

// Get user-friendly message
String message = ErrorHandlingUtils.getUserFriendlyMessage(error);

// Show success
ErrorHandlingUtils.handleSuccess(context, 'Product saved!');

// Show validation error
ErrorHandlingUtils.handleValidationError(context, 'Invalid email format');
```

## Common Patterns

### Pattern 1: Conditional State Rendering

```dart
Widget _buildBody() {
  if (_isLoading) {
    return Center(child: CircularProgressIndicator());
  }

  if (_hasError) {
    return ErrorStateWidget.network(
      onRetry: _loadData,
    );
  }

  if (_data.isEmpty) {
    return EmptyStateWidget.noProducts(
      onAction: _loadData,
    );
  }

  return _buildContent();
}
```

### Pattern 2: Form Validation with Shake

```dart
final _formKey = GlobalKey<FormState>();
bool _hasError = false;

void _submit() {
  setState(() => _hasError = false);
  
  if (!_formKey.currentState!.validate()) {
    setState(() => _hasError = true);
    SnackbarUtils.showError(context, 'Please fix the errors');
    return;
  }
  
  // Process form
}

// In build method
ShakeErrorWidget(
  hasError: _hasError,
  child: Form(
    key: _formKey,
    child: YourFormFields(),
  ),
)
```

### Pattern 3: Async Operation with Loading

```dart
Future<void> _saveProduct() async {
  final loadingController = SnackbarUtils.showLoading(
    context,
    'Saving product...',
  );

  try {
    await productService.save(product);
    loadingController.close();
    SnackbarUtils.showSuccess(context, 'Product saved!');
    Navigator.pop(context);
  } catch (e) {
    loadingController.close();
    ErrorHandlingUtils.handleFirebaseError(context, e);
  }
}
```

## Styling Customization

All widgets use the app's theme system:
- Colors from `lib/theme/app_colors.dart`
- Text styles from `lib/theme/app_text_styles.dart`
- Spacing from `lib/constants/app_spacing.dart`

To customize, modify these theme files rather than individual widgets.

## Requirements Covered

- **Requirement 1.1**: Modern and visually appealing interface with error states
- **Requirement 4.4**: Smooth loading animations and empty states
- **Requirement 10.1**: Smooth animations for UI elements (shake animation)

## Examples

See `lib/widgets/error_empty_states_examples.dart` for complete working examples of all components.

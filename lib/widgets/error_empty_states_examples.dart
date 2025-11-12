import 'package:flutter/material.dart';
import 'error_state_widget.dart';
import 'empty_state_widget.dart';
import 'shake_error_widget.dart';
import '../utils/snackbar_utils.dart';
import '../utils/error_handling_utils.dart';

/// Example file demonstrating how to use error and empty state widgets
/// This file serves as documentation and can be used as reference

// Example 1: Using ErrorStateWidget for network errors
class NetworkErrorExample extends StatelessWidget {
  const NetworkErrorExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Network Error Example')),
      body: ErrorStateWidget.network(
        onRetry: () {
          // Retry logic here
          print('Retrying...');
        },
      ),
    );
  }
}

// Example 2: Using ErrorStateWidget for general errors
class GeneralErrorExample extends StatelessWidget {
  const GeneralErrorExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('General Error Example')),
      body: ErrorStateWidget.general(
        title: 'Oops!',
        message: 'Something unexpected happened.',
        onRetry: () {
          // Retry logic here
        },
      ),
    );
  }
}

// Example 3: Using EmptyStateWidget for empty product list
class EmptyProductListExample extends StatelessWidget {
  const EmptyProductListExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Empty Products Example')),
      body: EmptyStateWidget.noProducts(
        onAction: () {
          // Navigate to add product or refresh
          print('Action triggered');
        },
        actionButtonText: 'Refresh',
      ),
    );
  }
}

// Example 4: Using EmptyStateWidget for empty search results
class EmptySearchExample extends StatelessWidget {
  const EmptySearchExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Empty Search Example')),
      body: EmptyStateWidget.noSearchResults(
        searchQuery: 'iPhone 15',
        onAction: () {
          // Clear filters or search
        },
      ),
    );
  }
}

// Example 5: Using ShakeErrorWidget with form validation
class FormValidationExample extends StatefulWidget {
  const FormValidationExample({super.key});

  @override
  State<FormValidationExample> createState() => _FormValidationExampleState();
}

class _FormValidationExampleState extends State<FormValidationExample> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _hasError = false;

  void _submitForm() {
    setState(() {
      _hasError = false;
    });

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _hasError = true;
      });
      SnackbarUtils.showError(context, 'Please fix the errors in the form');
      return;
    }

    // Form is valid, proceed
    SnackbarUtils.showSuccess(context, 'Form submitted successfully!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Form Validation Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ShakeErrorWidget(
                hasError: _hasError,
                child: TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}

// Example 6: Using SnackbarUtils for different message types
class SnackbarExample extends StatelessWidget {
  const SnackbarExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Snackbar Examples')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                SnackbarUtils.showSuccess(context, 'Operation completed successfully!');
              },
              child: const Text('Show Success'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                SnackbarUtils.showError(context, 'An error occurred!');
              },
              child: const Text('Show Error'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                SnackbarUtils.showWarning(context, 'Please be careful!');
              },
              child: const Text('Show Warning'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                SnackbarUtils.showInfo(context, 'Here is some information.');
              },
              child: const Text('Show Info'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                final controller = SnackbarUtils.showLoading(context, 'Loading...');
                // Simulate async operation
                Future.delayed(const Duration(seconds: 3), () {
                  controller.close();
                  SnackbarUtils.showSuccess(context, 'Done!');
                });
              },
              child: const Text('Show Loading'),
            ),
          ],
        ),
      ),
    );
  }
}

// Example 7: Conditional rendering with error/empty/content states
class ConditionalStateExample extends StatefulWidget {
  const ConditionalStateExample({super.key});

  @override
  State<ConditionalStateExample> createState() => _ConditionalStateExampleState();
}

class _ConditionalStateExampleState extends State<ConditionalStateExample> {
  bool _isLoading = true;
  bool _hasError = false;
  List<String> _products = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      // Simulate different scenarios:
      // 1. Success with data: _products = ['Product 1', 'Product 2'];
      // 2. Success with no data: _products = [];
      // 3. Error: throw Exception('Network error');
      
      setState(() {
        _products = []; // Empty list for demonstration
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
      ErrorHandlingUtils.handleFirebaseError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Conditional State Example')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_hasError) {
      return ErrorStateWidget.network(
        onRetry: _loadProducts,
      );
    }

    if (_products.isEmpty) {
      return EmptyStateWidget.noProducts(
        onAction: _loadProducts,
        actionButtonText: 'Refresh',
      );
    }

    // Show actual content
    return ListView.builder(
      itemCount: _products.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(_products[index]),
        );
      },
    );
  }
}

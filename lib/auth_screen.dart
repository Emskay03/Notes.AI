import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>(); // Added for form validation
  bool _isLoading = false;
  String? _errorMessage;
  bool _isLogin = true; // State to toggle between Login and Sign Up

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _clearError() {
    setState(() {
      _errorMessage = null;
    });
  }

  Future<void> _submitAuthForm() async {
    _clearError(); // Clear previous errors
    if (!_formKey.currentState!.validate()) {
      return; // Stop if form is invalid
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (_isLogin) {
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      } else {
        await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
      }
      // Success, navigation handled by StreamBuilder in main.dart
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = "An unexpected error occurred: $e";
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get current theme data for consistent styling
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView( // Allows scrolling if keyboard is open
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // --- App Logo/Icon ---
              Icon(
                Icons.notes, // Placeholder icon, replace with your app logo later
                size: 100,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 20),
              Text(
                _isLogin ? 'Welcome Back!' : 'Join Notes AI',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onBackground,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // --- Auth Form Card ---
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Take minimum vertical space
                      children: [
                        // --- Email Field ---
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: 'Email Address',
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || !value.contains('@')) {
                              return 'Please enter a valid email address.';
                            }
                            return null;
                          },
                          onChanged: (_) => _clearError(), // Clear error on input change
                        ),
                        const SizedBox(height: 16),

                        // --- Password Field ---
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          obscureText: true,
                          textInputAction: TextInputAction.done,
                          validator: (value) {
                            if (value == null || value.length < 6) {
                              return 'Password must be at least 6 characters long.';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => _submitAuthForm(), // Submit on Enter
                          onChanged: (_) => _clearError(), // Clear error on input change
                        ),
                        const SizedBox(height: 24),

                        // --- Error Message ---
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: theme.colorScheme.error,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        // --- Submit Button ---
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _submitAuthForm,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary,
                              foregroundColor: theme.colorScheme.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    _isLogin ? 'Sign In' : 'Sign Up',
                                    style: const TextStyle(fontSize: 18),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // --- Toggle Button ---
                        TextButton(
                          onPressed: _isLoading
                              ? null
                              : () {
                                  setState(() {
                                    _isLogin = !_isLogin;
                                    _errorMessage = null; // Clear error when toggling
                                    _formKey.currentState?.reset(); // Clear form fields
                                  });
                                },
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.secondary,
                          ),
                          child: Text(
                            _isLogin
                                ? 'Need an account? Sign Up'
                                : 'Already have an account? Sign In',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

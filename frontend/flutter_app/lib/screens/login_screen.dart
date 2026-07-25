import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'profile_setup_screen.dart';
import 'main_shell.dart';

const mint = Color(0xFF7DD3C0);
const mintLight = Color(0xFFE0F5EF);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isRegister = false;
  bool _loading = false;
  String _message = '';

  // Map a Firebase error code to a friendly message
  String _friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your connection.';
      default:
        return e.message ?? 'Something went wrong. Please try again.';
    }
  }

  // Client-side validators, checked before any Firebase call is made
  String? _validateDisplayName(String? value) {
    if (!_isRegister) return null;
    if (value == null || value.trim().isEmpty) {
      return 'Please enter a display name.';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter your email.';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'Please enter a valid email address.';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your password.';
    }
    if (_isRegister && value.length < 6) {
      return 'Password should be at least 6 characters.';
    }
    return null;
  }

  InputDecoration _boxDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

  Widget _tab(String label, bool selected, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: selected ? mint : mintLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: selected ? Colors.white : Colors.black87,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    setState(() => _message = '');

    // Stop here if any field fails validation — no Firebase call is made
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _loading = true);

    try {
      if (_isRegister) {
        await _authService.register(
          _emailController.text,
          _passwordController.text,
        );
        // After registering -> go to the Profile Setup screen
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProfileSetupScreen(
                displayName: _displayNameController.text.trim(),
              ),
            ),
          );
        }
      } else {
        await _authService.signIn(
          _emailController.text,
          _passwordController.text,
        );
        // Go to MainShell (not DashboardScreen directly) so the bottom
        // nav bar is present after a fresh login, same as when the app
        // is reopened with an existing session via AuthGate.
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const MainShell()),
          );
        }
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _message = _friendlyError(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2EEEC),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              children: [
                const SizedBox(height: 40),
                const Text(
                  'SECUROUTINE',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                    color: mint,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Security habit tracker',
                  style: TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    _tab('Login', !_isRegister, () {
                      setState(() => _isRegister = false);
                      _formKey.currentState?.reset();
                    }),
                    const SizedBox(width: 12),
                    _tab('Register', _isRegister, () {
                      setState(() => _isRegister = true);
                      _formKey.currentState?.reset();
                    }),
                  ],
                ),
                const SizedBox(height: 20),
                if (_isRegister) ...[
                  TextFormField(
                    controller: _displayNameController,
                    decoration: _boxDecoration('Display name'),
                    validator: _validateDisplayName,
                  ),
                  const SizedBox(height: 14),
                ],
                TextFormField(
                  controller: _emailController,
                  decoration: _boxDecoration('Email'),
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _passwordController,
                  decoration: _boxDecoration('Password'),
                  obscureText: true,
                  validator: _validatePassword,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mint,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _isRegister ? 'Create Account' : 'Login',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(_message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
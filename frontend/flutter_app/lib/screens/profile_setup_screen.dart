import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'main_shell.dart';

const mint = Color(0xFF7DD3C0);
const bgColor = Color(0xFFF2EEEC);

class ProfileSetupScreen extends StatefulWidget {
  final String displayName;
  const ProfileSetupScreen({super.key, required this.displayName});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _authService = AuthService();

  String? _experience;
  String? _ageGroup;
  String? _preference;
  bool _loading = false;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.displayName;
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
    );
  }


  Future<void> _saveProfile() async {
    setState(() => _message = '');
    // Validate the display name field first
    // Then validate the three dropdowns, which Form.validate() doesn't
    // cover since they're checked manually below
    if (_experience == null || _ageGroup == null || _preference == null) {
      setState(() => _message = 'Please select all of the options.');
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    try {
      await _authService.saveProfile(
        displayName: _nameController.text.trim(),
        experienceLevel: _experience!,
        ageGroup: _ageGroup!,
        securityPreference: _preference!,
      );
      // Go to MainShell (not DashboardScreen directly) so a freshly
      // registered user lands on the tabbed shell with the bottom nav
      // bar, same as returning users via AuthGate or login.
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainShell()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => _message = 'Error: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
@override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: bgColor, body: Center(
      child: SingleChildScrollView(
      padding: const EdgeInsets.all(28),
          child: Form(key: _formKey, child: Column(
            children: [
              const SizedBox(height: 40),
              const Text( 'SECUROUTINE',
                style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold, letterSpacing: 4,color: mint,
                  ),
                ),
              const SizedBox(height: 8),
              const Text('Profile Setup',
                style: TextStyle(color: Colors.black54),
                ),
              const SizedBox(height: 32),
              TextFormField(controller: _nameController,
                  decoration: _boxDecoration('Display name'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a display name.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(initialValue: _experience,
                  decoration: _boxDecoration(''),
                  hint: const Text('Select experience level'),
                  items: const ['Beginner', 'Intermediate', 'Advanced']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _experience = v),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(initialValue: _ageGroup,
                  decoration: _boxDecoration(''),
                  hint: const Text('Select age group'),
                  items: const ['Youth', 'Adult', 'Senior']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setState(() => _ageGroup = v),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(initialValue: _preference,
                  decoration: _boxDecoration(''),
                  hint: const Text('Select main security preference'),
                  items: const [
                    'Password Security',
                    'Two-Factor Authentication',
                    'Account Monitoring',
                    'Phishing Awareness'
                  ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (v) => setState(() => _preference = v),
                ),
                const SizedBox(height: 24),
                SizedBox(width: double.infinity,
                  child: ElevatedButton(onPressed: _loading ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(backgroundColor: mint, foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(height: 20, width: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Save Profile and Generate Tasks',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                if (_message.isNotEmpty)
                  Text(_message, textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.redAccent),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
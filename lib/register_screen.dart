import 'package:flutter/material.dart';

import 'api_service.dart';
import 'habit_data.dart';
import 'login_screen.dart';
import 'storage_service.dart';
import 'ui_helpers.dart';

/// Sign-up screen: username, email and password (required), plus name, age,
/// country (loaded from the REST Countries API) and starting habits.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  double _age = 25; // Default age set to 25
  String _country = 'United States';
  List<String> _countries = [];
  bool _loadingCountries = true;
  bool _countriesFromApi = false;
  bool _isSaving = false;
  String? _errorMessage;
  final List<String> selectedHabits = [];

  @override
  void initState() {
    super.initState();
    _fetchCountries();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Loads the country list from the REST Countries API (external API).
  Future<void> _fetchCountries() async {
    List<String> countries;
    bool fromApi;
    try {
      countries = await ApiService.fetchCountries();
      fromApi = true;
    } catch (e) {
      debugPrint('Country API error: $e');
      countries = List<String>.from(ApiService.fallbackCountries);
      fromApi = false;
      showErrorToast('Could not load countries. Showing a short list.');
    }

    if (!mounted) return;
    setState(() {
      _countries = countries;
      _countriesFromApi = fromApi;
      _country = countries.contains('United States')
          ? 'United States'
          : countries.first;
      _loadingCountries = false;
    });
  }

  Future<void> _register() async {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Error feedback when the user taps Sign Up without valid details.
    if (username.isEmpty || email.isEmpty || password.isEmpty) {
      _showError('Please fill in your username, email and password.');
      return;
    }
    if (!isValidEmail(email)) {
      _showError('Please enter a valid email address.');
      return;
    }
    if (password.length < 6) {
      _showError('Password must be at least 6 characters.');
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    final error = await StorageService.registerUser(
      name: name,
      username: username,
      email: email,
      password: password,
      age: _age.round(),
      country: _country,
      habits: selectedHabits,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (error != null) {
      _showError(error);
      return;
    }

    showSuccessToast('Registration successful! Please log in.');
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen(initialEmail: email)),
      (route) => false,
    );
  }

  void _showError(String message) {
    setState(() => _errorMessage = message);
    showErrorToast(message);
  }

  void _backToLogin() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade700,
        centerTitle: true,
        title: const Text(
          'Sign Up',
          style: TextStyle(
            fontSize: 28,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _backToLogin,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInputField(
                  controller: _usernameController,
                  hint: 'Username',
                  icon: Icons.alternate_email,
                ),
                const SizedBox(height: 12),
                _buildInputField(
                  controller: _emailController,
                  hint: 'Email',
                  icon: Icons.email,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                _buildInputField(
                  controller: _passwordController,
                  hint: 'Password (min. 6 characters)',
                  icon: Icons.lock,
                  obscureText: _obscurePassword,
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.blue.shade700,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 12),
                _buildInputField(
                  controller: _nameController,
                  hint: 'Name (optional)',
                  icon: Icons.person,
                ),
                const SizedBox(height: 16),
                Text('Age: ${_age.round()}',
                    style: const TextStyle(color: Colors.white, fontSize: 18)),
                Slider(
                  value: _age,
                  min: 18,
                  max: 100,
                  divisions: 82,
                  label: _age.round().toString(),
                  activeColor: Colors.white,
                  inactiveColor: Colors.blue.shade300,
                  onChanged: (double value) {
                    setState(() => _age = value);
                  },
                ),
                const SizedBox(height: 8),
                _buildCountryDropdown(),
                if (!_loadingCountries && _countriesFromApi)
                  Padding(
                    padding: const EdgeInsets.only(top: 6, left: 12),
                    child: Text(
                      '${_countries.length} countries loaded from the REST Countries API',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                const SizedBox(height: 16),
                const Text('Select Your Habits',
                    style: TextStyle(color: Colors.white, fontSize: 18)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: availableHabits.map((habit) {
                    final isSelected = selectedHabits.contains(habit);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedHabits.remove(habit);
                          } else {
                            selectedHabits.add(habit);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color:
                              isSelected ? Colors.blue.shade400 : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Colors.white
                                : Colors.blue.shade700,
                          ),
                        ),
                        child: Text(
                          habit,
                          style: TextStyle(
                            fontSize: 13,
                            color: isSelected
                                ? Colors.white
                                : Colors.blue.shade700,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                if (_errorMessage != null) ...[
                  ErrorBanner(message: _errorMessage!),
                  const SizedBox(height: 16),
                ],
                Center(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _register,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue.shade500,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 80, vertical: 15),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white),
                          )
                        : const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account?',
                      style: TextStyle(color: Colors.white70),
                    ),
                    TextButton(
                      onPressed: _backToLogin,
                      child: const Text(
                        'Log in',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffix,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.black87),
        onChanged: (_) {
          if (_errorMessage != null) setState(() => _errorMessage = null);
        },
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blue.shade700),
          suffixIcon: suffix,
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.black45),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }

  Widget _buildCountryDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
      ),
      child: _loadingCountries
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                children: [
                  SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.blue.shade700),
                  ),
                  const SizedBox(width: 12),
                  const Text('Loading countries...',
                      style: TextStyle(color: Colors.black54)),
                ],
              ),
            )
          : DropdownButton<String>(
              value: _country,
              icon: Icon(Icons.arrow_drop_down, color: Colors.blue.shade700),
              isExpanded: true,
              underline: const SizedBox(),
              dropdownColor: Colors.white,
              style: const TextStyle(color: Colors.black87, fontSize: 16),
              menuMaxHeight: 420,
              items: _countries.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (newValue) {
                if (newValue == null) return;
                setState(() => _country = newValue);
              },
            ),
    );
  }
}

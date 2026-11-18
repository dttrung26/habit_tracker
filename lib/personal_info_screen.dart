import 'package:flutter/material.dart';

import 'api_service.dart';
import 'app_state.dart';
import 'storage_service.dart';
import 'ui_helpers.dart';

/// Settings screen ("Personal Info"): lets the user update their name,
/// username, age, country, email and password. Data is loaded from and
/// saved to local storage (SharedPreferences).
class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  double _age = 25;
  String _country = 'United States';
  List<String> _countries = [];
  bool _loading = true;
  Map<String, dynamic> _profile = {};

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final profile = await StorageService.getUserProfile() ?? {};

    List<String> countries;
    try {
      countries = await ApiService.fetchCountries();
    } catch (e) {
      countries = List<String>.from(ApiService.fallbackCountries);
    }

    if (!mounted) return;
    setState(() {
      _profile = profile;
      _nameController.text = profile['name'] as String? ?? '';
      _usernameController.text = profile['username'] as String? ?? '';
      _emailController.text = profile['email'] as String? ?? '';
      final savedAge = (profile['age'] as num?)?.toDouble() ?? 25;
      _age = savedAge.clamp(18, 100).toDouble();

      final savedCountry = profile['country'] as String? ?? 'United States';
      if (!countries.contains(savedCountry)) {
        countries = [...countries, savedCountry]..sort();
      }
      _countries = countries;
      _country = savedCountry;
      _loading = false;
    });
  }

  Future<void> _saveUserData() async {
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim();
    final currentPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;

    if (username.isEmpty) {
      showErrorToast('Username cannot be empty.');
      return;
    }
    if (!isValidEmail(email)) {
      showErrorToast('Please enter a valid email address.');
      return;
    }

    String password = _profile['password'] as String? ?? '';
    final wantsNewPassword =
        currentPassword.isNotEmpty || newPassword.isNotEmpty;
    if (wantsNewPassword) {
      if (currentPassword != password) {
        showErrorToast('Current password is incorrect.');
        return;
      }
      if (newPassword.length < 6) {
        showErrorToast('New password must be at least 6 characters.');
        return;
      }
      password = newPassword;
    }

    final updated = <String, dynamic>{
      ..._profile,
      'name': _nameController.text.trim(),
      'username': username,
      'email': email,
      'password': password,
      'age': _age.round(),
      'country': _country,
    };
    await StorageService.saveUserProfile(updated);
    await StorageService.saveUserAction('Updated personal info');

    if (!mounted) return;
    setState(() {
      _profile = updated;
      _currentPasswordController.clear();
      _newPasswordController.clear();
    });
    showSuccessToast(wantsNewPassword
        ? 'Profile and password updated successfully'
        : 'Profile updated successfully');
  }

  InputDecoration _decoration(String label, IconData icon, {String? hint}) {
    final color = Colors.blue.shade700;
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: color),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: color),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(20),
        borderSide: BorderSide(color: color, width: 2),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue.shade700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: brandBlue,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text('Personal Info'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _sectionTitle('Profile'),
                  TextField(
                    controller: _nameController,
                    decoration: _decoration('Name', Icons.person),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _usernameController,
                    decoration:
                        _decoration('Username', Icons.alternate_email),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Age: ${_age.round()}',
                    textAlign: TextAlign.center,
                    style:
                        TextStyle(fontSize: 20, color: Colors.blue.shade700),
                  ),
                  Slider(
                    value: _age,
                    min: 18,
                    max: 100,
                    divisions: 82,
                    label: _age.round().toString(),
                    onChanged: (value) => setState(() => _age = value),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.blue.shade700),
                    ),
                    child: DropdownButton<String>(
                      value: _country,
                      isExpanded: true,
                      underline: const SizedBox(),
                      menuMaxHeight: 420,
                      items: _countries
                          .map((country) => DropdownMenuItem<String>(
                                value: country,
                                child: Text(country),
                              ))
                          .toList(),
                      onChanged: (newValue) {
                        if (newValue == null) return;
                        setState(() => _country = newValue);
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  _sectionTitle('Account'),
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _decoration('Email', Icons.email),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _currentPasswordController,
                    obscureText: true,
                    decoration: _decoration('Current password', Icons.lock,
                        hint: 'Only needed to change your password'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: _decoration(
                        'New password', Icons.lock_reset,
                        hint: 'Leave blank to keep your password'),
                  ),
                  const SizedBox(height: 28),
                  Center(
                    child: ElevatedButton(
                      onPressed: _saveUserData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 70, vertical: 16),
                      ),
                      child: const Text(
                        'Save Changes',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

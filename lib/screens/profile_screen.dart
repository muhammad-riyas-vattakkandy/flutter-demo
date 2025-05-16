import 'package:flutter/material.dart';
import '../database_helper.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

// screen that manage user profiles
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fnameController = TextEditingController();
  final _lnameController = TextEditingController();
  final _ageController = TextEditingController();
  final _emailController = TextEditingController();

  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  String message = '';
  bool isLoading = true;
  String? _recordObjectId;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final user = await DatabaseHelper.getCurrentUser();
    final record = await DatabaseHelper.getUserProfile();

    if (user != null) {
      _emailController.text = user.emailAddress ?? '';
    }

    if (record != null) {
      _recordObjectId = record.objectId;
      _fnameController.text = record.get<String>('fname') ?? '';
      _lnameController.text = record.get<String>('lname') ?? '';
      final age = record.get<int>('age');
      if (age != null) _ageController.text = age.toString();
    }

    setState(() => isLoading = false);
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r"^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$");
    if (!emailRegex.hasMatch(value.trim())) return 'Invalid email address';
    return null;
  }

  String? _validateAge(String? value) {
    if (value == null || value.trim().isEmpty) return 'Age is required';
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed <= 0 || parsed > 150) {
      return 'Enter a valid age (1–150)';
    }
    return null;
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate() || _recordObjectId == null) return;

    // Update email in _User
    final emailUpdated = await DatabaseHelper.updateCurrentUserEmail(_emailController.text.trim());

    // Update fname, lname, age in userRecords
    final recordUpdated = await DatabaseHelper.updateUserProfile(
      objectId: _recordObjectId!,
      fname: _fnameController.text.trim(),
      lname: _lnameController.text.trim(),
      age: int.tryParse(_ageController.text.trim()),
    );

    setState(() {
      if (emailUpdated && recordUpdated) {
        message = 'Profile updated successfully!';
      } else {
        message = 'Failed to update profile.';
      }
    });
  }

  Future<void> _changePassword() async {
    if (_oldPasswordController.text.isEmpty || _newPasswordController.text.length < 6) {
      setState(() => message = "Old password and new password (6+ chars) are required.");
      return;
    }

    final success = await DatabaseHelper.changePassword(
      oldPassword: _oldPasswordController.text,
      newPassword: _newPasswordController.text,
    );

    setState(() {
      message = success ? 'Password changed successfully!' : 'Failed to change password.';
    });
  }

  Future<void> _deleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Account"),
        content: const Text("Are you sure you want to permanently delete your account?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("Delete")),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await DatabaseHelper.deleteUserAccount();
      if (success && mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      } else {
        setState(() => message = "Failed to delete account.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Manage Profile")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text("Profile Info", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextFormField(
                controller: _fnameController,
                decoration: const InputDecoration(labelText: "First Name"),
                validator: (value) => value!.isEmpty ? 'First name is required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _lnameController,
                decoration: const InputDecoration(labelText: "Last Name"),
                validator: (value) => value!.isEmpty ? 'Last name is required' : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: "Age"),
                keyboardType: TextInputType.number,
                validator: _validateAge,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
                validator: _validateEmail,
              ),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _updateProfile, child: const Text("Update Profile")),

              const Divider(height: 40),

              const Text("Change Password", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              TextField(
                controller: _oldPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Old Password"),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "New Password (min 6 chars)"),
              ),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _changePassword, child: const Text("Change Password")),

              const Divider(height: 40),

              const SizedBox(height: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: _deleteAccount,
                child: const Text("Delete Account"),
              ),

              const SizedBox(height: 20),
              if (message.isNotEmpty)
                Text(message, style: const TextStyle(color: Colors.green)),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../database_helper.dart';
import 'home_screen.dart';

// Screen that allows user to enter additional details such as firstname, lastname, age
class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fnameController = TextEditingController();
  final _lnameController = TextEditingController();
  final _ageController = TextEditingController();

  String message = '';

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await DatabaseHelper.createUserRecord(
      fname: _fnameController.text.trim(),
      lname: _lnameController.text.trim(),
      age: int.tryParse(_ageController.text.trim()) ?? 0,
    );

    if (success && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      setState(() => message = "Failed to save profile details.");
    }
  }

  String? _validateAge(String? value) {
    if (value == null || value.trim().isEmpty) return 'Age is required';
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed <= 0 || parsed > 150) {
      return 'Enter a valid age (1–150)';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Complete Profile")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                "Let’s complete your profile",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _fnameController,
                decoration: const InputDecoration(labelText: "First Name"),
                validator: (value) => value!.isEmpty ? "First name is required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lnameController,
                decoration: const InputDecoration(labelText: "Last Name"),
                validator: (value) => value!.isEmpty ? "Last name is required" : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: "Age"),
                keyboardType: TextInputType.number,
                validator: _validateAge,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _submit, child: const Text("Continue")),
              const SizedBox(height: 10),
              Text(message, style: const TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ),
    );
  }
}

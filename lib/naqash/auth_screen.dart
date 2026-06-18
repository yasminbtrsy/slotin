import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthScreen extends StatefulWidget {
  final String initialMode; //
  final String initialRole; //

  const AuthScreen({
    super.key,
    this.initialMode = 'login',
    this.initialRole = 'user',
  });

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  late String _mode;
  late String _role;

  @override
  void initState() {
    super.initState();
    _mode = widget.initialMode;
    _role = widget.initialRole;
  }

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty ||
        _nameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    if (_passwordController.text.trim().length < 6) {
      _showError('Password must be at least 6 characters');
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      await credential.user?.updateDisplayName(_nameController.text.trim());

      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set({
            'name': _nameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'email': _emailController.text.trim(),
            'role': 'user',
            'createdAt': FieldValue.serverTimestamp(),
          });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created! Please log in.'),
            backgroundColor: Colors.green,
          ),
        );
        setState(() => _mode = 'login');
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'email-already-in-use':
          message = 'An account already exists for this email.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        case 'weak-password':
          message = 'Password is too weak. Use at least 6 characters.';
          break;
        default:
          message = e.message ?? 'Registration failed. Please try again.';
      }
      _showError(message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _login() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _showError('Please fill in all fields');
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .get();

      String userRole = doc['role'] ?? 'user';

      if (mounted) {
        if (_role == 'admin' && userRole == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin-dashboard');
        } else if (_role == 'user' && userRole == 'user') {
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          _showError('You do not have access as $_role.');
          await FirebaseAuth.instance.signOut();
        }
      }
    } on FirebaseAuthException catch (e) {
      String message;
      switch (e.code) {
        case 'user-not-found':
          message = 'No account found for this email.';
          break;
        case 'wrong-password':
          message = 'Incorrect password. Please try again.';
          break;
        case 'invalid-email':
          message = 'Please enter a valid email address.';
          break;
        default:
          message = e.message ?? 'Login failed. Please try again.';
      }
      _showError(message);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // TODO: change background color to white
      backgroundColor: Colors.white,
      appBar: AppBar(
        // TODO: change appbar color to white
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black54),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),

              // TODO: change logo container color to SlotIn green (0xFF1A6B3C)
              // TODO: change icon to Icons.sports_tennis
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blue, // wrong color
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.local_laundry_service, // wrong icon
                  color: Colors.white,
                  size: 32,
                ),
              ),

              const SizedBox(height: 12),

              // ROLE TOGGLE
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    _buildRoleTab('User', 'user'),
                    _buildRoleTab('Admin', 'admin'),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              if (_role == 'user')
                Row(
                  children: [
                    _buildModeTab('Login', 'login'),
                    _buildModeTab('Register', 'register'),
                  ],
                ),

              const SizedBox(height: 24),

              Text(
                _mode == 'register'
                    ? 'Create Account'
                    : _role == 'admin'
                    ? 'Admin Login'
                    : 'Welcome Back',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  // TODO: change heading color to SlotIn green (0xFF1A6B3C)
                  color: Colors.blue,
                ),
              ),

              const SizedBox(height: 24),

              if (_mode == 'register') ...[
                _buildLabel('Name'),
                _buildTextField(
                  controller: _nameController,
                  hint: 'Enter your name',
                ),
                const SizedBox(height: 16),
                _buildLabel('Phone Number'),
                _buildTextField(
                  controller: _phoneController,
                  hint: 'Enter your phone number',
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
              ],

              _buildLabel('Email'),
              _buildTextField(
                controller: _emailController,
                hint: 'Enter your email',
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),

              _buildLabel('Password'),
              _buildTextField(
                controller: _passwordController,
                hint: 'Enter your password',
                obscure: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    size: 20,
                    color: Colors.grey,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),

              const SizedBox(height: 28),

              // TODO: change button color to SlotIn green (0xFF1A6B3C)
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // wrong color
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isLoading
                      ? null
                      : _mode == 'register'
                      ? _register
                      : _login,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _mode == 'register' ? 'Register' : 'Login',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleTab(String label, String value) {
    bool isActive = _role == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          _role = value;
          _mode = 'login';
        }),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            // TODO: change active color to SlotIn green (0xFF1A6B3C)
            color: isActive ? Colors.blue : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black54,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModeTab(String label, String value) {
    bool isActive = _mode == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _mode = value),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                // TODO: change active color to SlotIn green (0xFF1A6B3C)
                color: isActive ? Colors.blue : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              // TODO: change active color to SlotIn green (0xFF1A6B3C)
              color: isActive ? Colors.blue : Colors.black38,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(fontSize: 13, color: Colors.black87),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.black26),
        suffixIcon: suffixIcon,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black12),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black12),
        ),
      ),
    );
  }
}

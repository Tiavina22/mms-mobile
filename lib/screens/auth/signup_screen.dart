import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final PageController _pageController = PageController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _authService = AuthService();

  int _currentStep = 0;
  bool _isProcessing = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _stepError;

  static const _steps = ['Username', 'Email', 'Phone', 'Security'];

  @override
  void dispose() {
    _pageController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool get _isLastStep => _currentStep == _steps.length - 1;

  Future<void> _handleContinue() async {
    setState(() => _stepError = null);
    switch (_currentStep) {
      case 0:
        await _validateUsernameStep();
        break;
      case 1:
        await _validateEmailStep();
        break;
      case 2:
        await _validatePhoneStep();
        break;
      case 3:
        await _submitSignup();
        break;
    }
  }

  Future<void> _validateUsernameStep() async {
    final username = _usernameController.text.trim();
    if (username.length < 3) {
      setState(() => _stepError = 'Username must be at least 3 characters');
      return;
    }
    await _performAvailabilityCheck(
      () => _authService.checkUsernameAvailability(username),
      successMessage: null,
      duplicateMessage: 'This username is already taken',
    );
  }

  Future<void> _validateEmailStep() async {
    final email = _emailController.text.trim();
    if (!email.contains('@') || email.length < 5) {
      setState(() => _stepError = 'Please enter a valid email address');
      return;
    }
    await _performAvailabilityCheck(
      () => _authService.checkEmailAvailability(email),
      duplicateMessage: 'This email is already registered',
    );
  }

  Future<void> _validatePhoneStep() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      setState(() => _stepError = 'Please enter your phone number');
      return;
    }
    await _performAvailabilityCheck(
      () => _authService.checkPhoneAvailability(phone),
      duplicateMessage: 'This phone number is already registered',
    );
  }

  Future<void> _performAvailabilityCheck(
    Future<Map<String, dynamic>> Function() request, {
    String? successMessage,
    required String duplicateMessage,
  }) async {
    setState(() => _isProcessing = true);
    final result = await request();
    setState(() => _isProcessing = false);

    if (!mounted) return;

    if (result['success'] == true && result['available'] == true) {
      _goToStep(_currentStep + 1);
      if (successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(successMessage)),
        );
      }
    } else if (result['success'] == true && result['available'] == false) {
      setState(() => _stepError = duplicateMessage);
    } else {
      setState(() =>
          _stepError = result['error'] as String? ?? 'Unable to verify');
    }
  }

  Future<void> _submitSignup() async {
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (password.length < 6) {
      setState(() => _stepError = 'Password must be at least 6 characters');
      return;
    }
    if (password != confirmPassword) {
      setState(() => _stepError = 'Passwords do not match');
      return;
    }

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signup(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: password,
      phone: _phoneController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      setState(
        () => _stepError =
            authProvider.error ?? 'Signup failed, please try again',
      );
    }
  }

  void _goToStep(int index) {
    if (index < 0 || index >= _steps.length) return;
    setState(() {
      _currentStep = index;
      _stepError = null;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProvider = context.watch<AuthProvider>();
    final isLoading =
        _isProcessing || (_isLastStep && authProvider.isLoading);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    Color(0xFF0A0A0A),
                    Color(0xFF141414),
                    Color(0xFF1F1F1F),
                  ]
                : const [
                    Color(0xFFF6F6F6),
                    Color(0xFFFFFFFF),
                    Color(0xFFF2F2F2),
                  ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
              final paddingTop = keyboardHeight > 0 ? 24.0 : 40.0;

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  24,
                  paddingTop,
                  24,
                  24 + keyboardHeight,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - keyboardHeight,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildHeader(theme, isDark),
                      const SizedBox(height: 32),
                      _buildStepIndicator(isDark),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 320,
                        child: PageView(
                          controller: _pageController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            _buildUsernameStep(isDark),
                            _buildEmailStep(isDark),
                            _buildPhoneStep(isDark),
                            _buildSecurityStep(isDark),
                          ],
                        ),
                      ),
                      if (_stepError != null) ...[
                        const SizedBox(height: 16),
                        _buildErrorBanner(isDark),
                      ],
                      const SizedBox(height: 24),
                      _buildActionButtons(isDark, isLoading),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Already have an account? Log in'),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isDark ? Colors.white.withOpacity(0.08) : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Icon(
            Icons.chat_bubble_outline_rounded,
            size: 34,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          'Create your MMS account',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'We’ll guide you through a few quick steps',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildStepIndicator(bool isDark) {
    return Row(
      children: List.generate(
        _steps.length,
        (index) {
          final isCompleted = index < _currentStep;
          final isActive = index == _currentStep;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: isActive ? 5 : 4,
              decoration: BoxDecoration(
                color: isCompleted || isActive
                    ? (isDark ? Colors.white : Colors.black87)
                    : (isDark ? Colors.white24 : Colors.black12),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUsernameStep(bool isDark) {
    return _StepWrapper(
      title: 'Choose a username',
      subtitle: 'This is how people will find you. It must be unique.',
      child: _buildModernTextField(
        controller: _usernameController,
        hint: 'Username',
        icon: Icons.person_outline_rounded,
        keyboardType: TextInputType.text,
      ),
    );
  }

  Widget _buildEmailStep(bool isDark) {
    return _StepWrapper(
      title: 'Your email address',
      subtitle: 'Use an address you check often to secure your account.',
      child: _buildModernTextField(
        controller: _emailController,
        hint: 'Email address',
        icon: Icons.mail_outline_rounded,
        keyboardType: TextInputType.emailAddress,
      ),
    );
  }

  Widget _buildPhoneStep(bool isDark) {
    return _StepWrapper(
      title: 'Verify your phone',
      subtitle: 'We use your phone to help friends find you and secure access.',
      child: _buildModernTextField(
        controller: _phoneController,
        hint: 'Phone number',
        icon: Icons.phone_outlined,
        keyboardType: TextInputType.phone,
      ),
    );
  }

  Widget _buildSecurityStep(bool isDark) {
    return _StepWrapper(
      title: 'Create a password',
      subtitle: 'Use at least 6 characters to keep your account secure.',
      child: Column(
        children: [
          _buildModernTextField(
            controller: _passwordController,
            hint: 'Password',
            icon: Icons.lock_outline_rounded,
            obscureText: _obscurePassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
          ),
          const SizedBox(height: 16),
          _buildModernTextField(
            controller: _confirmPasswordController,
            hint: 'Confirm password',
            icon: Icons.lock_outline_rounded,
            obscureText: _obscureConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () {
                setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(bool isDark) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isDark ? Colors.redAccent : Colors.red.shade50).withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? Colors.redAccent : Colors.red.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: isDark ? Colors.white : Colors.red),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _stepError ?? '',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.red.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(bool isDark, bool isLoading) {
    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading ? null : () => _goToStep(_currentStep - 1),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Back'),
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: isLoading ? null : _handleContinue,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(_isLastStep ? 'Create Account' : 'Continue'),
          ),
        ),
      ],
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.04)
            : Colors.black.withOpacity(0.03),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? Colors.white12 : Colors.black12,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(
            color: isDark ? Colors.white54 : Colors.black45,
          ),
          prefixIcon: Icon(icon, color: isDark ? Colors.white70 : Colors.black54),
          suffixIcon: suffixIcon,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
      ),
    );
  }
}

class _StepWrapper extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _StepWrapper({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark ? Colors.white54 : Colors.black54,
          ),
        ),
        const SizedBox(height: 24),
        child,
      ],
    );
  }
}


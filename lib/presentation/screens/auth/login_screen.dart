import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/localization/app_locale_provider.dart';
import '../../../data/models/app_user.dart';
import '../../controllers/auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _usePinMode = true; // Default to fast retail cashier PIN keypad
  String _enteredPin = '';
  final TextEditingController _emailController = TextEditingController(text: 'manager@hasad.com');
  final TextEditingController _passwordController = TextEditingController(text: '123456');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onKeypadTap(String digit) {
    if (_enteredPin.length < 4) {
      setState(() {
        _enteredPin += digit;
      });

      if (_enteredPin.length == 4) {
        _submitPin();
      }
    }
  }

  void _onBackspace() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  Future<void> _submitPin() async {
    final success = await ref.read(authNotifierProvider.notifier).loginWithPin(_enteredPin);
    if (!success && mounted) {
      final lang = ref.read(appLocaleProvider).languageCode;
      setState(() {
        _enteredPin = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            lang == 'ar'
                ? 'رمز PIN غير صحيح، يُرجى إعادة المحاولة'
                : 'Incorrect PIN, please try again',
          ),
          backgroundColor: AppColors.spoilageRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(appLocaleProvider);
    final lang = locale.languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Top Toolbar: Language & Theme Switchers
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        onTap: () => ref.read(appLocaleProvider.notifier).toggleLocale(),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.language_rounded, size: 14, color: AppColors.primary),
                              const SizedBox(width: 4),
                              Text(
                                lang == 'ar' ? 'English' : 'عربي',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => ref.read(appThemeModeProvider.notifier).toggleTheme(),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                          ),
                          child: Icon(
                            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                            size: 16,
                            color: isDark ? AppColors.secondary : AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Brand Logo Squircle
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF047857), Color(0xFF10B981), Color(0xFF34D399)],
                        begin: Alignment.bottomRight,
                        end: Alignment.topLeft,
                      ),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.45), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Positioned(
                          top: 3,
                          left: 4,
                          right: 4,
                          child: Container(
                            height: 28,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Colors.white.withValues(alpha: 0.4), Colors.white.withValues(alpha: 0.0)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                            ),
                          ),
                        ),
                        const Icon(Icons.eco_rounded, color: Colors.white, size: 38),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Title
                  Text(
                    lang == 'ar' ? 'حصاد' : 'Hasad',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    lang == 'ar' ? 'تسجيل الدخول لمنظومة المخزون والمبيعات' : 'Sign in to produce inventory system',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Mode Toggle Pill (PIN vs Email)
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.bgLight,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _usePinMode = true),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: _usePinMode ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  lang == 'ar' ? 'رمز PIN السريع' : 'Quick PIN',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: _usePinMode ? Colors.white : (isDark ? Colors.white70 : AppColors.textSecondaryLight),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () => setState(() => _usePinMode = false),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: !_usePinMode ? AppColors.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  lang == 'ar' ? 'البريد الإلكتروني' : 'Email Login',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: !_usePinMode ? Colors.white : (isDark ? Colors.white70 : AppColors.textSecondaryLight),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // FORM CONTENT: PIN KEYPAD or EMAIL INPUTS
                  if (_usePinMode) ...[
                    // PIN Dots indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (index) {
                        final isFilled = index < _enteredPin.length;
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isFilled ? AppColors.primary : (isDark ? Colors.white24 : AppColors.borderLight),
                            border: Border.all(
                              color: isFilled ? AppColors.primary : AppColors.borderLight,
                              width: 2,
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 18),

                    // Numeric Keypad
                    _buildKeypad(isDark),
                  ] else ...[
                    // Email Field
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: lang == 'ar' ? 'البريد الإلكتروني' : 'Email Address',
                        prefixIcon: const Icon(Icons.email_outlined, size: 20),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Password Field
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: lang == 'ar' ? 'كلمة المرور' : 'Password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 20),
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Login Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: authState.isLoading
                            ? null
                            : () => ref.read(authNotifierProvider.notifier).login(
                                  _emailController.text,
                                  _passwordController.text,
                                ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: authState.isLoading
                            ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : Text(
                                lang == 'ar' ? 'تسجيل الدخول' : 'Sign In',
                                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypad(bool isDark) {
    return Column(
      children: [
        for (var row in [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
          ['bio', '0', 'back'],
        ])
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: row.map((key) {
                if (key == 'bio') {
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 64,
                    height: 46,
                    child: IconButton(
                      icon: const Icon(Icons.fingerprint_rounded, size: 26, color: AppColors.primary),
                      onPressed: () {
                        ref.read(authNotifierProvider.notifier).loginAs(UserRole.manager);
                      },
                    ),
                  );
                }
                if (key == 'back') {
                  return SizedBox(
                    width: 64,
                    height: 46,
                    child: IconButton(
                      icon: const Icon(Icons.backspace_outlined, size: 20),
                      onPressed: _onBackspace,
                    ),
                  );
                }
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  width: 64,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: () => _onKeypadTap(key),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                      foregroundColor: isDark ? Colors.white : AppColors.textPrimaryLight,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                      ),
                    ),
                    child: Text(
                      key,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );
  }
}

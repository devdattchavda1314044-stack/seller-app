import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/app_colors.dart';
import '../../core/constants/static_credentials.dart';
import '../../shop/screens/shop_dashboard_screen.dart';
import '../../services/screens/services_dashboard_screen.dart';
import '../../startup/screens/startup_dashboard_screen.dart';
import '../screens/login_screen.dart'; 

enum LoginMethod { phone, email }

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm>
    with SingleTickerProviderStateMixin {
  LoginMethod _selectedMethod = LoginMethod.phone;
  bool _isStep1Valid = false;
  bool _isOnPasswordStep = false;
  bool _obscurePassword = true;

  final TextEditingController _inputController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _inputFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  late final AnimationController _slideController;
  late final Animation<Offset> _step1SlideAnim;
  late final Animation<Offset> _step2SlideAnim;

  @override
  void initState() {
    super.initState();
    _inputController.addListener(_validateStep1);
    
    _inputFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _step1SlideAnim = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));

    _step2SlideAnim = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _inputController.dispose();
    _passwordController.dispose();
    _inputFocusNode.dispose();
    _passwordFocusNode.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _validateStep1() {
    final text = _inputController.text;
    bool valid = false;
    if (_selectedMethod == LoginMethod.phone) {
      valid = RegExp(r'^\d{10}$').hasMatch(text);
    } else {
      valid = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(text);
    }
    if (valid != _isStep1Valid) {
      setState(() => _isStep1Valid = valid);
    }
  }

  void _onContinue() {
    if (!_isStep1Valid) return;
    FocusScope.of(context).unfocus();
    setState(() => _isOnPasswordStep = true);
    _slideController.forward().then((_) {
      if (mounted) {
        _passwordFocusNode.requestFocus();
      }
    });
  }

  void _onBack() {
    FocusScope.of(context).unfocus();
    _slideController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _isOnPasswordStep = false;
          _passwordController.clear();
          _obscurePassword = true;
        });
      }
    });
  }

  void _onLogin() {
    final enteredInput = _inputController.text.trim();
    final enteredPassword = _passwordController.text;
    final isPhone = _selectedMethod == LoginMethod.phone;

    final sellerType = StaticCredentials.validateLogin(
      enteredInput,
      enteredPassword,
      isPhone,
    );

    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();

    if (sellerType != null) {
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Login successfully'),
          backgroundColor: const Color(0xFF22C55E),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          duration: const Duration(seconds: 2),
        ),
      );

      Widget nextScreen;
      switch (sellerType) {
        case SellerType.shop:
          nextScreen = const ShopDashboardScreen();
          break;
        case SellerType.services:
          nextScreen = const ServicesDashboardScreen();
          break;
        case SellerType.startup:
          nextScreen = const StartupDashboardScreen();
          break;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => nextScreen),
      );
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: const Text('Invalid email/phone or password'),
          backgroundColor: const Color(0xFFEF4444),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Input Area
        ClipRect(
          child: AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                // Step 2: Password input
                SlideTransition(
                  position: _step2SlideAnim,
                  child: IgnorePointer(
                    ignoring: !_isOnPasswordStep,
                    child: Opacity(
                      opacity: _isOnPasswordStep ? 1.0 : 0.0,
                      child: _buildPasswordInput(),
                    ),
                  ),
                ),
                // Step 1: Phone/Email input
                SlideTransition(
                  position: _step1SlideAnim,
                  child: IgnorePointer(
                    ignoring: _isOnPasswordStep,
                    child: Opacity(
                      opacity: _isOnPasswordStep ? 0.0 : 1.0,
                      child: _buildStep1Input(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // Buttons Area
        ClipRect(
          child: SizedBox(
            height: 52,
            child: Stack(
              children: [
                // Step 1: Continue button
                SlideTransition(
                  position: _step1SlideAnim,
                  child: _buildContinueButton(),
                ),
                // Step 2: Back + Login buttons
                SlideTransition(
                  position: _step2SlideAnim,
                  child: _buildBackLoginButtons(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStep1Input() {
    final isPhone = _selectedMethod == LoginMethod.phone;
    final isFocused = _inputFocusNode.hasFocus;
    
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Segmented Control (Clean, flat mobile style)
        Container(
          height: 48,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (!isPhone) {
                      setState(() {
                        _selectedMethod = LoginMethod.phone;
                        _inputController.clear();
                        _isStep1Valid = false;
                      });
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isPhone ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: isPhone ? Border.all(color: const Color(0xFFE5E7EB)) : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Phone',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: isPhone ? FontWeight.w600 : FontWeight.w500,
                        color: isPhone ? AppColors.primaryText : AppColors.secondaryText,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (isPhone) {
                      setState(() {
                        _selectedMethod = LoginMethod.email;
                        _inputController.clear();
                        _isStep1Valid = false;
                      });
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    decoration: BoxDecoration(
                      color: !isPhone ? Colors.white : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: !isPhone ? Border.all(color: const Color(0xFFE5E7EB)) : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      'Email',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: !isPhone ? FontWeight.w600 : FontWeight.w500,
                        color: !isPhone ? AppColors.primaryText : AppColors.secondaryText,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Input Field
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isFocused ? AppColors.primary : const Color(0xFFE5E7EB),
              width: 1.0,
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 12.0),
                child: Icon(
                  isPhone ? Icons.phone_outlined : Icons.email_outlined,
                  color: isFocused ? AppColors.primaryText : AppColors.secondaryText,
                  size: 20,
                ),
              ),
              Expanded(
                child: TextField(
                  key: ValueKey(_selectedMethod),
                  controller: _inputController,
                  focusNode: _inputFocusNode,
                  keyboardType: isPhone
                      ? TextInputType.phone
                      : TextInputType.emailAddress,
                  maxLength: isPhone ? 10 : null,
                  inputFormatters: isPhone
                      ? [FilteringTextInputFormatter.digitsOnly]
                      : null,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                  decoration: InputDecoration(
                    hintText: isPhone
                        ? 'Enter mobile number'
                        : 'Enter email address',
                    hintStyle: TextStyle(
                      color: AppColors.secondaryText.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    counterText: '',
                    contentPadding: const EdgeInsets.only(right: 16, bottom: 2),
                    isDense: true,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordInput() {
    final isFocused = _passwordFocusNode.hasFocus;
    
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFocused ? AppColors.primary : const Color(0xFFE5E7EB),
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 12.0),
            child: Icon(
              Icons.lock_outline_rounded,
              color: isFocused ? AppColors.primaryText : AppColors.secondaryText,
              size: 20,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _passwordController,
              focusNode: _passwordFocusNode,
              obscureText: _obscurePassword,
              keyboardType: TextInputType.visiblePassword,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    letterSpacing: _obscurePassword ? 2.0 : null,
                  ),
              decoration: InputDecoration(
                hintText: 'Enter password',
                hintStyle: TextStyle(
                  color: AppColors.secondaryText.withValues(alpha: 0.8),
                  fontSize: 14,
                  letterSpacing: 0,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                counterText: '',
                contentPadding: const EdgeInsets.only(bottom: 2),
                isDense: true,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 4.0),
            child: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.secondaryText,
                size: 20,
              ),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
              splashRadius: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContinueButton() {
    return AnimatedScaleButton(
      onPressed: _isStep1Valid ? _onContinue : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: _isStep1Valid ? AppColors.primary : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          'Continue',
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: _isStep1Valid ? Colors.white : AppColors.secondaryText,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
        ),
      ),
    );
  }

  Widget _buildBackLoginButtons() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: Row(
        children: [
          Expanded(
            child: AnimatedScaleButton(
              onPressed: _onBack,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE5E7EB), width: 1.0),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Back',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: AppColors.primaryText,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: AnimatedScaleButton(
              onPressed: _onLogin,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Login',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

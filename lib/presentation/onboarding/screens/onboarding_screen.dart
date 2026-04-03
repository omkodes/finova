import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../widgets/fade_slide_animation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../auth/bloc/auth_bloc.dart';
import '../../home/screens/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  final _budgetController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _balanceController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 600),
        curve: Curves.fastOutSlowIn,
      );
    } else {
      if (_formKey.currentState?.validate() ?? false) {
        final balance = double.parse(_balanceController.text);
        final budget = double.parse(_budgetController.text);
        
        context.read<AuthBloc>().add(AuthCompleteOnboardingRequested(balance, budget));
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    }
  }

  void _skipOnboarding() {
    // If skipped, they start with 0.0 balance/budget
    context.read<AuthBloc>().add(const AuthCompleteOnboardingRequested(0.0, 0.0));
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Ambient Texture Decor
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.secondary.withOpacity(0.05),
              ),
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 120, sigmaY: 100),
              child: Container(color: Colors.transparent),
            ),
          ),
          
          SafeArea(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(), // Managed by buttons
              onPageChanged: (index) {
                setState(() => _currentPage = index);
              },
              children: [
                _buildSlide1(),
                _buildSlide2(),
                _buildSlide3Setup(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWrapper({required int step, required String titlePart1, required String titlePart2, required String subtitle, required Widget illustration, required String buttonLabel, required VoidCallback onMainTap}) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 448),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLowest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outlineVariant.withOpacity(0.1)),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x0F191C1D),
                      offset: Offset(0, 10),
                      blurRadius: 40,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Progress Steps
                    Padding(
                      padding: const EdgeInsets.only(bottom: 48),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: List.generate(3, (index) {
                              final isCurrent = index == (step - 1);
                              return Container(
                                margin: const EdgeInsets.only(right: 8),
                                height: 6,
                                width: isCurrent ? 48 : 32,
                                decoration: BoxDecoration(
                                  gradient: isCurrent
                                      ? const LinearGradient(colors: [AppColors.primary, AppColors.primaryContainer])
                                      : null,
                                  color: isCurrent ? null : AppColors.primaryContainer.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              );
                            }),
                          ),
                          Text(
                            'STEP $step OF 3',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                              color: AppColors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Illustration Header
                    illustration,

                    // Typography
                    FadeSlideAnimation(
                      delay: const Duration(milliseconds: 200),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: titlePart1,
                            style: const TextStyle(
                              fontFamily: 'Manrope',
                              fontSize: 30,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.0,
                              color: AppColors.onSurface,
                            ),
                            children: [
                              TextSpan(
                                text: titlePart2,
                                style: const TextStyle(color: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    FadeSlideAnimation(
                      delay: const Duration(milliseconds: 300),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            height: 1.5,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // CTA
                    FadeSlideAnimation(
                      delay: const Duration(milliseconds: 400),
                      child: Column(
                        children: [
                          Container(
                            height: 56,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: const LinearGradient(
                                colors: [AppColors.primary, AppColors.primaryContainer],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x333525CD),
                                  offset: Offset(0, 10),
                                  blurRadius: 15,
                                )
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: onMainTap,
                                borderRadius: BorderRadius.circular(12),
                                child: Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        buttonLabel,
                                        style: const TextStyle(
                                          fontFamily: 'Manrope',
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 20),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 48),
              const Text(
                'POWERED BY FINOVA INTELLIGENCE CORE',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                  color: Colors.black38,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlide1() {
    return _buildWrapper(
      step: 1,
      titlePart1: 'Track Every ',
      titlePart2: 'Penny',
      subtitle: 'Easily log your daily expenses and see where your money goes with intuitive categorization.',
      buttonLabel: 'Next Step',
      onMainTap: _nextPage,
      illustration: FadeSlideAnimation(
        child: Container(
          width: 192,
          height: 192,
          margin: const EdgeInsets.only(bottom: 40),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Stack(
            children: [
              const Center(
                child: Icon(Icons.show_chart_rounded, size: 100, color: AppColors.primaryContainer),
              ),
              Positioned(
                bottom: 12,
                right: 12,
                left: 12,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      color: Colors.white.withOpacity(0.7),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryContainer]),
                            ),
                            child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 16),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text('SCANNING...', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1.5, color: AppColors.onSurfaceVariant)),
                              Text('₹42.50 • Groceries', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.onSurface)),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlide2() {
    return _buildWrapper(
      step: 2,
      titlePart1: 'Conquer Your ',
      titlePart2: 'Goals',
      subtitle: 'Set bold financial targets and monitor your progress with beautifully mapped insight charts.',
      buttonLabel: 'Final Step',
      onMainTap: _nextPage,
      illustration: FadeSlideAnimation(
        child: Container(
          width: 192,
          height: 192,
          margin: const EdgeInsets.only(bottom: 40),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLow,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Center(
            child: Icon(Icons.flag_circle_rounded, size: 100, color: AppColors.secondary),
          ),
        ),
      ),
    );
  }

  Widget _buildSlide3Setup() {
    return _buildWrapper(
      step: 3,
      titlePart1: 'Final ',
      titlePart2: 'Setup',
      subtitle: 'Let\'s tailor your dashboard to your lifestyle.',
      buttonLabel: 'Start Tracking',
      onMainTap: _nextPage,
      illustration: FadeSlideAnimation(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildInputBlock(
                  label: 'PREFERRED NAME',
                  controller: _nameController,
                  hint: 'How should we call you?',
                  isNumber: false,
                ),
                const SizedBox(height: 24),
                _buildInputBlock(
                  label: 'MONTHLY BUDGET',
                  controller: _budgetController,
                  hint: '0.00',
                  prefixText: '₹',
                  isNumber: true,
                  subtext: 'You can adjust your goals anytime in settings.',
                ),
                const SizedBox(height: 24),
                _buildInputBlock(
                  label: 'STARTING BALANCE',
                  controller: _balanceController,
                  hint: '0.00',
                  prefixText: '₹',
                  isNumber: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBlock({required String label, required TextEditingController controller, required String hint, String? prefixText, required bool isNumber, String? subtext}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            fontWeight: isNumber ? FontWeight.w600 : FontWeight.normal,
            color: AppColors.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefixText != null ? '$prefixText  ' : null,
            prefixStyle: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
            filled: true,
            fillColor: AppColors.surfaceContainerLow,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.primaryContainer, width: 2)),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) return 'Required field';
            if (isNumber && double.tryParse(value) == null) return 'Must be a number';
            return null;
          },
        ),
        if (subtext != null) ...[
          const SizedBox(height: 8),
          Text(
            subtext,
            style: const TextStyle(fontSize: 10, fontFamily: 'Inter', fontStyle: FontStyle.italic, color: AppColors.onSurfaceVariant),
          ),
        ]
      ],
    );
  }
}

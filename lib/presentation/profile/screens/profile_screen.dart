import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../auth/bloc/auth_bloc.dart';
import '../../theme/theme_cubit.dart';
import '../../../services/biometric_service.dart';
import '../widgets/edit_profile_bottom_sheet.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _biometricLogin = false;
  bool _hasBiometricCapability = false;
  final BiometricService _biometricService = BiometricService();

  @override
  void initState() {
    super.initState();
    _loadBiometricSettings();
  }

  Future<void> _loadBiometricSettings() async {
    final isAvailable = await _biometricService.isBiometricAvailable();
    if (isAvailable) {
      final isEnabled = await _biometricService.isBiometricEnabled();
      if (mounted) {
        setState(() {
          _hasBiometricCapability = true;
          _biometricLogin = isEnabled;
        });
      }
    }
  }

  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      final success = await _biometricService.authenticate(
        reason: 'Authenticate to enable biometric login',
      );
      if (!success) {
        return;
      }
    }
    
    await _biometricService.setBiometricEnabled(value);
    if (mounted) {
      setState(() {
        _biometricLogin = value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // When logout completes, AuthUnauthenticated is emitted.
        // Reset the entire navigation stack so LoginScreen is shown.
        if (state is AuthUnauthenticated) {
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            // Only show spinner while loading, not on unauthenticated
            // (the BlocListener above handles the navigation away).
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final user = state.user;
          final colorScheme = Theme.of(context).colorScheme;

          return Scaffold(
            backgroundColor: colorScheme.background,
            body: Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    // Sticky App Bar
                    SliverAppBar(
                      pinned: true,
                      backgroundColor: colorScheme.background.withOpacity(0.8),
                      elevation: 0,
                      toolbarHeight: 64,
                      leading: IconButton(
                        icon: Icon(Icons.arrow_back, color: colorScheme.primary),
                        onPressed: () => Navigator.pop(context),
                        splashRadius: 24,
                      ),
                      title: Text(
                        'Profile',
                        style: TextStyle(
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      flexibleSpace: ClipRRect(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(color: Colors.transparent),
                        ),
                      ),
                      actions: [
                        Container(
                          margin: const EdgeInsets.only(right: 16),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: colorScheme.primary.withOpacity(0.1),
                          ),
                          child: Center(
                            child: Text(
                              user.name.isNotEmpty
                                  ? user.name[0].toUpperCase()
                                  : 'U',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 24,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          // User Identity Section
                          _buildUserIdentity(context, user),
                          const SizedBox(height: 40),

                          // Bento Grid Settings
                          _buildBentoGrid(context, user),
                          const SizedBox(height: 32),

                          // Logout Section
                          _buildLogoutButton(context),
                          const SizedBox(height: 100),
                        ]),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUserIdentity(BuildContext context, user) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        GestureDetector(
          onTap: () => _openEditProfile(context, user),
          child: Container(
            width: 112,
            height: 112,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 4),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x1A191C1D),
                  blurRadius: 40,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: ClipOval(
              child:
                  user.profileImagePath != null &&
                      user.profileImagePath!.isNotEmpty
                  ? Image.file(
                      File(user.profileImagePath!),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.person,
                        size: 48,
                        color: colorScheme.outline,
                      ),
                    )
                  : Image.network(
                      'https://lh3.googleusercontent.com/aida-public/AB6AXuArMfGM7cUNMmy0YHaP3-2aKk72tMn3fSdjYLwdLQC5yeV8xFYCTie5QBYUck9q84r1Z7qMdIq4DDIKSOZib4SKcTXO6ugNv62Bfxa4jcdz4wljYWB4KTovSPyBepLxxWiHjM2POtuNqIjeGW3RCjbM_YPpXKcXqd_zMV8kOyNOeA7pE620TN0SbRS8bLLA7nrc3FYtIkvZ9Wmq_AXZC_hMCVvJ7wbo4cwMJWyEJATXUrQoxZZeAN5EFWGwpm-OLykDk6pnyQzKtTc',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.person,
                        size: 48,
                        color: colorScheme.outline,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user.name,
          style: TextStyle(
            fontFamily: 'Manrope',
            fontWeight: FontWeight.w800,
            fontSize: 24,
            letterSpacing: -0.5,
            color: colorScheme.onSurface,
          ),
        ),
        Text(
          user.email,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  void _openEditProfile(BuildContext context, user) {
    showEditProfileBottomSheet(
      context,
      name: user.name,
      email: user.email,
      monthlyBudget: user.monthlyBudget,
      profileImagePath: user.profileImagePath,
    );
  }

  Widget _buildBentoGrid(BuildContext context, user) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildBentoSection(
                title: 'Account Settings',
                icon: Icons.account_circle_rounded,
                children: [
                  _buildSettingsTile(
                    'Edit Profile',
                    hasChevron: true,
                    onTap: () => _openEditProfile(context, user),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: _buildBentoSection(
                title: 'Preferences',
                icon: Icons.settings_suggest_rounded,
                children: [
                  BlocBuilder<ThemeCubit, ThemeMode>(
                    builder: (context, mode) {
                      return _buildSwitchTile(
                        'Dark Mode',
                        mode == ThemeMode.dark,
                        (val) => context.read<ThemeCubit>().toggleTheme(val),
                      );
                    },
                  ),
                  _buildSettingsTile('Currency', value: 'INR (₹)'),
                  _buildSettingsTile('Language', value: 'English'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _buildBentoSection(
                title: 'Security',
                icon: Icons.verified_user_rounded,
                children: [
                  if (_hasBiometricCapability)
                    _buildSwitchTile(
                      'Biometric Login',
                      _biometricLogin,
                      _toggleBiometric,
                    )
                  else
                    _buildSettingsTile(
                      'Biometric Login',
                      value: 'Not Available',
                    ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildBentoSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: colorScheme.brightness == Brightness.light
                ? const Color(0x08191C1D)
                : Colors.black26,
            blurRadius: 40,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colorScheme.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Manrope',
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSettingsTile(
    String title, {
    String? value,
    bool hasChevron = false,
    bool hasExternal = false,
    VoidCallback? onTap,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurface,
                ),
              ),
              if (value != null)
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              if (hasChevron)
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: colorScheme.outline,
                ),
              if (hasExternal)
                Icon(
                  Icons.open_in_new_rounded,
                  size: 18,
                  color: colorScheme.outline,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            ),
            Transform.scale(
              scale: 0.8,
              child: Switch(
                value: value,
                onChanged: onChanged,
                activeColor: Colors.white,
                activeTrackColor: colorScheme.primary,
                inactiveThumbColor: colorScheme.background,
                inactiveTrackColor: colorScheme.surfaceContainerHighest,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () {
        context.read<AuthBloc>().add(AuthLogoutRequested());
      },
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: BoxDecoration(
          color: colorScheme.error.withOpacity(0.05),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colorScheme.error.withOpacity(0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: colorScheme.error, size: 20),
            const SizedBox(width: 12),
            Text(
              'Logout',
              style: TextStyle(
                fontFamily: 'Manrope',
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';

import 'package:finova/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../auth/bloc/auth_bloc.dart';

class EditProfileBottomSheet extends StatefulWidget {
  final String name;
  final String email;
  final double monthlyBudget;
  final String? profileImagePath;

  const EditProfileBottomSheet({
    super.key,
    required this.name,
    required this.email,
    required this.monthlyBudget,
    this.profileImagePath,
  });

  @override
  State<EditProfileBottomSheet> createState() => _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends State<EditProfileBottomSheet> {
  late TextEditingController _nameController;
  late TextEditingController _budgetController;
  String? _selectedImagePath;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _budgetController = TextEditingController(
      text: widget.monthlyBudget.toStringAsFixed(0),
    );
    _selectedImagePath = widget.profileImagePath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _selectedImagePath = image.path;
        });
      }
    } catch (e) {
      debugPrint('Image Picking Error: $e');
      if (mounted) {
        final colorScheme = Theme.of(context).colorScheme;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to pick image: $e'),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    }
  }

  void _showDeleteConfirmation() {
    final colorScheme = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text(
          'This action is permanent and will delete all your transactions and profile data. Proceed?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close bottom sheet
              context.read<AuthBloc>().add(
                AuthDeleteAccountRequested(widget.email),
              );
            },
            child: Text(
              'Delete',
              style: TextStyle(
                color: colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.brightness == Brightness.light
            ? AppColors.surfaceContainerLowest
            : AppColors.darkSurfaceContainerLowest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          const SizedBox(height: 16),
          Container(
            width: 48,
            height: 6,
            decoration: BoxDecoration(
              color: colorScheme.outlineVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.close, color: colorScheme.onSurface),
                      onPressed: () => Navigator.pop(context),
                      splashRadius: 24,
                    ),
                    Text(
                      'Edit Profile',
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      context.read<AuthBloc>().add(
                        AuthUpdateProfileRequested(
                          name: _nameController.text,
                          monthlyBudget: double.tryParse(
                            _budgetController.text,
                          ),
                          profileImagePath: _selectedImagePath,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: Text(
                    'Save',
                    style: TextStyle(
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(32, 8, 32, 48),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Avatar Selection
                    Center(
                      child: Stack(
                        children: [
                          Container(
                            width: 112,
                            height: 112,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colorScheme.surfaceVariant,
                                width: 4,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      colorScheme.brightness == Brightness.light
                                      ? const Color(0x0A000000)
                                      : Colors.black26,
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipOval(
                              child:
                                  _selectedImagePath != null &&
                                      _selectedImagePath!.isNotEmpty
                                  ? Image.file(
                                      File(_selectedImagePath!),
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      'https://lh3.googleusercontent.com/aida-public/AB6AXuArMfGM7cUNMmy0YHaP3-2aKk72tMn3fSdjYLwdLQC5yeV8xFYCTie5QBYUck9q84r1Z7qMdIq4DDIKSOZib4SKcTXO6ugNv62Bfxa4jcdz4wljYWB4KTovSPyBepLxxWiHjM2POtuNqIjeGW3RCjbM_YPpXKcXqd_zMV8kOyNOeA7pE620TN0SbRS8bLLA7nrc3FYtIkvZ9Wmq_AXZC_hMCVvJ7wbo4cwMJWyEJATXUrQoxZZeAN5EFWGwpm-OLykDk6pnyQzKtTc',
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Icon(
                                        Icons.person,
                                        size: 64,
                                        color: colorScheme.outline,
                                      ),
                                    ),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: colorScheme.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.edit_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _nameController.text.isEmpty
                          ? 'New User'
                          : _nameController.text,
                      style: TextStyle(
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Personal Account',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Form Fields
                    _buildInputField(
                      label: 'Full Name',
                      controller: _nameController,
                      icon: Icons.person_outline_rounded,
                      hint: 'Enter your full name',
                    ),
                    const SizedBox(height: 24),
                    _buildInputField(
                      label: 'Email Address',
                      controller: TextEditingController(text: widget.email),
                      icon: Icons.mail_outline_rounded,
                      readOnly: true,
                    ),
                    const SizedBox(height: 24),
                    _buildInputField(
                      label: 'Monthly Budget (₹)',
                      controller: _budgetController,
                      icon: Icons.payments_outlined,
                      hint: '0.00',
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 32),

                    // Deactivate Button
                    TextButton(
                      onPressed: _showDeleteConfirmation,
                      child: Text(
                        'Delete Finova Account',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    String? hint,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            fontSize: 16,
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: Icon(icon, color: colorScheme.outline, size: 20),
            filled: true,
            fillColor: colorScheme.surfaceVariant.withOpacity(0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }
}

void showEditProfileBottomSheet(
  BuildContext context, {
  required String name,
  required String email,
  required double monthlyBudget,
  String? profileImagePath,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => EditProfileBottomSheet(
      name: name,
      email: email,
      monthlyBudget: monthlyBudget,
      profileImagePath: profileImagePath,
    ),
  );
}

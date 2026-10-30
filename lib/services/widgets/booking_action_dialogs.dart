import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../models/service_booking_model.dart';

/// Prompts that stand between a tap and a stage change.
///
/// Two of the six transitions cannot be a bare swipe: assigning needs a name,
/// and rejecting needs a reason the customer can be shown. The rest advance
/// straight away, because asking a seller to confirm "on the way" twice is how
/// they stop updating the app at all.
class BookingActionDialogs {
  const BookingActionDialogs._();

  /// Asks who is doing the job. Returns the name, or null if dismissed.
  static Future<String?> askProfessional(
    BuildContext context, {
    required SellerBooking booking,
    List<String> suggestions = defaultProfessionals,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => _ProfessionalDialog(
        booking: booking,
        suggestions: suggestions,
      ),
    );
  }

  /// Confirms a rejection and collects a reason.
  ///
  /// Returns the reason on confirm — possibly an empty string if the seller
  /// gave none — or null if they backed out. Null and empty mean different
  /// things here, so callers must check for null rather than for emptiness.
  static Future<String?> confirmReject(
    BuildContext context, {
    required SellerBooking booking,
  }) {
    return showDialog<String>(
      context: context,
      builder: (context) => _RejectDialog(booking: booking),
    );
  }

  /// Names the app offers when assigning. Stands in for the staff list a real
  /// provider account would carry.
  static const List<String> defaultProfessionals = [
    'Ramesh B.',
    'Jignesh P.',
    'Kavita M.',
    'Suresh T.',
    'Alpesh V.',
  ];
}

const List<String> defaultProfessionals =
    BookingActionDialogs.defaultProfessionals;

class _ProfessionalDialog extends StatefulWidget {
  final SellerBooking booking;
  final List<String> suggestions;

  const _ProfessionalDialog({required this.booking, required this.suggestions});

  @override
  State<_ProfessionalDialog> createState() => _ProfessionalDialogState();
}

class _ProfessionalDialogState extends State<_ProfessionalDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _canSubmit => _controller.text.trim().isNotEmpty;

  void _submit() {
    if (!_canSubmit) return;
    Navigator.of(context).pop(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      title: const Text(
        'Assign a professional',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16.5,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryText,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.booking.serviceTitle} • ${widget.booking.slot.label}',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12.5,
              color: AppColors.secondaryText,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => setState(() {}),
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: 'Name of the person attending',
              hintStyle: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13.5,
                color: AppTokens.mutedText,
              ),
              filled: true,
              fillColor: AppTokens.fieldFill,
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppTokens.borderField),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.primaryText,
            ),
            cursorColor: AppColors.primary,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: widget.suggestions.map((name) {
              final bool isSelected = _controller.text.trim() == name;
              return GestureDetector(
                onTap: () => setState(() {
                  _controller.text = name;
                  _controller.selection = TextSelection.collapsed(
                    offset: name.length,
                  );
                }),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTokens.actionSoft
                        : AppTokens.fieldFill,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppTokens.borderField,
                      width: isSelected ? 1 : 0.5,
                    ),
                  ),
                  child: Text(
                    name,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.secondaryText,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: AppColors.secondaryText,
            ),
          ),
        ),
        TextButton(
          onPressed: _canSubmit ? _submit : null,
          child: Text(
            'Assign',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: _canSubmit
                  ? AppTokens.success
                  : AppTokens.faintText,
            ),
          ),
        ),
      ],
    );
  }
}

class _RejectDialog extends StatefulWidget {
  final SellerBooking booking;

  const _RejectDialog({required this.booking});

  @override
  State<_RejectDialog> createState() => _RejectDialogState();
}

class _RejectDialogState extends State<_RejectDialog> {
  final TextEditingController _controller = TextEditingController();

  /// Reasons a provider actually gives, so the common case is one tap.
  static const List<String> _reasons = [
    'Fully booked for that window',
    'Outside my service area',
    'Job needs equipment I do not have',
    'Customer unreachable',
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      title: const Text(
        'Reject this booking?',
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 16.5,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryText,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${widget.booking.customerName} will be told the booking is '
            'cancelled. This cannot be undone.',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12.5,
              color: AppColors.secondaryText,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _reasons.map((reason) {
              final bool isSelected = _controller.text == reason;
              return GestureDetector(
                onTap: () => setState(() => _controller.text = reason),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTokens.dangerSoft
                        : AppTokens.fieldFill,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: isSelected
                          ? AppTokens.danger
                          : AppTokens.borderField,
                      width: isSelected ? 1 : 0.5,
                    ),
                  ),
                  child: Text(
                    reason,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? AppTokens.danger
                          : AppColors.secondaryText,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.fromLTRB(12, 14, 12, 10),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Keep it',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: AppColors.secondaryText,
            ),
          ),
        ),
        TextButton(
          // Empty is allowed: a reason helps the customer, it is not a gate.
          onPressed: () =>
              Navigator.of(context).pop(_controller.text.trim()),
          child: const Text(
            'Reject booking',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppTokens.danger,
            ),
          ),
        ),
      ],
    );
  }
}

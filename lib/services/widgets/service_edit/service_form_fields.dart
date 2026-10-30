import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';
import '../../models/service_booking_model.dart';
import '../../models/service_listing_model.dart';

/// Section heading with an optional line of guidance underneath.
class ServiceFormLabel extends StatelessWidget {
  final String label;
  final String? hint;
  final bool isRequired;

  const ServiceFormLabel({
    super.key,
    required this.label,
    this.hint,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryText,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: AppTokens.danger,
                ),
              ),
          ],
        ),
        if (hint != null) ...[
          const SizedBox(height: 3),
          Text(
            hint!,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.secondaryText,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}

/// The form's one text field style.
class ServiceTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final int maxLines;
  final bool isNumeric;
  final String? prefixText;
  final TextCapitalization textCapitalization;

  const ServiceTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.maxLines = 1,
    this.isNumeric = false,
    this.prefixText,
    this.textCapitalization = TextCapitalization.sentences,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType:
          isNumeric ? const TextInputType.numberWithOptions(decimal: true) : null,
      inputFormatters: isNumeric
          ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))]
          : null,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 13.5,
          fontWeight: FontWeight.w400,
          color: AppTokens.mutedText,
        ),
        prefixText: prefixText,
        prefixStyle: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.secondaryText,
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTokens.borderField),
        ),
      ),
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.primaryText,
        height: 1.4,
      ),
      cursorColor: AppColors.primary,
    );
  }
}

/// Category and sub-category in one control.
///
/// Changing the category clears the sub-category rather than carrying it
/// across: "Bridal" under Plumbing is not a listing anyone meant to publish.
class ServiceCategorySelector extends StatelessWidget {
  final String category;
  final String subCategory;
  final void Function(String category, String subCategory) onChanged;

  const ServiceCategorySelector({
    super.key,
    required this.category,
    required this.subCategory,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final ServiceCategoryOption selected = categoryByName(category);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ServiceFormLabel(
          label: 'Department',
          hint: 'Where customers will find this service.',
          isRequired: true,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: serviceCategories.map((option) {
            final bool isSelected = option.name == category;
            return GestureDetector(
              onTap: () => onChanged(
                option.name,
                option.subCategories.isEmpty ? '' : option.subCategories.first,
              ),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                decoration: BoxDecoration(
                  // One selection colour for every department, as Shop's
                  // category sheets do. Tinting each chip with its own pastel
                  // made the picker read as eight unrelated controls.
                  color: isSelected ? AppTokens.actionSoft : AppTokens.fieldFill,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppTokens.borderField,
                    width: isSelected ? 1.2 : 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      option.icon,
                      size: 15,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.secondaryText,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      option.name,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12.5,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        if (selected.subCategories.isNotEmpty) ...[
          const SizedBox(height: 18),
          const ServiceFormLabel(label: 'Sub-category', isRequired: true),
          const SizedBox(height: 10),
          Wrap(
            spacing: 7,
            runSpacing: 7,
            children: selected.subCategories.map((sub) {
              final bool isSelected = sub == subCategory;
              return GestureDetector(
                onTap: () => onChanged(category, sub),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTokens.actionSoft
                        : AppTokens.fieldFill,
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppTokens.borderField,
                      width: isSelected ? 1.2 : 0.5,
                    ),
                  ),
                  child: Text(
                    sub,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12.5,
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
      ],
    );
  }
}

/// How soon the seller can attend.
class ServiceAvailabilitySelector extends StatelessWidget {
  final ServiceAvailability value;
  final ValueChanged<ServiceAvailability> onChanged;

  const ServiceAvailabilitySelector({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ServiceFormLabel(
          label: 'Earliest availability',
          hint: 'The promise customers see on the card. "Available now" puts '
              'this service in the emergency rail, so only pick it if someone '
              'can genuinely be dispatched within the hour.',
          isRequired: true,
        ),
        const SizedBox(height: 10),
        ...ServiceAvailability.values.map((option) {
          final bool isSelected = option == value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 7),
            child: GestureDetector(
              onTap: () => onChanged(option),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTokens.actionSoft
                      : AppTokens.fieldFill,
                  borderRadius: BorderRadius.circular(11),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppTokens.borderField,
                    width: isSelected ? 1.2 : 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isSelected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      size: 18,
                      color: isSelected
                          ? AppColors.primary
                          : AppTokens.faintText,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            option.label,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13.5,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.primaryText,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            option.detail,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 11.5,
                              color: AppColors.secondaryText,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

/// Which two-hour windows this service can be booked into.
class ServiceSlotSelector extends StatelessWidget {
  final List<BookingSlotRef> selected;
  final ValueChanged<List<BookingSlotRef>> onChanged;

  const ServiceSlotSelector({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ServiceFormLabel(
          label: 'Bookable windows',
          hint: selected.isEmpty
              ? 'Pick at least one window, or customers cannot book this at all.'
              : 'Customers choose one of these when they book.',
          isRequired: true,
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 7,
          runSpacing: 7,
          children: BookingSlot.all.map((slot) {
            final bool isSelected = selected.contains(slot.id);
            return GestureDetector(
              onTap: () {
                final next = List<BookingSlotRef>.of(selected);
                isSelected ? next.remove(slot.id) : next.add(slot.id);
                onChanged(next);
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTokens.actionSoft
                      : AppTokens.fieldFill,
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(
                    color: isSelected
                        ? AppColors.primary
                        : AppTokens.borderField,
                    width: isSelected ? 1.2 : 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isSelected
                          ? Icons.check_circle_rounded
                          : Icons.circle_outlined,
                      size: 14,
                      color: isSelected
                          ? AppColors.primary
                          : AppTokens.faintText,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      slot.label,
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
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

/// An editable list of short lines — inclusions, exclusions, requirements.
///
/// A plain multi-line text box would be less code, but these three lists are
/// rendered as bulleted panels on the customer's detail screen, so they have
/// to be collected as separate items rather than one blob split on newlines.
class ServiceTermsEditor extends StatefulWidget {
  final String label;
  final String hint;
  final String addHint;
  final IconData bulletIcon;
  final Color bulletColor;
  final List<String> items;
  final ValueChanged<List<String>> onChanged;

  const ServiceTermsEditor({
    super.key,
    required this.label,
    required this.hint,
    required this.addHint,
    required this.bulletIcon,
    required this.bulletColor,
    required this.items,
    required this.onChanged,
  });

  @override
  State<ServiceTermsEditor> createState() => _ServiceTermsEditorState();
}

class _ServiceTermsEditorState extends State<ServiceTermsEditor> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    final String text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onChanged([...widget.items, text]);
    _controller.clear();
  }

  void _removeAt(int index) {
    final next = List<String>.of(widget.items)..removeAt(index);
    widget.onChanged(next);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ServiceFormLabel(label: widget.label, hint: widget.hint),
        const SizedBox(height: 10),

        ...widget.items.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Container(
              padding: const EdgeInsets.fromLTRB(11, 9, 5, 9),
              decoration: BoxDecoration(
                color: AppTokens.fieldFill,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppTokens.borderField, width: 0.5),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(
                      widget.bulletIcon,
                      size: 14,
                      color: widget.bulletColor,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: AppColors.primaryText,
                        height: 1.4,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      splashRadius: 16,
                      onPressed: () => _removeAt(entry.key),
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 15,
                        color: AppTokens.mutedText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }),

        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _add(),
                decoration: InputDecoration(
                  hintText: widget.addHint,
                  hintStyle: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    color: AppTokens.mutedText,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 12,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppTokens.borderField),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.primary),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppTokens.borderField),
                  ),
                ),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primaryText,
                ),
                cursorColor: AppColors.primary,
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _add,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTokens.actionSoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.add_rounded,
                  size: 21,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// A labelled switch row.
class ServiceToggleRow extends StatelessWidget {
  final String label;
  final String hint;
  final bool value;
  final ValueChanged<bool> onChanged;
  final Color activeColor;

  const ServiceToggleRow({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
    this.activeColor = AppTokens.success,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTokens.fieldFill,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTokens.borderField, width: 0.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryText,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hint,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11.5,
                    color: AppColors.secondaryText,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeTrackColor: activeColor,
          ),
        ],
      ),
    );
  }
}

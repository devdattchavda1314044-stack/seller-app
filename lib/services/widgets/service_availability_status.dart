import 'package:flutter/material.dart';

import '../../core/theme/app_tokens.dart';

/// Booking-intake control with toggle.
///
/// The services counterpart to `ShopStoreStatus`. A shop closes; a
/// tradesperson stops taking new work while still finishing today's jobs — so
/// off pauses *new requests* and says so, rather than claiming the business is
/// shut.
class ServiceAvailabilityStatus extends StatelessWidget {
  final bool isAccepting;
  final ValueChanged<bool> onChanged;

  /// Jobs still open. Shown when intake is off so the seller can see that
  /// pausing has not abandoned work already committed to.
  final int activeJobs;

  const ServiceAvailabilityStatus({
    super.key,
    required this.isAccepting,
    required this.onChanged,
    this.activeJobs = 0,
  });

  @override
  Widget build(BuildContext context) {
    final String subtitle;
    if (isAccepting) {
      subtitle = 'Accepting new bookings';
    } else if (activeJobs > 0) {
      subtitle =
          'New requests paused • $activeJobs job${activeJobs == 1 ? '' : 's'} still open';
    } else {
      subtitle = 'New requests paused';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
        decoration: BoxDecoration(
          color: isAccepting ? AppTokens.openFill : AppTokens.destructiveSoft,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                isAccepting ? AppTokens.openBorder : AppTokens.closedBorder,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            // Status dot
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: isAccepting
                    ? AppTokens.success
                    : AppTokens.danger,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            // Status text — two lines
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isAccepting ? 'Available for Work' : 'Not Taking Work',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isAccepting
                          ? AppTokens.openText
                          : AppTokens.closedText,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: isAccepting
                          ? AppTokens.openText.withValues(alpha: 0.7)
                          : AppTokens.closedText.withValues(alpha: 0.7),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            _CustomToggle(value: isAccepting, onChanged: onChanged),
          ],
        ),
      ),
    );
  }
}

class _CustomToggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const _CustomToggle({required this.value, required this.onChanged});

  @override
  State<_CustomToggle> createState() => _CustomToggleState();
}

class _CustomToggleState extends State<_CustomToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Alignment> _alignmentAnimation;
  late Animation<Color?> _trackColorAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );

    _alignmentAnimation = AlignmentTween(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _trackColorAnimation = ColorTween(
      begin: AppTokens.faintText,
      end: AppTokens.success,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.value) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(_CustomToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      widget.value ? _controller.forward() : _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onChanged(!widget.value),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Container(
            width: 48,
            height: 28,
            decoration: BoxDecoration(
              color: _trackColorAnimation.value,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(3),
            child: Align(
              alignment: _alignmentAnimation.value,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

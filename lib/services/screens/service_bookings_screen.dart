import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../models/service_booking_model.dart';
import '../models/service_booking_store.dart';
import '../models/service_seller_profile_model.dart';
import '../utils/booking_actions.dart';
import '../widgets/service_booking_list_item.dart';

/// The whole booking pipeline, bucketed.
///
/// The dashboard shows today; this shows the funnel. Buckets rather than one
/// long list because the seller's question is never "all my bookings" — it is
/// "what needs a decision", "what is running right now", "what is coming".
class ServiceBookingsScreen extends StatefulWidget {
  const ServiceBookingsScreen({super.key});

  @override
  State<ServiceBookingsScreen> createState() => _ServiceBookingsScreenState();
}

class _ServiceBookingsScreenState extends State<ServiceBookingsScreen> {
  final ServiceBookingStore _store = ServiceBookingStore();

  BookingBucket _bucket = BookingBucket.requests;

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreChanged);
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    super.dispose();
  }

  void _onStoreChanged() {
    if (mounted) setState(() {});
  }

  void _showPausedSnackBar() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Availability is off. Turn it on to manage bookings.',
          style: TextStyle(fontFamily: 'Poppins', fontSize: 13),
        ),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ServiceSellerProfile>(
      valueListenable: ServiceSellerProfileProvider().profileNotifier,
      builder: (context, profile, _) {
        final List<SellerBooking> bookings = _store.inBucket(_bucket);

        return Scaffold(
          backgroundColor: AppTokens.pageBackground,
          body: SafeArea(
            bottom: false,
            child: Column(
              children: [
                _buildHeader(),
                _buildBucketTabs(),
                Expanded(
                  child: bookings.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
                          physics: const BouncingScrollPhysics(),
                          itemCount: bookings.length,
                          itemBuilder: (context, index) {
                            final booking = bookings[index];
                            return ServiceBookingListItem(
                              booking: booking,
                              isAccepting: profile.isAcceptingBookings,
                              onDisabledSwipe: _showPausedSnackBar,
                              onAdvance: () => BookingActions.advance(
                                context,
                                booking,
                                isAccepting: profile.isAcceptingBookings,
                              ),
                              onReject: () => BookingActions.reject(
                                context,
                                booking,
                                isAccepting: profile.isAcceptingBookings,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text(
                'Bookings',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                  height: 1.15,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  '${_store.openJobCount} open',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                    color: AppColors.secondaryText,
                    height: 1.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            _store.pendingRequestCount > 0
                ? '${_store.pendingRequestCount} request${_store.pendingRequestCount == 1 ? '' : 's'} waiting on you'
                : 'No requests waiting',
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 12.5,
              fontWeight: FontWeight.w400,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBucketTabs() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: 42,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: BookingBucket.values.length,
              itemBuilder: (context, index) {
                final bucket = BookingBucket.values[index];
                final bool isSelected = bucket == _bucket;
                final int count = _store.inBucket(bucket).length;

                return Padding(
                  padding: EdgeInsets.only(
                    right: index < BookingBucket.values.length - 1 ? 6 : 0,
                  ),
                  child: GestureDetector(
                    onTap: () => setState(() => _bucket = bucket),
                    behavior: HitTestBehavior.opaque,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTokens.inkFill
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            bucket.label,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : AppColors.secondaryText,
                              letterSpacing: 0.1,
                            ),
                          ),
                          if (count > 0) ...[
                            const SizedBox(width: 6),
                            Container(
                              constraints: const BoxConstraints(minWidth: 18),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 1,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.2)
                                    : AppTokens.divider,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                '$count',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? Colors.white
                                      : AppColors.secondaryText,
                                  height: 1.3,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Container(height: 1, color: AppTokens.dividerStrong),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    final (IconData icon, String title, String detail) = switch (_bucket) {
      BookingBucket.requests => (
          Icons.inbox_outlined,
          'No new requests',
          'New booking requests land here for you to accept or reject.',
        ),
      BookingBucket.upcoming => (
          Icons.event_available_outlined,
          'Nothing scheduled',
          'Accepted bookings waiting on their slot show up here.',
        ),
      BookingBucket.active => (
          Icons.directions_bike_outlined,
          'No jobs in progress',
          'Once you are on the way or on site, the job moves here.',
        ),
      BookingBucket.completed => (
          Icons.task_alt_outlined,
          'Nothing completed yet',
          'Finished jobs are kept here with their full timeline.',
        ),
      BookingBucket.cancelled => (
          Icons.cancel_outlined,
          'No cancellations',
          'Bookings you or the customer called off are listed here.',
        ),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppTokens.faintText),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTokens.mutedText,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              detail,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: AppTokens.faintText,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

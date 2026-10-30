import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../models/service_booking_model.dart';
import '../models/service_booking_store.dart';
import '../models/service_listing_model.dart';
import '../models/service_seller_profile_model.dart';
import '../utils/booking_actions.dart';
import '../widgets/service_availability_status.dart';
import '../widgets/service_booking_list_item.dart';
import '../widgets/services_bottom_nav_bar.dart';
import '../widgets/services_dashboard_header.dart';
import 'service_bookings_screen.dart';
import 'service_listing_list_screen.dart';
import 'services_offers_screen.dart';
import 'services_profile_screen.dart';

/// Shell and home screen for a services seller.
///
/// Same five-tab shape as `ShopDashboardScreen`, but the home tab is built
/// around the day's appointments rather than a basket queue: a services seller
/// opens the app to find out where they have to be, and only then what they
/// earned.
class ServicesDashboardScreen extends StatefulWidget {
  const ServicesDashboardScreen({super.key});

  @override
  State<ServicesDashboardScreen> createState() =>
      _ServicesDashboardScreenState();
}

class _ServicesDashboardScreenState extends State<ServicesDashboardScreen> {
  int _selectedIndex = 0;

  final ServiceBookingStore _store = ServiceBookingStore();

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

  void _setAccepting(bool value) {
    final provider = ServiceSellerProfileProvider();
    provider.updateProfile(
      provider.profileNotifier.value.copyWith(isAcceptingBookings: value),
    );
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
    return Scaffold(
      backgroundColor: AppTokens.pageBackground,
      body: SafeArea(
        child: switch (_selectedIndex) {
          0 => _buildDashboardContent(),
          1 => const ServiceListingListScreen(),
          2 => const ServiceBookingsScreen(),
          3 => const ServicesOffersScreen(),
          _ => const ServicesProfileScreen(),
        },
      ),
      bottomNavigationBar: ServicesBottomNavBar(
        selectedIndex: _selectedIndex,
        pendingRequests: _store.pendingRequestCount,
        onItemSelected: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }

  Widget _buildDashboardContent() {
    return ValueListenableBuilder<ServiceSellerProfile>(
      valueListenable: ServiceSellerProfileProvider().profileNotifier,
      builder: (context, profile, _) {
        final List<SellerBooking> schedule = _store.today;

        return Column(
          children: [
            // Fixed header + intake status
            ServicesDashboardHeader(title: profile.businessName),
            const SizedBox(height: 12),
            ServiceAvailabilityStatus(
              isAccepting: profile.isAcceptingBookings,
              activeJobs: _store.openJobCount,
              onChanged: _setAccepting,
            ),

            // Scrollable content.
            //
            // Deliberately not blurred when intake is off, unlike the shop
            // module's closed-store overlay: a tradesperson who stops taking
            // new work still has today's jobs to run, and hiding them behind
            // a shutter would be hiding the work they already committed to.
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: _buildBusinessHero(),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: _buildJobPipeline(),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: _buildBusinessOverview(profile),
                    ),
                  ),

                  // ── TODAY'S SCHEDULE SECTION TITLE ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Today's Schedule",
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                schedule.isEmpty
                                    ? 'Nothing booked for today'
                                    : _scheduleSubtitle(schedule),
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                          if (_store.pendingRequestCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppTokens.warningSoft,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppTokens.warningBorder,
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                '${_store.pendingRequestCount} new',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTokens.warningText,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),

                  // ── SCHEDULE LIST ──
                  if (schedule.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 40.0,
                        ),
                        child: Center(
                          child: Column(
                            children: const [
                              Icon(Icons.event_busy_outlined,
                                  size: 48, color: AppTokens.faintText),
                              SizedBox(height: 12),
                              Text(
                                'No jobs today',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 15,
                                  color: AppTokens.mutedText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final booking = schedule[index];
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
                          childCount: schedule.length,
                        ),
                      ),
                    ),

                  const SliverToBoxAdapter(child: SizedBox(height: 20)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  String _scheduleSubtitle(List<SellerBooking> schedule) {
    final int open = schedule.where((b) => b.status.isOpen).length;
    if (open == 0) return 'All of today\'s jobs are closed out';
    return '$open of ${schedule.length} still open';
  }

  // ─────────────────────────────────────────────────────
  // TODAY'S BUSINESS — Hero section with two primary KPIs
  // ─────────────────────────────────────────────────────
  Widget _buildBusinessHero() {
    return Container(
      decoration: BoxDecoration(
        color: AppTokens.surface,
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        border: Border.all(color: AppTokens.border, width: 1.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "TODAY'S BUSINESS",
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondaryText,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _buildHeroKPI(
                      icon: Icons.event_note_outlined,
                      iconBgColor: AppTokens.actionSoft,
                      iconColor: AppTokens.action,
                      label: "Today's Jobs",
                      value: '${_store.today.length}',
                    ),
                  ),

                  Container(
                    width: 1,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    color: AppTokens.divider,
                  ),

                  Expanded(
                    child: _buildHeroKPI(
                      icon: Icons.account_balance_wallet_outlined,
                      iconBgColor: AppTokens.earningsSoft,
                      iconColor: AppTokens.earnings,
                      label: "Today's Earnings",
                      value: '₹${_store.todaysEarnings.toStringAsFixed(0)}',
                      // Earnings count completed jobs only, so the pipeline
                      // figure is stated beside it rather than folded in.
                      footnote: _store.todaysPipeline > 0
                          ? '₹${_store.todaysPipeline.toStringAsFixed(0)} in progress'
                          : null,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroKPI({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String label,
    required String value,
    String? footnote,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: iconColor),
        ),
        const SizedBox(height: 14),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Poppins',
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppColors.secondaryText,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryText,
              height: 1.1,
            ),
          ),
        ),
        if (footnote != null) ...[
          const SizedBox(height: 3),
          Text(
            footnote,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10.5,
              fontWeight: FontWeight.w400,
              color: AppTokens.mutedText,
              height: 1.2,
            ),
          ),
        ],
      ],
    );
  }

  // ─────────────────────────────────────────────────────
  // JOB PIPELINE — where today's work has reached
  // ─────────────────────────────────────────────────────
  Widget _buildJobPipeline() {
    return _buildMetricSection(
      title: 'Job Pipeline',
      rows: [
        [
          _MetricSpec(
            icon: Icons.schedule_rounded,
            color: AppTokens.warning,
            label: 'Requests',
            value: '${_store.pendingRequestCount}',
          ),
          _MetricSpec(
            icon: Icons.event_available_rounded,
            color: AppTokens.action,
            label: 'Upcoming',
            value: '${_store.upcoming.length}',
          ),
        ],
        [
          _MetricSpec(
            icon: Icons.directions_bike_rounded,
            color: AppTokens.progress,
            label: 'Live now',
            value: '${_store.liveJobCount}',
          ),
          _MetricSpec(
            icon: Icons.task_alt_rounded,
            color: AppTokens.success,
            label: 'Completed',
            value: '${_store.todaysCompletedCount}',
          ),
        ],
      ],
    );
  }

  // ─────────────────────────────────────────────────────
  // BUSINESS OVERVIEW — catalogue and account standing
  // ─────────────────────────────────────────────────────
  Widget _buildBusinessOverview(ServiceSellerProfile profile) {
    final int activeListings =
        dummyServiceListings.where((s) => s.isActive).length;

    return _buildMetricSection(
      title: 'Business Overview',
      rows: [
        [
          _MetricSpec(
            icon: Icons.check_circle_outline,
            color: AppTokens.success,
            label: 'Active services',
            value: '$activeListings',
          ),
          _MetricSpec(
            icon: Icons.grid_view_rounded,
            color: AppTokens.info,
            label: 'Total services',
            value: '${dummyServiceListings.length}',
          ),
        ],
        [
          _MetricSpec(
            icon: Icons.verified_outlined,
            color: AppTokens.accentTeal,
            label: 'Jobs done',
            value: '${profile.jobsDone}',
          ),
          _MetricSpec(
            icon: Icons.workspace_premium_outlined,
            color: AppTokens.accentViolet,
            label: 'Current plan',
            value: 'Premium',
            showActiveDot: true,
          ),
        ],
      ],
    );
  }

  // ─────────────────────────────────────────────────────
  // Shared metric-card scaffolding
  //
  // Shop renders its secondary metrics as a white card with hairline-divided
  // cells, not as filled tiles. Both sections here go through one builder so
  // they cannot drift from each other either.
  // ─────────────────────────────────────────────────────
  Widget _buildMetricSection({
    required String title,
    required List<List<_MetricSpec>> rows,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Poppins',
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
        ),

        Container(
          decoration: BoxDecoration(
            color: AppTokens.surface,
            borderRadius: BorderRadius.circular(AppTokens.radiusCard),
            border: Border.all(color: AppTokens.border, width: 1.0),
          ),
          child: Column(
            children: [
              for (int i = 0; i < rows.length; i++) ...[
                if (i > 0) Container(height: 1, color: AppTokens.divider),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      for (int j = 0; j < rows[i].length; j++) ...[
                        if (j > 0)
                          Container(width: 1, color: AppTokens.divider),
                        Expanded(child: _buildMetricCell(rows[i][j])),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCell(_MetricSpec spec) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: spec.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(spec.icon, size: 16, color: spec.color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  spec.label,
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: AppColors.secondaryText,
                    height: 1.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        spec.value,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryText,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (spec.showActiveDot) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: AppTokens.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// One cell in a metric card.
class _MetricSpec {
  final IconData icon;
  final Color color;
  final String label;
  final String value;

  /// Small green dot after the value — used for "Current plan: Premium", where
  /// the value is a state rather than a count.
  final bool showActiveDot;

  const _MetricSpec({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    this.showActiveDot = false,
  });
}

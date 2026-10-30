import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_tokens.dart';
import '../models/service_seller_profile_model.dart';

/// The seller's profile and account settings.
///
/// Built on the same pattern as `ShopProfileScreen`: an app bar, a hero card,
/// then grouped setting tiles and a logout card. The first version of this
/// screen was a bespoke info page — monogram, a stat strip, chip lists — which
/// carried the same data but read as a different app's profile tab.
///
/// Services-specific facts (areas covered, working hours, performance) are
/// carried as tiles in a Business group rather than as new layouts, so the
/// page gains nothing Shop does not already have a shape for.
class ServicesProfileScreen extends StatefulWidget {
  const ServicesProfileScreen({super.key});

  @override
  State<ServicesProfileScreen> createState() => _ServicesProfileScreenState();
}

class _ServicesProfileScreenState extends State<ServicesProfileScreen> {
  bool _isDarkMode = false;

  ServiceSellerProfileProvider get _provider => ServiceSellerProfileProvider();

  void _setAccepting(bool value) {
    _provider.updateProfile(
      _provider.profileNotifier.value.copyWith(isAcceptingBookings: value),
    );
  }

  void _showFeedback(String message) {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontFamily: 'Poppins', fontSize: 14),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: AppColors.primaryText,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.only(bottom: 24, left: 16, right: 16),
      ),
    );
  }

  void _showLogoutConfirmation() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTokens.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTokens.danger.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout,
                    color: AppTokens.danger,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Logout?',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Are you sure you want to logout of your seller account?',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 15,
                color: AppColors.secondaryText,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppTokens.borderField),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTokens.radiusRow),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showFeedback('Logout selected');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTokens.danger,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTokens.radiusRow),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ServiceSellerProfile>(
      valueListenable: _provider.profileNotifier,
      builder: (context, profile, _) {
        return Scaffold(
          backgroundColor: AppTokens.pageBackground,
          appBar: AppBar(
            backgroundColor: AppTokens.pageBackground,
            elevation: 0,
            centerTitle: false,
            title: const Text(
              'Profile',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryText,
              ),
            ),
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            automaticallyImplyLeading: false, // Managed by bottom nav
          ),
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── HERO SECTION ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: _buildProfileHero(profile),
                ),
              ),

              // ── ACCOUNT SECTION ──
              SliverToBoxAdapter(
                child: _buildSectionGroup(
                  title: 'ACCOUNT',
                  children: [
                    _buildActionTile(
                      title: 'Profile Edit',
                      subtitle: 'Update your business information',
                      icon: Icons.person_outline,
                      iconColor: AppTokens.info,
                      iconBgColor: AppTokens.actionTile,
                      onTap: () => _showFeedback('Profile editing is not built yet'),
                    ),
                  ],
                ),
              ),

              // ── BUSINESS SECTION ──
              //
              // Where the services-specific facts live. Shop has no equivalent
              // group, but every tile here is Shop's tile.
              SliverToBoxAdapter(
                child: _buildSectionGroup(
                  title: 'BUSINESS',
                  children: [
                    _buildActionTile(
                      title: 'Service Areas',
                      subtitle: profile.serviceAreas.isEmpty
                          ? 'No areas set'
                          : '${profile.serviceAreas.length} areas · '
                              '${profile.serviceAreas.take(2).join(', ')}…',
                      icon: Icons.map_outlined,
                      iconColor: AppTokens.accentTeal,
                      iconBgColor: AppTokens.accentTealSoft,
                      onTap: () => _showFeedback('Service areas are not editable yet'),
                    ),
                    _buildActionTile(
                      title: 'Working Hours',
                      subtitle: profile.workingHours,
                      icon: Icons.schedule_outlined,
                      iconColor: AppTokens.warning,
                      iconBgColor: AppTokens.warningSoft,
                      onTap: () => _showFeedback('Working hours are not editable yet'),
                    ),
                    _buildActionTile(
                      title: 'Departments',
                      subtitle: profile.categoriesHandled.isEmpty
                          ? 'No departments set'
                          : profile.categoriesHandled.join(' · '),
                      icon: Icons.handyman_outlined,
                      iconColor: AppTokens.accentViolet,
                      iconBgColor: AppTokens.accentVioletSoft,
                      onTap: () => _showFeedback('Departments are not editable yet'),
                    ),
                    _buildActionTile(
                      title: 'Performance',
                      subtitle: profile.reviewsCount == 0
                          ? '${profile.jobsDone} jobs done · No reviews yet'
                          : '${profile.jobsDone} jobs done · '
                              '${profile.rating.toStringAsFixed(1)} from '
                              '${profile.reviewsCount} reviews',
                      icon: Icons.insights_outlined,
                      iconColor: AppTokens.positive,
                      iconBgColor: AppTokens.positiveSoft,
                      onTap: () => _showFeedback('Performance detail is not built yet'),
                    ),
                  ],
                ),
              ),

              // ── PLAN & AVAILABILITY SECTION ──
              SliverToBoxAdapter(
                child: _buildSectionGroup(
                  title: 'PLAN & AVAILABILITY',
                  children: [
                    _buildActionTile(
                      title: 'Change Plan',
                      subtitle: 'Choose a different seller plan',
                      icon: Icons.card_membership_outlined,
                      iconColor: AppTokens.accentViolet,
                      iconBgColor: AppTokens.accentVioletSoft,
                      onTap: () => _showFeedback('Change Plan selected'),
                    ),
                    _buildActionTile(
                      title: 'Availability',
                      subtitle: 'Control whether you take new bookings',
                      icon: Icons.event_available_outlined,
                      iconColor: AppTokens.positive,
                      iconBgColor: AppTokens.positiveSoft,
                      trailing: Switch.adaptive(
                        value: profile.isAcceptingBookings,
                        activeTrackColor: AppTokens.positive,
                        onChanged: (val) {
                          _setAccepting(val);
                          _showFeedback(
                            val
                                ? 'Now accepting new bookings'
                                : 'New booking requests paused',
                          );
                        },
                      ),
                      onTap: () {
                        final next = !profile.isAcceptingBookings;
                        _setAccepting(next);
                        _showFeedback(
                          next
                              ? 'Now accepting new bookings'
                              : 'New booking requests paused',
                        );
                      },
                      showChevron: false,
                    ),
                  ],
                ),
              ),

              // ── PREFERENCES SECTION ──
              SliverToBoxAdapter(
                child: _buildSectionGroup(
                  title: 'PREFERENCES',
                  children: [
                    _buildActionTile(
                      title: 'Settings',
                      subtitle: 'Manage app preferences',
                      icon: Icons.settings_outlined,
                      iconColor: AppColors.secondaryText,
                      iconBgColor: AppTokens.divider,
                      onTap: () => _showFeedback('Settings selected'),
                    ),
                    _buildActionTile(
                      title: 'Appearance',
                      subtitle: 'Switch to dark or light mode',
                      icon: _isDarkMode
                          ? Icons.dark_mode_outlined
                          : Icons.light_mode_outlined,
                      iconColor: AppTokens.warning,
                      iconBgColor: AppTokens.warningSoft,
                      trailing: _buildThemeToggle(),
                      onTap: () {},
                      showChevron: false,
                    ),
                  ],
                ),
              ),

              // ── SECURITY SECTION ──
              SliverToBoxAdapter(
                child: _buildSectionGroup(
                  title: 'SECURITY',
                  children: [
                    _buildActionTile(
                      title: 'Change Password',
                      subtitle: 'Update your account password',
                      icon: Icons.lock_outline,
                      iconColor: AppTokens.accentTeal,
                      iconBgColor: AppTokens.accentTealSoft,
                      onTap: () => _showFeedback('Change Password selected'),
                    ),
                  ],
                ),
              ),

              // ── HELP & SUPPORT SECTION ──
              SliverToBoxAdapter(
                child: _buildSectionGroup(
                  title: 'HELP & SUPPORT',
                  children: [
                    _buildActionTile(
                      title: 'Suggestion',
                      subtitle: 'Share ideas to improve UDUR',
                      icon: Icons.lightbulb_outline,
                      iconColor: AppTokens.progress,
                      iconBgColor: AppTokens.progressSoft,
                      onTap: () => _showFeedback('Suggestion selected'),
                    ),
                    _buildActionTile(
                      title: 'Contact Us',
                      subtitle: 'Get help or contact the UDUR team',
                      icon: Icons.support_agent_outlined,
                      iconColor: AppTokens.info,
                      iconBgColor: AppTokens.actionTile,
                      onTap: () => _showFeedback('Contact Us selected'),
                    ),
                  ],
                ),
              ),

              // ── LOGOUT SECTION ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 48),
                  child: InkWell(
                    onTap: _showLogoutConfirmation,
                    borderRadius: BorderRadius.circular(AppTokens.radiusCard),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: AppTokens.surface,
                        borderRadius:
                            BorderRadius.circular(AppTokens.radiusCard),
                        border: Border.all(color: AppTokens.borderField),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTokens.danger.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.logout,
                              color: AppTokens.danger,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Text(
                              'Logout',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTokens.danger,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bottom spacing for navigation bar
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        );
      },
    );
  }

  /// ── WIDGETS ──

  Widget _buildProfileHero(ServiceSellerProfile profile) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTokens.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTokens.borderField),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar. A monogram rather than a photo: the customer app draws
              // providers the same way, and there is no provider image to load.
              GestureDetector(
                onTap: () => _showFeedback('Profile editing is not built yet'),
                child: Stack(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTokens.divider,
                        border: Border.all(
                          color: AppTokens.borderField,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        profile.initials,
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.edit,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            profile.businessName,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryText,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (profile.isVerified) ...[
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.verified_rounded,
                            size: 17,
                            color: AppTokens.action,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.categoriesHandled.isEmpty
                          ? profile.ownerName
                          : profile.categoriesHandled.first,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      profile.email,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 13,
                        color: AppColors.secondaryText.withValues(alpha: 0.8),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Status & Plan row
          Row(
            children: [
              Expanded(
                child: _buildHeroPill(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: profile.isAcceptingBookings
                              ? AppTokens.positive
                              : AppTokens.danger,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        profile.isAcceptingBookings ? 'Available' : 'Paused',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildHeroPill(
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        size: 16,
                        color: AppTokens.warning,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Premium Plan',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeroPill({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: AppTokens.fieldFill,
        borderRadius: BorderRadius.circular(AppTokens.radiusField),
        border: Border.all(color: AppTokens.divider),
      ),
      child: child,
    );
  }

  Widget _buildThemeToggle() {
    return Container(
      height: 36,
      decoration: BoxDecoration(
        color: AppTokens.divider,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildThemeOption(label: 'Light', isSelected: !_isDarkMode),
          _buildThemeOption(label: 'Dark', isSelected: _isDarkMode),
        ],
      ),
    );
  }

  Widget _buildThemeOption({required String label, required bool isSelected}) {
    return GestureDetector(
      onTap: () {
        setState(() => _isDarkMode = label == 'Dark');
        _showFeedback('$label Mode selected');
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTokens.radiusRow),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                  ),
                ]
              : [],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color:
                isSelected ? AppColors.primaryText : AppColors.secondaryText,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionGroup({
    required String title,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
                color: AppColors.secondaryText,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: AppTokens.surface,
              borderRadius: BorderRadius.circular(AppTokens.radiusCard),
              border: Border.all(color: AppTokens.borderField),
            ),
            child: Column(
              children: List.generate(
                children.length,
                (index) => Column(
                  children: [
                    children[index],
                    if (index < children.length - 1)
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: AppTokens.divider,
                        indent: 72,
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

  Widget _buildActionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required VoidCallback onTap,
    Widget? trailing,
    bool showChevron = true,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTokens.radiusCard),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(AppTokens.radiusField),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: AppColors.secondaryText,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (trailing != null)
                trailing
              else if (showChevron)
                const Icon(
                  Icons.chevron_right,
                  color: AppTokens.faintText,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

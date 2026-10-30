import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../models/seller_profile_model.dart';
import 'shop_edit_profile_screen.dart';
class ShopProfileScreen extends StatefulWidget {
  const ShopProfileScreen({super.key});

  @override
  State<ShopProfileScreen> createState() => _ShopProfileScreenState();
}

class _ShopProfileScreenState extends State<ShopProfileScreen> {
  // Local state for UI toggles
  bool _isStoreAvailable = true;
  bool _isDarkMode = false;

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
        backgroundColor: const Color(0xFF1F2937),
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
          color: Colors.white,
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
                    color: Colors.red.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.logout, color: Colors.red, size: 24),
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
                      side: const BorderSide(color: Color(0xFFE5E7EB)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.primaryText),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _showFeedback("Logout selected");
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Logout',
                      style: TextStyle(fontFamily: 'Poppins', fontSize: 15, fontWeight: FontWeight.w600, color: Colors.white),
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
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FA),
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
              child: _buildProfileHero(),
            ),
          ),

          // ── ACCOUNT SECTION ──
          SliverToBoxAdapter(
            child: _buildSectionGroup(
              title: 'ACCOUNT',
              children: [
                _buildActionTile(
                  title: 'Profile Edit',
                  subtitle: 'Update your seller information',
                  icon: Icons.person_outline,
                  iconColor: const Color(0xFF3B82F6),
                  iconBgColor: const Color(0xFFEFF6FF),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ShopEditProfileScreen()),
                    );
                  },
                ),
              ],
            ),
          ),

          // ── PLAN & STORE SECTION ──
          SliverToBoxAdapter(
            child: _buildSectionGroup(
              title: 'PLAN & STORE',
              children: [
                _buildActionTile(
                  title: 'Change Plan',
                  subtitle: 'Choose a different seller plan',
                  icon: Icons.card_membership_outlined,
                  iconColor: const Color(0xFF8B5CF6),
                  iconBgColor: const Color(0xFFF5F3FF),
                  onTap: () => _showFeedback('Change Plan selected'),
                ),
                _buildActionTile(
                  title: 'Availability',
                  subtitle: 'Control whether your store is available',
                  icon: Icons.store_outlined,
                  iconColor: const Color(0xFF10B981),
                  iconBgColor: const Color(0xFFECFDF5),
                  trailing: Switch.adaptive(
                    value: _isStoreAvailable,
                    activeTrackColor: const Color(0xFF10B981),
                    onChanged: (val) {
                      setState(() {
                        _isStoreAvailable = val;
                      });
                      _showFeedback('Availability selected');
                    },
                  ),
                  onTap: () {
                    setState(() {
                      _isStoreAvailable = !_isStoreAvailable;
                    });
                    _showFeedback('Availability selected');
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
                  iconColor: const Color(0xFF6B7280),
                  iconBgColor: const Color(0xFFF3F4F6),
                  onTap: () => _showFeedback('Settings selected'),
                ),
                _buildActionTile(
                  title: 'Appearance',
                  subtitle: 'Switch to dark or light mode',
                  icon: _isDarkMode ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
                  iconColor: const Color(0xFFF59E0B),
                  iconBgColor: const Color(0xFFFEF3C7),
                  trailing: Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() => _isDarkMode = false);
                            _showFeedback('Light Mode selected');
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: !_isDarkMode ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: !_isDarkMode
                                  ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                                  : [],
                            ),
                            child: Text(
                              'Light',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: !_isDarkMode ? FontWeight.w600 : FontWeight.w400,
                                color: !_isDarkMode ? AppColors.primaryText : AppColors.secondaryText,
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() => _isDarkMode = true);
                            _showFeedback('Dark Mode selected');
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: _isDarkMode ? Colors.white : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: _isDarkMode
                                  ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]
                                  : [],
                            ),
                            child: Text(
                              'Dark',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 13,
                                fontWeight: _isDarkMode ? FontWeight.w600 : FontWeight.w400,
                                color: _isDarkMode ? AppColors.primaryText : AppColors.secondaryText,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                  iconColor: const Color(0xFF14B8A6),
                  iconBgColor: const Color(0xFFCCFBF1),
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
                  iconColor: const Color(0xFFF97316),
                  iconBgColor: const Color(0xFFFFEDD5),
                  onTap: () => _showFeedback('Suggestion selected'),
                ),
                _buildActionTile(
                  title: 'Contact Us',
                  subtitle: 'Get help or contact the UDUR team',
                  icon: Icons.support_agent_outlined,
                  iconColor: const Color(0xFF3B82F6),
                  iconBgColor: const Color(0xFFEFF6FF),
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
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.logout, color: Colors.red, size: 22),
                      ),
                      const SizedBox(width: 16),
                      const Expanded(
                        child: Text(
                          'Logout',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.red,
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
  }

  /// ── WIDGETS ──

  Widget _buildProfileHero() {
    return ValueListenableBuilder<SellerProfile>(
      valueListenable: SellerProfileProvider().profileNotifier,
      builder: (context, profile, _) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE5E7EB)),
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
                  // Avatar
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ShopEditProfileScreen()),
                      );
                    },
                    child: Stack(
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFF3F4F6),
                            border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
                          ),
                          child: ClipOval(
                            child: profile.profileImage != null && profile.profileImage!.startsWith('assets/')
                                ? Image.asset(profile.profileImage!, fit: BoxFit.cover, errorBuilder: (_, _, _) => const Icon(Icons.store, color: AppColors.secondaryText, size: 30))
                                : (profile.profileImage != null 
                                    ? Image.file(File(profile.profileImage!), fit: BoxFit.cover)
                                    : const Icon(Icons.store, color: AppColors.secondaryText, size: 30)),
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
                            child: const Icon(Icons.edit, size: 12, color: Colors.white),
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
                        Text(
                          profile.shopName,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryText,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          profile.mainCategory,
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
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(width: 8, height: 8, decoration: const BoxDecoration(color: Color(0xFF10B981), shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      const Text(
                        'Active',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryText),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFF1F5F9)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.workspace_premium, size: 16, color: Color(0xFFF59E0B)),
                      SizedBox(width: 6),
                      Text(
                        'Free Plan',
                        style: TextStyle(fontFamily: 'Poppins', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryText),
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
    });
  }

  Widget _buildSectionGroup({required String title, required List<Widget> children}) {
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
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: Column(
              children: List.generate(
                children.length,
                (index) => Column(
                  children: [
                    children[index],
                    if (index < children.length - 1)
                      const Divider(height: 1, thickness: 1, color: Color(0xFFF3F4F6), indent: 72),
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
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
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
                    ),
                  ],
                ),
              ),
              if (trailing != null)
                trailing
              else if (showChevron)
                const Icon(Icons.chevron_right, color: Color(0xFFD1D5DB), size: 24),
            ],
          ),
        ),
      ),
    );
  }
}

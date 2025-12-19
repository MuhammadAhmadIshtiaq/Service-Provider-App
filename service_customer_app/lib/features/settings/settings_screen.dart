// ============================================
// ENHANCED UI: lib/features/settings/settings_screen.dart
// Modern gradient design with beautiful cards and animations
// ============================================
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _darkMode = false;
  String _language = 'English';

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(Icons.language_rounded, color: Colors.blue, size: 28),
              SizedBox(width: 12),
              Text('Select Language'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildLanguageOption('English', Icons.flag),
              _buildLanguageOption('Spanish', Icons.flag),
              _buildLanguageOption('French', Icons.flag),
              _buildLanguageOption('German', Icons.flag),
              _buildLanguageOption('Arabic', Icons.flag),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(String language, IconData icon) {
    final isSelected = _language == language;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() => _language = language);
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: Colors.white),
                  const SizedBox(width: 12),
                  Text('Language changed to $language'),
                ],
              ),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.blue : Colors.grey[200]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.blue : Colors.grey[600],
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  language,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.blue : Colors.black87,
                  ),
                ),
              ),
              if (isSelected)
                const Icon(Icons.check_circle_rounded, color: Colors.blue, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Gradient Header
            Container(
              width: double.infinity,
              height: 180,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.purple[600]!,
                    Colors.purple[400]!,
                    Colors.deepPurple[400]!,
                  ],
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.settings_rounded,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Customize Your',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Text(
                        'Experience',
                        style: TextStyle(
                          fontSize: 26,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Content with Transform
            Transform.translate(
              offset: const Offset(0, -30),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // Notifications Card
                    _buildSectionCard(
                      title: 'Notifications',
                      icon: Icons.notifications_rounded,
                      iconColor: Colors.orange,
                      iconBg: Colors.orange[50]!,
                      children: [
                        _buildModernSwitchTile(
                          icon: Icons.notifications_active_rounded,
                          title: 'Push Notifications',
                          subtitle: 'Receive real-time alerts',
                          value: _pushNotifications,
                          activeColor: Colors.orange,
                          onChanged: (value) {
                            setState(() => _pushNotifications = value);
                            _showToast(
                              value ? 'Push notifications enabled' : 'Push notifications disabled',
                              value ? Colors.green : Colors.grey,
                            );
                          },
                        ),
                        _buildDivider(),
                        _buildModernSwitchTile(
                          icon: Icons.email_rounded,
                          title: 'Email Notifications',
                          subtitle: 'Get updates via email',
                          value: _emailNotifications,
                          activeColor: Colors.blue,
                          onChanged: (value) {
                            setState(() => _emailNotifications = value);
                            _showToast(
                              value ? 'Email notifications enabled' : 'Email notifications disabled',
                              value ? Colors.green : Colors.grey,
                            );
                          },
                        ),
                        _buildDivider(),
                        _buildModernSwitchTile(
                          icon: Icons.sms_rounded,
                          title: 'SMS Notifications',
                          subtitle: 'Receive text messages',
                          value: _smsNotifications,
                          activeColor: Colors.green,
                          onChanged: (value) {
                            setState(() => _smsNotifications = value);
                            _showToast(
                              value ? 'SMS notifications enabled' : 'SMS notifications disabled',
                              value ? Colors.green : Colors.grey,
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Appearance Card
                    _buildSectionCard(
                      title: 'Appearance',
                      icon: Icons.palette_rounded,
                      iconColor: Colors.purple,
                      iconBg: Colors.purple[50]!,
                      children: [
                        _buildModernSwitchTile(
                          icon: Icons.dark_mode_rounded,
                          title: 'Dark Mode',
                          subtitle: 'Switch to dark theme',
                          value: _darkMode,
                          activeColor: Colors.indigo,
                          onChanged: (value) {
                            setState(() => _darkMode = value);
                            _showToast(
                              value ? 'Dark mode enabled' : 'Dark mode disabled',
                              value ? Colors.green : Colors.grey,
                            );
                          },
                        ),
                        _buildDivider(),
                        _buildModernMenuItem(
                          icon: Icons.language_rounded,
                          title: 'Language',
                          subtitle: _language,
                          iconColor: Colors.blue,
                          iconBg: Colors.blue[50]!,
                          onTap: _showLanguageDialog,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Account Card
                    _buildSectionCard(
                      title: 'Account',
                      icon: Icons.account_circle_rounded,
                      iconColor: Colors.teal,
                      iconBg: Colors.teal[50]!,
                      children: [
                   _buildModernMenuItem(
  icon: Icons.lock_rounded,
  title: 'Change Password',
  subtitle: 'Update your password',
  iconColor: Colors.red,
  iconBg: Colors.red[50]!,
  onTap: () {
    // UPDATED: Navigate to change password screen
    context.push('/change-password');
  },
),
                        _buildDivider(),
                        _buildModernMenuItem(
                          icon: Icons.security_rounded,
                          title: 'Security',
                          subtitle: 'Manage security settings',
                          iconColor: Colors.orange,
                          iconBg: Colors.orange[50]!,
                          onTap: () {
                            // TODO: Navigate to security settings
                            _showToast('Security settings coming soon', Colors.blue);
                          },
                        ),
                        _buildDivider(),
                        _buildModernMenuItem(
                          icon: Icons.payment_rounded,
                          title: 'Payment Methods',
                          subtitle: 'Manage your cards',
                          iconColor: Colors.green,
                          iconBg: Colors.green[50]!,
                          onTap: () {
                            // TODO: Navigate to payment methods
                            _showToast('Payment methods coming soon', Colors.blue);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Legal & About Card
                    _buildSectionCard(
                      title: 'Legal & About',
                      icon: Icons.info_rounded,
                      iconColor: Colors.indigo,
                      iconBg: Colors.indigo[50]!,
                      children: [
                        _buildModernMenuItem(
                          icon: Icons.privacy_tip_rounded,
                          title: 'Privacy Policy',
                          subtitle: 'How we protect your data',
                          iconColor: Colors.blue,
                          iconBg: Colors.blue[50]!,
                          onTap: () {
                            // TODO: Navigate to privacy policy
                            _showToast('Opening Privacy Policy', Colors.blue);
                          },
                        ),
                        _buildDivider(),
                        _buildModernMenuItem(
                          icon: Icons.description_rounded,
                          title: 'Terms of Service',
                          subtitle: 'Read our terms',
                          iconColor: Colors.purple,
                          iconBg: Colors.purple[50]!,
                          onTap: () {
                            // TODO: Navigate to terms
                            _showToast('Opening Terms of Service', Colors.blue);
                          },
                        ),
                        _buildDivider(),
                        _buildModernMenuItem(
                          icon: Icons.help_rounded,
                          title: 'Help & Support',
                          subtitle: 'Get assistance',
                          iconColor: Colors.orange,
                          iconBg: Colors.orange[50]!,
                          onTap: () {
                            // TODO: Navigate to help
                            _showToast('Opening Help Center', Colors.blue);
                          },
                        ),
                        _buildDivider(),
                        _buildModernMenuItem(
                          icon: Icons.star_rounded,
                          title: 'Rate Us',
                          subtitle: 'Share your feedback',
                          iconColor: Colors.amber,
                          iconBg: Colors.amber[50]!,
                          onTap: () {
                            _showToast('Thank you for your support!', Colors.green);
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Danger Zone Card
                    _buildSectionCard(
                      title: 'Danger Zone',
                      icon: Icons.warning_rounded,
                      iconColor: Colors.red,
                      iconBg: Colors.red[50]!,
                      children: [
                        _buildModernMenuItem(
                          icon: Icons.delete_forever_rounded,
                          title: 'Delete Account',
                          subtitle: 'Permanently delete your account',
                          iconColor: Colors.red,
                          iconBg: Colors.red[50]!,
                          textColor: Colors.red,
                          onTap: () {
                            _showDeleteAccountDialog();
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // App Version
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              size: 18,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Version 1.0.0',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildModernSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Color activeColor,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: activeColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: activeColor, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeColor: activeColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color iconColor,
    required Color iconBg,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBg,
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
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: textColor ?? Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey[400],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 68, right: 20),
      child: Divider(height: 1, color: Colors.grey[200]),
    );
  }

  void _showToast(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              color == Colors.green ? Icons.check_circle_rounded : Icons.info_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.red, size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Delete Account',
                  style: TextStyle(fontSize: 20),
                ),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to delete your account?',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),
              Text(
                'This action cannot be undone. All your data will be permanently removed.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _showToast('Account deletion cancelled', Colors.grey);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}


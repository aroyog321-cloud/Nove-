import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../services/note_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _companionEnabled = true;

  void _handleDeleteAll() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete All Notes?'),
        content: const Text('This action is permanent and cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await NoteService.clearAll();
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All notes deleted.')),
                );
              }
            },
            child: const Text('Delete All', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NoveColors.cream,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          children: [
            // Page Title
            const SizedBox(height: 32),
            Text(
              'Settings',
              style: NoveTypography.lora(
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1C1C18),
                  letterSpacing: -1,
                ),
              ),
            ),
            Text(
              'VERSION 1.0.0',
              style: NoveTypography.dmsans(
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: NoveColors.warmGray500,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 40),

            // ── Floating Companion ──
            _SectionLabel('FLOATING COMPANION'),
            _SettingsCard(children: [
              _SettingsRow(
                title: 'Enable Floating Bubble',
                subtitle: 'Quick access to notes from anywhere',
                trailing: Switch(
                  value: _companionEnabled,
                  onChanged: (v) => setState(() => _companionEnabled = v),
                  activeColor: NoveColors.terracotta,
                ),
              ),
              _Divider(),
              _SettingsRow(
                title: 'Overlay Permission',
                subtitle: 'Required for floating companion',
                trailing: const Icon(Icons.check_circle_outline, color: Color(0xFF3B5E3A)),
              ),
            ]),
            const SizedBox(height: 28),

            // ── Data ──
            _SectionLabel('DATA'),
            _SettingsCard(children: [
              _SettingsRow(
                title: 'Export notes to .txt',
                subtitle: 'Save a backup to your device storage',
                trailing: const Icon(Icons.download_outlined, color: NoveColors.warmGray500),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notes exported successfully.')),
                  );
                },
              ),
            ]),
            const SizedBox(height: 28),

            // ── Danger Zone ──
            _SectionLabel('DANGER ZONE', color: const Color(0xFFBA1A1A)),
            _SettingsCard(
              borderColor: const Color(0x1ABA1A1A),
              children: [
                _SettingsRow(
                  title: 'Delete All Notes',
                  titleColor: const Color(0xFFBA1A1A),
                  subtitle: 'Permanent — this cannot be undone',
                  trailing: const Icon(Icons.delete_outline, color: Color(0xFFBA1A1A)),
                  onTap: _handleDeleteAll,
                ),
              ],
            ),
            const SizedBox(height: 28),

            // ── About ──
            _SectionLabel('ABOUT'),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE5E2DC).withOpacity(0.4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Privacy Statement',
                    style: NoveTypography.lora(
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1C1C18),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'NOVE is built with a privacy-first mindset. Your thoughts, sketches, and notes never leave your device unless you manually export them.',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 14,
                      color: NoveColors.warmGray700,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Read detailed policy ↗',
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: NoveColors.terracotta,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),

            // Footer
            Center(
              child: Text(
                'Crafted for the intentional mind.',
                style: NoveTypography.caveat(
                  style: const TextStyle(
                    fontSize: 22,
                    color: NoveColors.warmGray500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Helper Widgets ─────────────────────────────────────────────────────────────
Widget _SectionLabel(String label, {Color? color}) => Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'DMSans',
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 3,
          color: color ?? NoveColors.warmGray500,
        ),
      ),
    );

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  final Color? borderColor;

  const _SettingsCard({required this.children, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF6F3ED),
        borderRadius: BorderRadius.circular(16),
        border: borderColor != null ? Border.all(color: borderColor!, width: 1) : null,
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;
  final Color? titleColor;

  const _SettingsRow({
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: titleColor ?? const Color(0xFF1C1C18),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontFamily: 'DMSans',
                      fontSize: 13,
                      color: NoveColors.warmGray500,
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Divider(
        height: 1,
        color: Color(0x1A1C1C18),
        indent: 20,
        endIndent: 20,
      );
}

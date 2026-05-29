import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/neo_button.dart';
import '../../../core/widgets/neo_card.dart';
import '../../../data/models/guest.dart';
import '../../../domain/blocs/guest/guest_bloc.dart';
import 'guest_form_screen.dart';

/// Guest list screen displaying all guests with summary counts.
///
/// Shows name, side (Pria/Wanita/Keluarga), and invitation status for each guest.
/// Displays summary: total guests, confirmed (Konfirmasi/Hadir), pending (Belum Diundang/Diundang).
/// Requirements: 5.1, 5.2, 5.4, 5.6
class GuestScreen extends StatefulWidget {
  const GuestScreen({super.key});

  @override
  State<GuestScreen> createState() => _GuestScreenState();
}

class _GuestScreenState extends State<GuestScreen> {
  @override
  void initState() {
    super.initState();
    context.read<GuestBloc>().add(const LoadGuests());
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<GuestBloc>();
    bloc.add(const LoadGuests());
    await bloc.stream.firstWhere(
      (state) => state is! GuestLoading,
    );
  }

  void _navigateToAddGuest() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const GuestFormScreen()),
    );
  }

  void _showDeleteConfirmation(Guest guest) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          side: const BorderSide(color: AppTheme.black, width: AppTheme.borderWidth),
        ),
        title: const Text('Hapus Tamu', style: AppTypography.h4),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${guest.name}" dari daftar tamu?',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Batal',
              style: AppTypography.body.copyWith(color: AppTheme.darkGray),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<GuestBloc>().add(DeleteGuest(id: guest.id));
            },
            child: Text(
              'Hapus',
              style: AppTypography.body.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        title: const Text('Daftar Tamu', style: AppTypography.h3),
        backgroundColor: AppTheme.white,
        elevation: 0,
      ),
      body: BlocConsumer<GuestBloc, GuestState>(
        listener: (context, state) {
          if (state is GuestError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade700,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is GuestLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.pink),
            );
          }

          final guests = _getGuests(state);

          return RefreshIndicator(
            color: AppTheme.pink,
            onRefresh: _onRefresh,
            child: guests.isEmpty
                ? _buildEmptyState()
                : _buildGuestList(guests),
          );
        },
      ),
      floatingActionButton: _buildAddButton(),
    );
  }

  List<Guest> _getGuests(GuestState state) {
    if (state is GuestLoaded) return state.guests;
    if (state is GuestError) return state.guests;
    return [];
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 120),
        Center(
          child: Column(
            children: [
              Icon(Icons.people_outline, size: 64, color: AppTheme.lightPink),
              SizedBox(height: 16),
              Text('Belum ada tamu.', style: AppTypography.body),
              SizedBox(height: 8),
              Text(
                'Tap + untuk menambah tamu baru.',
                style: AppTypography.secondary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGuestList(List<Guest> guests) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSummaryCard(guests),
          const SizedBox(height: 16),
          ...guests.map((guest) => _buildGuestItem(guest)),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  /// Summary card showing total, confirmed, and pending counts.
  /// Requirement 5.2
  Widget _buildSummaryCard(List<Guest> guests) {
    final total = guests.length;
    final confirmed = guests.where((g) =>
        g.status == GuestStatus.konfirmasi || g.status == GuestStatus.hadir).length;
    final pending = guests.where((g) =>
        g.status == GuestStatus.belumDiundang || g.status == GuestStatus.diundang).length;

    return NeoCard(
      child: Row(
        children: [
          Expanded(
            child: _buildCountItem(
              label: 'Total',
              count: total,
              icon: Icons.people,
            ),
          ),
          Expanded(
            child: _buildCountItem(
              label: 'Konfirmasi',
              count: confirmed,
              icon: Icons.check_circle,
            ),
          ),
          Expanded(
            child: _buildCountItem(
              label: 'Pending',
              count: pending,
              icon: Icons.hourglass_empty,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountItem({
    required String label,
    required int count,
    required IconData icon,
  }) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.pink, size: 24),
        const SizedBox(height: 4),
        Text(
          count.toString(),
          style: AppTypography.h3.copyWith(color: AppTheme.pink),
        ),
        const SizedBox(height: 2),
        Text(label, style: AppTypography.caption),
      ],
    );
  }

  /// Individual guest item card showing name, side, and status.
  /// Requirement 5.1
  Widget _buildGuestItem(Guest guest) {
    return NeoCard(
      backgroundColor: AppTheme.white,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guest.name,
                  style: AppTypography.body.copyWith(fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildTag(_sideLabel(guest.side), AppTheme.lightPink),
                    const SizedBox(width: 8),
                    _buildTag(_statusLabel(guest.status), _statusColor(guest.status)),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 22),
            onPressed: () => _showDeleteConfirmation(guest),
            tooltip: 'Hapus tamu',
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color backgroundColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.black, width: 1.5),
      ),
      child: Text(
        text,
        style: AppTypography.body.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildAddButton() {
    return NeoButton(
      onPressed: _navigateToAddGuest,
      label: '+',
      padding: const EdgeInsets.all(16),
    );
  }

  String _sideLabel(GuestSide side) {
    switch (side) {
      case GuestSide.pria:
        return 'Pria';
      case GuestSide.wanita:
        return 'Wanita';
      case GuestSide.keluarga:
        return 'Keluarga';
    }
  }

  String _statusLabel(GuestStatus status) {
    switch (status) {
      case GuestStatus.belumDiundang:
        return 'Belum Diundang';
      case GuestStatus.diundang:
        return 'Diundang';
      case GuestStatus.konfirmasi:
        return 'Konfirmasi';
      case GuestStatus.hadir:
        return 'Hadir';
    }
  }

  Color _statusColor(GuestStatus status) {
    switch (status) {
      case GuestStatus.belumDiundang:
        return Colors.grey.shade200;
      case GuestStatus.diundang:
        return Colors.orange.shade100;
      case GuestStatus.konfirmasi:
        return Colors.green.shade100;
      case GuestStatus.hadir:
        return Colors.green.shade200;
    }
  }
}

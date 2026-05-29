import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/neo_button.dart';
import '../../../core/widgets/neo_card.dart';
import '../../../data/models/vendor.dart';
import '../../../domain/blocs/vendor/vendor_bloc.dart';
import 'vendor_form_screen.dart';

/// Vendor list screen displaying all vendors with details.
///
/// Shows name, category, phone, email, cost (formatted as currency), and status.
/// Provides add and delete functionality with confirmation dialog.
/// Requirements: 8.1, 8.3, 8.6
class VendorScreen extends StatefulWidget {
  const VendorScreen({super.key});

  @override
  State<VendorScreen> createState() => _VendorScreenState();
}

class _VendorScreenState extends State<VendorScreen> {
  final _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    context.read<VendorBloc>().add(const LoadVendors());
  }

  Future<void> _onRefresh() async {
    final bloc = context.read<VendorBloc>();
    bloc.add(const LoadVendors());
    await bloc.stream.firstWhere(
      (state) => state is! VendorLoading,
    );
  }

  void _navigateToAddVendor() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const VendorFormScreen()),
    );
  }

  void _showDeleteConfirmation(Vendor vendor) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTheme.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          side: const BorderSide(
              color: AppTheme.black, width: AppTheme.borderWidth),
        ),
        title: const Text('Hapus Vendor', style: AppTypography.h4),
        content: Text(
          'Apakah Anda yakin ingin menghapus "${vendor.name}" dari daftar vendor?',
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
              context.read<VendorBloc>().add(DeleteVendor(id: vendor.id));
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
        title: const Text('Daftar Vendor', style: AppTypography.h3),
        backgroundColor: AppTheme.white,
        elevation: 0,
      ),
      body: BlocConsumer<VendorBloc, VendorState>(
        listener: (context, state) {
          if (state is VendorError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red.shade700,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is VendorLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.pink),
            );
          }

          final vendors = _getVendors(state);

          return RefreshIndicator(
            color: AppTheme.pink,
            onRefresh: _onRefresh,
            child: vendors.isEmpty ? _buildEmptyState() : _buildVendorList(vendors),
          );
        },
      ),
      floatingActionButton: _buildAddButton(),
    );
  }

  List<Vendor> _getVendors(VendorState state) {
    if (state is VendorLoaded) return state.vendors;
    if (state is VendorError) return state.vendors;
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
              Icon(Icons.store_outlined, size: 64, color: AppTheme.lightPink),
              SizedBox(height: 16),
              Text('Belum ada vendor.', style: AppTypography.body),
              SizedBox(height: 8),
              Text(
                'Tap + untuk menambah vendor baru.',
                style: AppTypography.secondary,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVendorList(List<Vendor> vendors) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...vendors.map((vendor) => _buildVendorItem(vendor)),
          const SizedBox(height: 80), // Space for FAB
        ],
      ),
    );
  }

  /// Individual vendor item card showing name, category, phone, email, cost, status.
  /// Requirement 8.1
  Widget _buildVendorItem(Vendor vendor) {
    return NeoCard(
      backgroundColor: AppTheme.white,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  vendor.name,
                  style:
                      AppTypography.body.copyWith(fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                // Category and Status tags
                Row(
                  children: [
                    _buildTag(vendor.category, AppTheme.lightPink),
                    const SizedBox(width: 8),
                    _buildTag(vendor.status, Colors.green.shade100),
                  ],
                ),
                const SizedBox(height: 8),
                // Contact info
                if (vendor.phone != null && vendor.phone!.isNotEmpty)
                  _buildInfoRow(Icons.phone, vendor.phone!),
                if (vendor.email != null && vendor.email!.isNotEmpty)
                  _buildInfoRow(Icons.email_outlined, vendor.email!),
                // Cost
                _buildInfoRow(
                  Icons.attach_money,
                  _currencyFormat.format(vendor.cost),
                ),
              ],
            ),
          ),
          IconButton(
            icon:
                const Icon(Icons.delete_outline, color: Colors.red, size: 22),
            onPressed: () => _showDeleteConfirmation(vendor),
            tooltip: 'Hapus vendor',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppTheme.darkGray),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: AppTypography.secondary.copyWith(fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
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
        style:
            AppTypography.body.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _buildAddButton() {
    return NeoButton(
      onPressed: _navigateToAddVendor,
      label: '+',
      padding: const EdgeInsets.all(16),
    );
  }
}

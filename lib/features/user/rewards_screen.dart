import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../models/redeemed_voucher.dart';
import 'user_provider.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({super.key});

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  int _activeTab = 0; // 0 for Redemption, 1 for Reward History

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProvider>();
    final coupons = provider.availableCoupons;

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Rewards', style: Theme.of(context).textTheme.headlineMedium),
                Chip(
                  backgroundColor: Colors.amber.withOpacity(0.2),
                  avatar: const Icon(Icons.star, color: Colors.amber, size: 20),
                  label: Text('${provider.totalPoints} pts', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTab = 0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _activeTab == 0
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Redemption',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _activeTab == 0 ? Colors.black : Colors.white60,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _activeTab = 1),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: _activeTab == 1
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Reward History',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: _activeTab == 1 ? Colors.black : Colors.white60,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) {
                return FadeTransition(opacity: animation, child: child);
              },
              child: _activeTab == 0
                  ? Column(
                      key: const ValueKey<int>(0),
                      children: [
                        const AnimatedEntrance(
                          delayMs: 100,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: _GenerateVoucherCard(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.68,
                            ),
                            itemCount: coupons.length,
                            itemBuilder: (context, index) {
                              final coupon = coupons[index];
                              IconData icon;
                              switch (coupon.iconType) {
                                case 'property':
                                  icon = Icons.home_work_rounded;
                                  break;
                                case 'electricity':
                                  icon = Icons.bolt_rounded;
                                  break;
                                case 'water':
                                  icon = Icons.water_drop_rounded;
                                  break;
                                case 'stars':
                                default:
                                  icon = Icons.stars_rounded;
                              }

                              final canRedeem = provider.totalPoints >= coupon.pointsRequired;

                              return AnimatedEntrance(
                                delayMs: 200 + (index * 100).clamp(0, 500),
                                child: Card(
                                  elevation: 4,
                                  shadowColor: Colors.black.withOpacity(0.5),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        CircleAvatar(
                                          radius: 24,
                                          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                          child: Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
                                        ),
                                        Text(
                                          coupon.title,
                                          textAlign: TextAlign.center,
                                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          '${coupon.pointsRequired} pts',
                                          style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                                        ),
                                        ElevatedButton(
                                          onPressed: canRedeem
                                              ? () async {
                                                  final code = await provider.redeemCoupon(coupon);
                                                  if (code != null && context.mounted) {
                                                    showDialog(
                                                      context: context,
                                                      barrierDismissible: false,
                                                      builder: (context) => _RedemptionSuccessDialog(
                                                        couponTitle: coupon.title,
                                                        code: code,
                                                      ),
                                                    );
                                                  }
                                                }
                                              : null,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: canRedeem ? Theme.of(context).colorScheme.primary : Colors.white.withOpacity(0.05),
                                            foregroundColor: canRedeem ? Colors.black : Colors.white24,
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            minimumSize: const Size(double.infinity, 36),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                          ),
                                          child: const Text(
                                            'REDEEM',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w900,
                                              fontStyle: FontStyle.italic,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    )
                  : provider.myVouchers.isEmpty
                      ? const Center(
                          key: ValueKey<int>(1),
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.history_toggle_off_rounded, size: 54, color: Colors.white24),
                                SizedBox(height: 12),
                                Text(
                                  'No Vouchers Redeemed',
                                  style: TextStyle(color: Colors.white60, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Redeem points to pay your utility bills.',
                                  style: TextStyle(color: Colors.white38, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.builder(
                          key: const ValueKey<int>(2),
                          padding: const EdgeInsets.only(top: 8, bottom: 24),
                          itemCount: provider.myVouchers.length,
                          itemBuilder: (context, index) {
                            final voucher = provider.myVouchers[index];
                            IconData typeIcon = Icons.confirmation_number_rounded;
                            Gradient cardGradient = const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Color(0xFF1F2937), Color(0xFF111827)],
                            );

                            if (voucher.billType != null) {
                              if (voucher.billType!.contains('property')) {
                                typeIcon = Icons.home_work_rounded;
                                cardGradient = const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFF312E81), Color(0xFF1E1B4B)],
                                );
                              } else if (voucher.billType!.contains('electricity')) {
                                typeIcon = Icons.bolt_rounded;
                                cardGradient = const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFF78350F), Color(0xFF451A03)],
                                );
                              } else if (voucher.billType!.contains('water')) {
                                typeIcon = Icons.water_drop_rounded;
                                cardGradient = const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFF065F46), Color(0xFF022C22)],
                                );
                              }
                            }

                            return AnimatedEntrance(
                              delayMs: (index * 80).clamp(0, 400),
                              child: GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => _VoucherDetailDialog(
                                      voucher: voucher,
                                      typeIcon: typeIcon,
                                      cardGradient: cardGradient,
                                    ),
                                  );
                                },
                                child: Container(
                                  height: 110,
                                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    gradient: cardGradient,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: Colors.white.withOpacity(0.15)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 12,
                                                    backgroundColor: Colors.white.withOpacity(0.2),
                                                    child: Icon(typeIcon, size: 14, color: Colors.white),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    voucher.billType != null
                                                        ? voucher.billType!.replaceAll('_', ' ').toUpperCase()
                                                        : 'VOUCHER',
                                                    style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 9,
                                                      fontWeight: FontWeight.bold,
                                                      letterSpacing: 1,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                voucher.title,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              if (voucher.consumerNumber != null)
                                                Text(
                                                  'ID: ${voucher.consumerNumber}',
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    color: Colors.white.withOpacity(0.6),
                                                    fontSize: 10,
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: List.generate(
                                          5,
                                          (_) => Container(
                                            margin: const EdgeInsets.symmetric(vertical: 2),
                                            width: 1.5,
                                            height: 4,
                                            color: Colors.white24,
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: 95,
                                        padding: const EdgeInsets.all(10),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              voucher.code,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontFamily: 'monospace',
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withOpacity(0.15),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: const Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.qr_code_2_rounded, size: 12, color: Colors.white),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    'VIEW',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 8,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ],
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
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GenerateVoucherCard extends StatefulWidget {
  const _GenerateVoucherCard();

  @override
  State<_GenerateVoucherCard> createState() => _GenerateVoucherCardState();
}

class _GenerateVoucherCardState extends State<_GenerateVoucherCard> {
  final TextEditingController _pointsController = TextEditingController();
  final TextEditingController _consumerController = TextEditingController();
  final TextEditingController _providerController = TextEditingController();
  String _selectedBillType = 'property_tax';
  String? _selectedMunicipalBoard;
  double _convertedValue = 0.0;
  bool _isGenerating = false;
  bool _isExpanded = false; // Collapsed by default

  @override
  void initState() {
    super.initState();
    _pointsController.addListener(_onPointsChanged);
  }

  void _onPointsChanged() {
    final points = int.tryParse(_pointsController.text) ?? 0;
    setState(() {
      _convertedValue = points / 10.0;
    });
  }

  @override
  void dispose() {
    _pointsController.removeListener(_onPointsChanged);
    _pointsController.dispose();
    _consumerController.dispose();
    _providerController.dispose();
    super.dispose();
  }

  String _getConsumerLabel() {
    if (_selectedBillType == 'property_tax') return 'Property Assessment ID';
    if (_selectedBillType == 'electricity_bill') return 'Consumer Account ID';
    return 'Water Connection Number';
  }

  String _getConsumerHint() {
    if (_selectedBillType == 'property_tax') return 'e.g. PROP-987452';
    if (_selectedBillType == 'electricity_bill') return 'e.g. 102938475';
    return 'e.g. WAT-002938';
  }

  String _getProviderLabel() {
    if (_selectedBillType == 'property_tax') return 'Municipal Corporation';
    if (_selectedBillType == 'electricity_bill') return 'Electricity Board';
    return 'Water Board';
  }

  String _getProviderHint() {
    if (_selectedBillType == 'property_tax') return 'e.g. BMC, PMC, NMC';
    if (_selectedBillType == 'electricity_bill') return 'e.g. MSEDCL, TATA POWER';
    return 'e.g. DJB, MCGM';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<UserProvider>();
    final primaryColor = Theme.of(context).colorScheme.primary; 
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: surfaceColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: primaryColor.withOpacity(0.1)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1), 
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.receipt_long_rounded, color: primaryColor, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pay Utility Bills',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const Text(
                          'Convert points to tax & bill credit',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white60,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: primaryColor,
                  ),
                ],
              ),
            ),
            if (_isExpanded) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedBillType,
                isExpanded: true,
                dropdownColor: const Color(0xFF1E1E1E),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                decoration: InputDecoration(
                  labelText: 'Select utility/tax type',
                  labelStyle: TextStyle(color: primaryColor.withOpacity(0.8), fontSize: 10, fontWeight: FontWeight.bold),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.3),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                  ),
                ),
                items: const [
                  DropdownMenuItem(value: 'property_tax', child: Text('🏠 Property Tax Rebate')),
                  DropdownMenuItem(value: 'electricity_bill', child: Text('⚡ Electricity Bill Discount')),
                  DropdownMenuItem(value: 'water_bill', child: Text('💧 Water Tax/Bill Discount')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedBillType = val;
                      _providerController.clear();
                      _selectedMunicipalBoard = null;
                    });
                  }
                },
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _pointsController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: 'Points to redeem (min. 100)',
                        labelStyle: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                        hintText: 'Points',
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12, fontWeight: FontWeight.bold),
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.3),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        suffixText: _convertedValue > 0 ? '₹${_convertedValue.toStringAsFixed(2)}' : null,
                        suffixStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(0.0, 0.1),
                        end: Offset.zero,
                      ).animate(animation),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  key: ValueKey<String>(_selectedBillType),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _consumerController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: _getConsumerLabel(),
                        labelStyle: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                        hintText: _getConsumerHint(),
                        hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12),
                        filled: true,
                        fillColor: Colors.black.withOpacity(0.3),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _selectedBillType == 'property_tax'
                        ? DropdownButtonFormField<String>(
                            key: const ValueKey<String>('municipal_dropdown'),
                            value: _selectedMunicipalBoard,
                            isExpanded: true,
                            dropdownColor: const Color(0xFF1E1E1E),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            decoration: InputDecoration(
                              labelText: 'Select Municipal Corporation',
                              labelStyle: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                              filled: true,
                              fillColor: Colors.black.withOpacity(0.3),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'NMC', child: Text('Nashik Municipal Corporation (NMC)')),
                              DropdownMenuItem(value: 'BMC', child: Text('Brihanmumbai Municipal Corporation (BMC)')),
                              DropdownMenuItem(value: 'PMC', child: Text('Pune Municipal Corporation (PMC)')),
                              DropdownMenuItem(value: 'TMC', child: Text('Thane Municipal Corporation (TMC)')),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedMunicipalBoard = val;
                                  _providerController.text = val;
                                });
                              }
                            },
                          )
                        : TextField(
                            key: const ValueKey<String>('provider_textfield'),
                            controller: _providerController,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: _getProviderLabel(),
                              labelStyle: const TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold),
                              hintText: _getProviderHint(),
                              hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 12),
                              filled: true,
                              fillColor: Colors.black.withOpacity(0.3),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(color: Colors.white.withOpacity(0.05)),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isGenerating ? null : _handleGenerate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isGenerating
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2))
                      : const Text(
                          'Apply Redemption',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _handleGenerate() async {
    final pointsStr = _pointsController.text;
    final points = int.tryParse(pointsStr);
    final consumerVal = _consumerController.text.trim();
    final providerVal = _providerController.text.trim();
    final provider = context.read<UserProvider>();

    if (points == null || points < 100) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimum 100 points required.')),
      );
      return;
    }

    if (provider.totalPoints < points) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Insufficient points.')),
      );
      return;
    }

    if (consumerVal.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your ${_getConsumerLabel().toLowerCase()}.')),
      );
      return;
    }

    if (providerVal.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter your ${_getProviderLabel().toLowerCase()}.')),
      );
      return;
    }

    setState(() => _isGenerating = true);
    final code = await provider.generateCustomVoucher(
      points,
      billType: _selectedBillType,
      consumerNumber: consumerVal,
      providerName: providerVal,
    );
    setState(() => _isGenerating = false);

    if (code != null && mounted) {
      _pointsController.clear();
      _consumerController.clear();
      _providerController.clear();
      
      final typeLabel = _selectedBillType.replaceAll('_', ' ');
      final formattedLabel = typeLabel[0].toUpperCase() + typeLabel.substring(1);
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => _RedemptionSuccessDialog(
          couponTitle: '₹${(points / 10).toStringAsFixed(2)} $formattedLabel',
          code: code,
          detailText: 'Applied to Acc# $consumerVal ($providerVal)',
        ),
      );
    }
  }
}

class _RedemptionSuccessDialog extends StatelessWidget {
  final String couponTitle;
  final String code;
  final String? detailText;

  const _RedemptionSuccessDialog({
    required this.couponTitle,
    required this.code,
    this.detailText,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A1A1A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFCCFF00),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_rounded, color: Colors.black, size: 40),
            ),
            const SizedBox(height: 24),
            Text(
              'Redeemed!',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 24,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              couponTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
            ),
            if (detailText != null) ...[
              const SizedBox(height: 6),
              Text(
                detailText!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ],
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFCCFF00).withOpacity(0.3), width: 2),
                borderRadius: BorderRadius.circular(12),
                color: Colors.black,
              ),
              child: Column(
                children: [
                  const Text('Transaction Reference Code', style: TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Text(
                    code,
                    style: const TextStyle(
                      color: Color(0xFFCCFF00),
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Transaction code copied!')),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFCCFF00),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Copy & Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VoucherDetailDialog extends StatelessWidget {
  final RedeemedVoucher voucher;
  final IconData typeIcon;
  final Gradient cardGradient;

  const _VoucherDetailDialog({
    required this.voucher,
    required this.typeIcon,
    required this.cardGradient,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Center(
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 340),
          decoration: BoxDecoration(
            gradient: cardGradient,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.6),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header section
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Colors.white.withOpacity(0.15),
                      child: Icon(typeIcon, color: Colors.white, size: 30),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      voucher.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      voucher.billType != null
                          ? voucher.billType!.replaceAll('_', ' ').toUpperCase()
                          : 'REWARD VOUCHER',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Dashed divider line with side cutout notches
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFF030712), // Background slate color
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(12),
                        bottomRight: Radius.circular(12),
                      ),
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Flex(
                          direction: Axis.horizontal,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(
                            (constraints.constrainWidth() / 10).floor(),
                            (_) => const SizedBox(
                              width: 5,
                              height: 1,
                              child: DecoratedBox(
                                decoration: BoxDecoration(color: Colors.white24),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    width: 12,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Color(0xFF030712), // Background slate color
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        bottomLeft: Radius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
              
              // Code and copy area
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 20.0),
                child: Column(
                  children: [
                    const Text(
                      'TRANSACTION REFERENCE CODE',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: voucher.code));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Voucher code copied to clipboard!')),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withOpacity(0.1)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              voucher.code,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'monospace',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.copy, color: Colors.white54, size: 16),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // Barcode illustration
                    Container(
                      height: 44,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(
                          26,
                          (index) => Container(
                            width: (index % 3 == 0) ? 3.0 : (index % 5 == 0) ? 1.0 : 2.0,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    if (voucher.consumerNumber != null)
                      _buildDetailRow('Consumer ID', voucher.consumerNumber!),
                    if (voucher.providerName != null)
                      _buildDetailRow('Provider', voucher.providerName!),
                    _buildDetailRow('Redeemed On', DateFormat.yMMMd().format(DateTime.now())),
                    
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text('Close Voucher', style: TextStyle(fontWeight: FontWeight.bold)),
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
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedEntrance extends StatefulWidget {
  final Widget child;
  final int delayMs;

  const AnimatedEntrance({
    super.key,
    required this.child,
    required this.delayMs,
  });

  @override
  State<AnimatedEntrance> createState() => _AnimatedEntranceState();
}

class _AnimatedEntranceState extends State<AnimatedEntrance> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

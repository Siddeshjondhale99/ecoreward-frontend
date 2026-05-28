import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'user_provider.dart';

class RewardsScreen extends StatelessWidget {
  const RewardsScreen({super.key});

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
          if (provider.myVouchers.isNotEmpty) ...[
            AnimatedEntrance(
              delayMs: 0,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Your Utility Payments & Vouchers',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.5,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            AnimatedEntrance(
              delayMs: 100,
              child: SizedBox(
                height: 130,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: provider.myVouchers.length,
                  itemBuilder: (context, index) {
                    final voucher = provider.myVouchers[index];
                    IconData typeIcon = Icons.confirmation_number_rounded;
                    if (voucher.billType != null) {
                      if (voucher.billType!.contains('property')) {
                        typeIcon = Icons.home_work_rounded;
                      } else if (voucher.billType!.contains('electricity')) {
                        typeIcon = Icons.bolt_rounded;
                      } else if (voucher.billType!.contains('water')) {
                        typeIcon = Icons.water_drop_rounded;
                      }
                    }
                    return Container(
                      width: 220,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(typeIcon, size: 16, color: Theme.of(context).colorScheme.primary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  voucher.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            voucher.code,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          if (voucher.consumerNumber != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Consumer ID: ${voucher.consumerNumber}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 10),
                            ),
                          ],
                          const Spacer(),
                          InkWell(
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Voucher code copied!')),
                              );
                            },
                            child: Row(
                              children: [
                                Icon(Icons.copy, size: 12, color: Theme.of(context).colorScheme.primary),
                                const SizedBox(width: 4),
                                const Text('Copy Code', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
          const AnimatedEntrance(
            delayMs: 200,
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
                  delayMs: 300 + (index * 100).clamp(0, 600),
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

    return Container(
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
          Row(
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
                    Text(
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
            ],
          ),
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

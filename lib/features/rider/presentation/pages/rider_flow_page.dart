import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../application/rider_flow_controller.dart';
import '../../application/rider_flow_state.dart';
import '../../domain/rider_stage.dart';

const _cobalt = AppColors.primary;
const _ink = AppColors.ink;
const _slate = AppColors.slate;
const _muted = AppColors.muted;
const _line = AppColors.border;
const _soft = AppColors.surfaceSubtle;
const _periwinkle = AppColors.primarySubtle;
const _green = AppColors.success;

class RiderFlow extends ConsumerStatefulWidget {
  const RiderFlow({super.key});

  @override
  ConsumerState<RiderFlow> createState() => _RiderFlowState();
}

class _RiderFlowState extends ConsumerState<RiderFlow> {
  final _phoneController = TextEditingController(text: '12 345 6789');
  final _destinationController = TextEditingController(text: 'KL Sentral');

  RiderFlowController get _controller =>
      ref.read(riderFlowControllerProvider.notifier);
  RiderFlowState get _flow => ref.read(riderFlowControllerProvider);
  String get _otp => _flow.otp;
  String get _selectedRide => _flow.selectedRide;
  String get _payment => _flow.paymentMethod;
  int get _rating => _flow.rating;
  int get _tip => _flow.tip;
  bool get _shared => _flow.tripShared;

  @override
  void dispose() {
    _phoneController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  void _go(RiderStage next, {bool remember = true}) {
    _controller.go(next, remember: remember);
  }

  void _back() => _controller.back();

  void _startMatching() => _controller.startMatching();

  @override
  Widget build(BuildContext context) {
    final stage = ref.watch(riderFlowControllerProvider).stage;
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: KeyedSubtree(key: ValueKey(stage), child: _screenForStage(stage)),
    );
  }

  Widget _screenForStage(RiderStage stage) {
    return switch (stage) {
      RiderStage.signIn => _signInScreen(),
      RiderStage.otp => _otpScreen(invalid: false),
      RiderStage.invalidOtp => _otpScreen(invalid: true),
      RiderStage.permission => _permissionScreen(),
      RiderStage.home => _homeScreen(),
      RiderStage.destination => _destinationScreen(),
      RiderStage.pickup => _pickupScreen(),
      RiderStage.ride => _rideScreen(),
      RiderStage.payment => _paymentScreen(),
      RiderStage.confirm => _confirmScreen(),
      RiderStage.searching => _searchingScreen(),
      RiderStage.noDriver => _noDriverScreen(),
      RiderStage.matched => _matchedScreen(),
      RiderStage.approaching => _approachingScreen(),
      RiderStage.driverArrived => _driverArrivedScreen(),
      RiderStage.inTrip => _inTripScreen(),
      RiderStage.safety => _safetyScreen(),
      RiderStage.share => _shareScreen(),
      RiderStage.cancelReasons => _cancelReasonsScreen(),
      RiderStage.cancellationPolicy => _cancellationPolicyScreen(),
      RiderStage.completed => _completedScreen(),
      RiderStage.history => _historyScreen(),
      RiderStage.reconnect => _reconnectScreen(),
    };
  }

  Widget _signInScreen() {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [SwiftRideLogo(), _StepChip('01/23')],
              ),
              const SizedBox(height: 48),
              Text('Ready when\nyou are.', style: _headline(38, height: .98)),
              const SizedBox(height: 14),
              const Text(
                'Book a reliable ride in less than a minute.',
                style: TextStyle(color: _muted, fontSize: 13),
              ),
              const SizedBox(height: 44),
              const _FieldLabel('MOBILE NUMBER'),
              const SizedBox(height: 8),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  prefixIcon: _CountryCode(),
                  hintText: '12 345 6789',
                ),
              ),
              const SizedBox(height: 14),
              PrimaryButton(
                label: 'Send verification code',
                icon: Icons.arrow_forward,
                onPressed: () => _go(RiderStage.otp),
              ),
              const SizedBox(height: 24),
              const _OrDivider(),
              const SizedBox(height: 18),
              ProviderButton(
                label: 'Continue with Google',
                logo: const GoogleMark(),
                onPressed: () => _go(RiderStage.permission),
              ),
              const SizedBox(height: 10),
              ProviderButton(
                label: 'Continue with Apple',
                logo: const Icon(Icons.apple, size: 21, color: _ink),
                onPressed: () => _go(RiderStage.permission),
              ),
              const SizedBox(height: 24),
              Center(
                child: TextButton(
                  onPressed: () {},
                  child: const Text('Need help?  Visit support'),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'By continuing, you agree to SwiftRide’s Terms and Privacy Policy.',
                textAlign: TextAlign.center,
                style: TextStyle(color: _muted, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _otpScreen({required bool invalid}) {
    return _Page(
      title: invalid ? 'That code didn’t work' : 'Check your messages',
      step: invalid ? '03/23' : '02/23',
      onBack: _back,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            invalid
                ? 'Try again or request a new verification code.'
                : 'Enter the 6-digit code sent to +60 12 345 6789.',
            style: const TextStyle(color: _muted, fontSize: 13, height: 1.45),
          ),
          const SizedBox(height: 28),
          Row(
            children: List.generate(6, (index) {
              final value = index < _otp.length ? _otp[index] : '—';
              return Expanded(
                child: Container(
                  height: 58,
                  margin: EdgeInsets.only(right: index == 5 ? 0 : 7),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: invalid ? const Color(0xFFFFF4F1) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: invalid ? const Color(0xFFD65C45) : _line,
                    ),
                  ),
                  child: Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: value == '—' ? const Color(0xFFB2B8C6) : _ink,
                    ),
                  ),
                ),
              );
            }),
          ),
          if (invalid) ...[
            const SizedBox(height: 12),
            const Row(
              children: [
                Icon(Icons.error_outline, color: Color(0xFFD65C45), size: 17),
                SizedBox(width: 7),
                Text(
                  'Invalid or expired code',
                  style: TextStyle(color: Color(0xFFD65C45), fontSize: 12),
                ),
              ],
            ),
          ],
          const SizedBox(height: 24),
          _NumberPad(
            onDigit: (digit) {
              _controller.appendOtp(digit);
            },
            onDelete: () {
              _controller.deleteOtpDigit();
            },
          ),
          const Spacer(),
          PrimaryButton(
            label: 'Verify and continue',
            onPressed: () {
              if (_otp == '000000') {
                _go(RiderStage.invalidOtp);
              } else {
                _go(RiderStage.permission);
              }
            },
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: () => _controller.setOtp(''),
              child: const Text('Resend code in 00:24'),
            ),
          ),
          Center(
            child: TextButton(
              onPressed: () {
                _controller.setOtp('000000');
                _go(RiderStage.invalidOtp);
              },
              child: const Text(
                'Preview invalid-code state',
                style: TextStyle(fontSize: 11, color: _muted),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _permissionScreen() {
    return _Page(
      title: 'Enable location',
      step: '04/23',
      child: Column(
        children: [
          const SizedBox(height: 28),
          Container(
            width: 154,
            height: 154,
            decoration: BoxDecoration(
              color: _periwinkle,
              borderRadius: BorderRadius.circular(38),
            ),
            child: const Center(child: _MapPermissionIcon()),
          ),
          const SizedBox(height: 30),
          Text('Find rides around you', style: _title(20)),
          const SizedBox(height: 10),
          const Text(
            'We use your location to set accurate pickup points, show nearby drivers and calculate your fare.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 28),
          const _PermissionBenefit(
            Icons.my_location_rounded,
            'Accurate pickup location',
          ),
          const _PermissionBenefit(
            Icons.local_taxi_outlined,
            'Nearby driver availability',
          ),
          const _PermissionBenefit(Icons.route_outlined, 'Live route and ETA'),
          const Spacer(),
          PrimaryButton(
            label: 'Allow location access',
            onPressed: () => _go(RiderStage.home),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => _go(RiderStage.home),
            child: const Text('Not now'),
          ),
        ],
      ),
    );
  }

  Widget _homeScreen() {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: MapCanvas(showRoute: false)),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: _floatingDecoration(),
                        child: const Row(
                          children: [
                            SwiftRideMark(size: 28),
                            SizedBox(width: 9),
                            Text(
                              'Good morning, Saimon',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _CircleButton(
                        icon: Icons.person_outline,
                        onTap: () => _go(RiderStage.history),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () => _go(RiderStage.destination),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 15,
                      ),
                      decoration: _floatingDecoration(),
                      child: const Row(
                        children: [
                          Icon(Icons.search_rounded, color: _ink),
                          SizedBox(width: 12),
                          Text(
                            'Where to?',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Spacer(),
                          Icon(Icons.arrow_forward, color: _cobalt, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x1F17233B),
                          blurRadius: 24,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Quick places',
                          style: TextStyle(
                            fontSize: 12,
                            color: _muted,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: _SavedPlace(
                                icon: Icons.home_outlined,
                                title: 'Home',
                                subtitle: 'Taman Melati',
                                onTap: () => _go(RiderStage.pickup),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _SavedPlace(
                                icon: Icons.business_outlined,
                                title: 'Work',
                                subtitle: 'KL Sentral',
                                onTap: () => _go(RiderStage.pickup),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: () => _go(RiderStage.reconnect),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.gps_not_fixed,
                                size: 17,
                                color: _muted,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Location and connection status',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(fontSize: 11, color: _muted),
                                ),
                              ),
                              Icon(
                                Icons.chevron_right,
                                size: 18,
                                color: _muted,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  _BottomNav(onHistory: () => _go(RiderStage.history)),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _destinationScreen() {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: MapCanvas(showRoute: false)),
          SafeArea(
            child: Column(
              children: [
                _MapTopBar(title: 'Where to?', onBack: _back),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                    decoration: _floatingDecoration(radius: 20),
                    child: Column(
                      children: [
                        const _LocationField(
                          color: _ink,
                          label: 'Pickup',
                          value: 'Jalan Ampang, KLCC',
                        ),
                        const Padding(
                          padding: EdgeInsets.only(left: 5),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: SizedBox(
                              height: 18,
                              child: VerticalDivider(
                                width: 2,
                                thickness: 2,
                                color: Color(0xFFC8CEE0),
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(Icons.circle, size: 11, color: _cobalt),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: _destinationController,
                                autofocus: true,
                                textInputAction: TextInputAction.go,
                                onSubmitted: (_) => _go(RiderStage.pickup),
                                decoration: const InputDecoration(
                                  isDense: true,
                                  filled: false,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  labelText: 'Destination',
                                  hintText: 'Type a destination',
                                  contentPadding: EdgeInsets.zero,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: _destinationController.clear,
                              icon: const Icon(Icons.close, size: 18),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: SecondaryButton(
                    label: 'Choose destination on map',
                    icon: Icons.location_on_outlined,
                    onPressed: () => _go(RiderStage.pickup),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _pickupScreen() {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: MapCanvas(showRoute: false, pickupCentered: true),
          ),
          SafeArea(
            child: _MapTopBar(title: 'Confirm pickup', onBack: _back),
          ),
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 42),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_pin, color: _cobalt, size: 48),
                  SizedBox(height: 4),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Text(
                        'Move the map to adjust pickup',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomSheetSurface(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pickup at Jalan Ampang', style: _title(18)),
                  const SizedBox(height: 8),
                  const Text(
                    'Main lobby · KLCC',
                    style: TextStyle(color: _muted, fontSize: 12),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Confirm pickup',
                    onPressed: () => _go(RiderStage.ride),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _rideScreen() {
    final rides = const [
      (
        'SwiftGo',
        '4 seats · 3 min',
        'RM 15.80',
        'Best value',
        Icons.directions_car_filled_outlined,
      ),
      (
        'SwiftPlus',
        'Newer cars · 5 min',
        'RM 21.40',
        'Comfort',
        Icons.local_taxi_outlined,
      ),
      (
        'SwiftXL',
        '6 seats · 7 min',
        'RM 28.60',
        'More room',
        Icons.airport_shuttle_outlined,
      ),
    ];
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: MapCanvas(showRoute: true)),
          SafeArea(
            child: _MapTopBar(title: 'Choose your ride', onBack: _back),
          ),
          Positioned(
            top: 116,
            left: 18,
            right: 18,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
              decoration: _floatingDecoration(),
              child: const Row(
                children: [
                  Text(
                    '18 min',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '6.8 km · Jalan Ampang → KL Sentral',
                      style: TextStyle(fontSize: 10, color: _muted),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomSheetSurface(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text('Choose a ride', style: _title(18))),
                      const Text(
                        '3 options nearby',
                        style: TextStyle(color: _muted, fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...rides.map(
                    (ride) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: _RideOption(
                        title: ride.$1,
                        meta: ride.$2,
                        price: ride.$3,
                        tag: ride.$4,
                        icon: ride.$5,
                        selected: _selectedRide == ride.$1,
                        onTap: () => _controller.selectRide(ride.$1),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => _go(RiderStage.payment),
                    borderRadius: BorderRadius.circular(13),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: _soft,
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.credit_card,
                            size: 18,
                            color: _slate,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _payment,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.keyboard_arrow_down,
                            size: 19,
                            color: _muted,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'Continue with $_selectedRide',
                    onPressed: () => _go(RiderStage.confirm),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _paymentScreen() {
    return _Page(
      title: 'Payment method',
      step: '09/23',
      onBack: _back,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Choose how you would like to pay for this ride.',
            style: TextStyle(color: _muted, fontSize: 12),
          ),
          const SizedBox(height: 24),
          _PaymentOption(
            icon: Icons.credit_card,
            title: 'Visa •••• 4821',
            subtitle: 'Default card',
            selected: _payment.startsWith('Visa'),
            onTap: () => _controller.selectPayment('Visa •••• 4821'),
          ),
          _PaymentOption(
            icon: Icons.account_balance_wallet_outlined,
            title: 'SwiftWallet',
            subtitle: 'Balance RM 48.60',
            selected: _payment == 'SwiftWallet',
            onTap: () => _controller.selectPayment('SwiftWallet'),
          ),
          _PaymentOption(
            icon: Icons.payments_outlined,
            title: 'Cash',
            subtitle: 'Pay your driver after the trip',
            selected: _payment == 'Cash',
            onTap: () => _controller.selectPayment('Cash'),
          ),
          const SizedBox(height: 8),
          SecondaryButton(
            label: 'Add payment method',
            icon: Icons.add,
            onPressed: () {},
          ),
          const Spacer(),
          PrimaryButton(
            label: 'Use $_payment',
            onPressed: () => _go(RiderStage.confirm),
          ),
        ],
      ),
    );
  }

  Widget _confirmScreen() {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: MapCanvas(showRoute: true)),
          SafeArea(
            child: _MapTopBar(title: 'Confirm booking', onBack: _back),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomSheetSurface(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _RouteSummary(compact: true),
                  const SizedBox(height: 16),
                  _DropdownSummary(
                    icon: Icons.directions_car_outlined,
                    label: 'RIDE TYPE',
                    value: _selectedRide,
                    onTap: () => _go(RiderStage.ride),
                  ),
                  const SizedBox(height: 8),
                  _DropdownSummary(
                    icon: Icons.credit_card,
                    label: 'PAYMENT',
                    value: _payment,
                    onTap: () => _go(RiderStage.payment),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          label: 'Add promo',
                          icon: Icons.local_offer_outlined,
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SecondaryButton(
                          label: 'Driver note',
                          icon: Icons.chat_bubble_outline,
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children: [
                      Text(
                        'Upfront fare',
                        style: TextStyle(color: _muted, fontSize: 11),
                      ),
                      Spacer(),
                      Text(
                        'RM 15.80',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'Confirm and find a driver',
                    onPressed: _startMatching,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchingScreen() {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: MapCanvas(showRoute: true, searching: true),
          ),
          SafeArea(
            child: _MapTopBar(title: 'Finding you a driver', onBack: _back),
          ),
          const Center(child: _SearchingPulse()),
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomSheetSurface(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Finding the best match', style: _title(18)),
                  const SizedBox(height: 6),
                  const Text(
                    'Usually takes less than 2 minutes.',
                    style: TextStyle(color: _muted, fontSize: 11),
                  ),
                  const SizedBox(height: 16),
                  const LinearProgressIndicator(
                    minHeight: 5,
                    borderRadius: BorderRadius.all(Radius.circular(4)),
                  ),
                  const SizedBox(height: 16),
                  _DropdownSummary(
                    icon: Icons.directions_car_outlined,
                    label: _selectedRide,
                    value: 'RM 15.80 · $_payment',
                  ),
                  const SizedBox(height: 10),
                  SecondaryButton(
                    label: 'Cancel booking',
                    onPressed: () => _go(RiderStage.cancelReasons),
                  ),
                  Center(
                    child: TextButton(
                      onPressed: () => _go(RiderStage.noDriver),
                      child: const Text(
                        'Preview no-driver state',
                        style: TextStyle(color: _muted, fontSize: 10),
                      ),
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

  Widget _noDriverScreen() {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: MapCanvas(showRoute: true)),
          SafeArea(
            child: _MapTopBar(title: 'No driver found', onBack: _back),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomSheetSurface(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const _StateIcon(icon: Icons.car_crash_outlined),
                  const SizedBox(height: 14),
                  Text('Drivers are busy nearby', style: _title(20)),
                  const SizedBox(height: 8),
                  const Text(
                    'Try searching again or choose SwiftXL for a faster match.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _muted, fontSize: 12, height: 1.45),
                  ),
                  const SizedBox(height: 16),
                  _RideOption(
                    title: 'SwiftXL',
                    meta: '6 seats · 4 min',
                    price: 'RM 28.60',
                    tag: 'Available',
                    icon: Icons.airport_shuttle_outlined,
                    selected: false,
                    onTap: () => _controller.selectRide('SwiftXL'),
                  ),
                  const SizedBox(height: 12),
                  PrimaryButton(
                    label: 'Search again',
                    onPressed: _startMatching,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => _go(RiderStage.home),
                    child: const Text('Return home'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _matchedScreen() {
    return _DriverMapScreen(
      title: 'Aina is your driver',
      badge: 'MATCHED',
      headline: 'Arrives in 3 min',
      onBack: _back,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _DriverIdentity(),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: _soft,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              children: [
                Text(
                  'VCF 9421',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                  ),
                ),
                Spacer(),
                Icon(Icons.verified_user_outlined, size: 17, color: _cobalt),
                SizedBox(width: 6),
                Text(
                  'Check the plate',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _ActionRow(
            actions: [
              _Action(Icons.phone_outlined, 'Call', () {}),
              _Action(Icons.chat_bubble_outline, 'Message', () {}),
              _Action(
                Icons.shield_outlined,
                'Safety',
                () => _go(RiderStage.safety),
              ),
              _Action(Icons.more_horiz, 'More', () {}),
            ],
          ),
          const SizedBox(height: 14),
          PrimaryButton(
            label: 'Track Aina’s arrival',
            onPressed: () => _go(RiderStage.approaching),
          ),
        ],
      ),
    );
  }

  Widget _approachingScreen() {
    return _DriverMapScreen(
      title: 'Driver is approaching',
      badge: 'ON THE WAY',
      headline: '2 min away',
      onBack: _back,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aina · VCF 9421 · White Perodua Alza',
            style: TextStyle(color: _muted, fontSize: 11),
          ),
          const SizedBox(height: 14),
          const _InfoCard(
            label: 'MEET AT',
            value: 'Jalan Ampang · Main lobby',
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 10),
          const Text(
            'Free cancellation for 03:00',
            style: TextStyle(
              color: _green,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          _ActionRow(
            actions: [
              _Action(Icons.phone_outlined, 'Call', () {}),
              _Action(Icons.chat_bubble_outline, 'Message', () {}),
              _Action(
                Icons.shield_outlined,
                'Safety',
                () => _go(RiderStage.safety),
              ),
              _Action(
                Icons.close,
                'Cancel',
                () => _go(RiderStage.cancelReasons),
              ),
            ],
          ),
          const SizedBox(height: 14),
          PrimaryButton(
            label: 'Simulate driver arrival',
            onPressed: () => _go(RiderStage.driverArrived),
          ),
        ],
      ),
    );
  }

  Widget _driverArrivedScreen() {
    return _DriverMapScreen(
      title: 'Your driver has arrived',
      badge: 'ARRIVED',
      headline: 'Waiting 02:18',
      onBack: _back,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Meet Aina at the main lobby', style: _title(17)),
          const SizedBox(height: 5),
          const Text(
            'VCF 9421 · White Perodua Alza',
            style: TextStyle(color: _muted, fontSize: 11),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _periwinkle,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PICKUP CODE',
                  style: TextStyle(
                    fontSize: 9,
                    color: _muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 7),
                Center(
                  child: Text(
                    '7   2   4   9',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Only share after checking the car and plate.',
                  style: TextStyle(fontSize: 9, color: _muted),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _ActionRow(
            actions: [
              _Action(Icons.phone_outlined, 'Call', () {}),
              _Action(Icons.chat_bubble_outline, 'Message', () {}),
              _Action(
                Icons.shield_outlined,
                'Safety',
                () => _go(RiderStage.safety),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'WAITING FEE MAY APPLY AFTER 5 MIN',
            style: TextStyle(
              fontSize: 9,
              color: _muted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: 'Start demo trip',
            onPressed: () => _go(RiderStage.inTrip),
          ),
        ],
      ),
    );
  }

  Widget _inTripScreen() {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(
            child: MapCanvas(showRoute: true, inTrip: true),
          ),
          SafeArea(
            child: _MapTopBar(
              title: 'On your way',
              onBack: _back,
              trailing: const _StatusPill('IN TRIP'),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomSheetSurface(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('14 min', style: _headline(28)),
                      const SizedBox(width: 8),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: Text(
                          'remaining · 5.1 km',
                          style: TextStyle(color: _muted, fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const LinearProgressIndicator(
                    value: .32,
                    minHeight: 6,
                    borderRadius: BorderRadius.all(Radius.circular(6)),
                  ),
                  const SizedBox(height: 16),
                  const _InfoCard(
                    label: 'DESTINATION',
                    value: 'KL Sentral · Brickfields',
                    icon: Icons.flag_outlined,
                  ),
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      Text(
                        'Fare',
                        style: TextStyle(color: _muted, fontSize: 10),
                      ),
                      SizedBox(width: 6),
                      Text(
                        'RM 15.80',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                      Spacer(),
                      Text(
                        'Visa •••• 4821',
                        style: TextStyle(color: _muted, fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  _ActionRow(
                    actions: [
                      _Action(
                        Icons.ios_share_outlined,
                        'Share',
                        () => _go(RiderStage.share),
                      ),
                      _Action(
                        Icons.shield_outlined,
                        'Safety',
                        () => _go(RiderStage.safety),
                      ),
                      _Action(Icons.phone_outlined, 'Driver', () {}),
                      _Action(Icons.help_outline, 'Help', () {}),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: SecondaryButton(
                          label: 'Report route',
                          icon: Icons.alt_route,
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: PrimaryButton(
                          label: 'Arrive',
                          onPressed: () => _go(RiderStage.completed),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _safetyScreen() {
    return _Page(
      title: 'Safety centre',
      step: '18/23',
      onBack: _back,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _slate,
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Row(
              children: [
                Icon(Icons.shield_outlined, color: Colors.white, size: 32),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Your ride is being monitored for unexpected route or stop changes.',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      height: 1.45,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _SafetyTile(
            icon: Icons.ios_share_outlined,
            title: 'Share trip status',
            subtitle: 'Send route, driver and ETA to trusted contacts',
            onTap: () => _go(RiderStage.share),
          ),
          _SafetyTile(
            icon: Icons.emergency_outlined,
            title: 'Emergency assistance',
            subtitle: 'Contact emergency services and share your location',
            danger: true,
            onTap: () {},
          ),
          _SafetyTile(
            icon: Icons.mic_none_outlined,
            title: 'Audio recording',
            subtitle: 'Securely record audio during your ride',
            onTap: () {},
          ),
          _SafetyTile(
            icon: Icons.report_outlined,
            title: 'Report a safety issue',
            subtitle: 'Tell SwiftRide about a concern',
            onTap: () {},
          ),
          _SafetyTile(
            icon: Icons.verified_user_outlined,
            title: 'Ride protection',
            subtitle: 'View insurance and support information',
            onTap: () {},
          ),
          const Spacer(),
          PrimaryButton(label: 'Close safety centre', onPressed: _back),
        ],
      ),
    );
  }

  Widget _shareScreen() {
    return _Page(
      title: 'Share your trip',
      step: '19/23',
      onBack: _back,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trusted contacts can follow your live route, ETA and driver details.',
            style: TextStyle(color: _muted, fontSize: 12, height: 1.45),
          ),
          const SizedBox(height: 20),
          Container(
            height: 210,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(22)),
            child: const MapCanvas(showRoute: true, compact: true),
          ),
          const SizedBox(height: 18),
          const _ContactTile(
            initials: 'NK',
            name: 'Nadia Kabir',
            relation: 'Sister',
          ),
          const _ContactTile(
            initials: 'AK',
            name: 'Arif Khan',
            relation: 'Friend',
          ),
          const SizedBox(height: 10),
          SecondaryButton(
            label: 'Add trusted contact',
            icon: Icons.person_add_alt_1_outlined,
            onPressed: () {},
          ),
          const Spacer(),
          PrimaryButton(
            label: _shared ? 'Trip shared' : 'Share live trip',
            icon: _shared ? Icons.check : Icons.ios_share,
            onPressed: _controller.markTripShared,
          ),
        ],
      ),
    );
  }

  Widget _cancelReasonsScreen() {
    final reasons = [
      'Driver asked me to cancel',
      'Driver is not moving',
      'I can’t find the driver',
      'The wait is too long',
      'My plans changed',
      'Other reason',
    ];
    return _Page(
      title: 'Why are you cancelling?',
      step: '20/23',
      onBack: _back,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _DriverIdentity(compact: true),
          const SizedBox(height: 18),
          const Text(
            'Choose the reason that best describes the issue.',
            style: TextStyle(color: _muted, fontSize: 11),
          ),
          const SizedBox(height: 12),
          ...reasons.map(
            (reason) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => _go(RiderStage.cancellationPolicy),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _line),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          reason,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: _muted, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          SecondaryButton(label: 'Keep my booking', onPressed: _back),
        ],
      ),
    );
  }

  Widget _cancellationPolicyScreen() {
    return _Page(
      title: 'Cancellation policy',
      step: '21/23',
      onBack: _back,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _StateIcon(icon: Icons.receipt_long_outlined),
          const SizedBox(height: 18),
          Text('A fee may apply', style: _title(22)),
          const SizedBox(height: 8),
          const Text(
            'Late cancellation compensates your driver for the time and distance already spent reaching you.',
            style: TextStyle(color: _muted, fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _line),
            ),
            child: const Column(
              children: [
                _PolicyRow(
                  label: 'Free cancellation window',
                  value: 'First 5 min',
                ),
                Divider(height: 26),
                _PolicyRow(
                  label: 'Estimated cancellation fee',
                  value: 'RM 3–5',
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const _PolicyCheck('No fee when the driver has not moved toward you'),
          const _PolicyCheck(
            'No fee when the driver is over 10 min later than the ETA',
          ),
          const _PolicyCheck('No fee when you cancel inside the free window'),
          const Spacer(),
          PrimaryButton(
            label: 'Cancel booking anyway',
            destructive: true,
            onPressed: () {
              _controller.resetToHome();
            },
          ),
          const SizedBox(height: 8),
          SecondaryButton(label: 'Keep my booking', onPressed: _back),
        ],
      ),
    );
  }

  Widget _completedScreen() {
    return _Page(
      title: 'You’ve arrived',
      step: '22/23',
      child: Column(
        children: [
          const SizedBox(height: 4),
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              color: Color(0xFFE9F7F0),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded, color: _green, size: 36),
          ),
          const SizedBox(height: 14),
          Text('How was your ride with Aina?', style: _title(19)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              5,
              (index) => IconButton(
                onPressed: () => _controller.setRating(index + 1),
                icon: Icon(
                  index < _rating
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: index < _rating
                      ? const Color(0xFFF4B740)
                      : const Color(0xFFB8BFCD),
                  size: 31,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: _line),
            ),
            child: const Column(
              children: [
                _PolicyRow(label: 'Trip fare', value: 'RM 15.80'),
                Divider(height: 24),
                _PolicyRow(label: 'Payment', value: 'Visa •••• 4821'),
                Divider(height: 24),
                _PolicyRow(label: 'Receipt', value: 'View ›'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Align(
            alignment: Alignment.centerLeft,
            child: _FieldLabel('ADD A TIP'),
          ),
          const SizedBox(height: 9),
          Row(
            children: [0, 2, 5, 10]
                .map(
                  (amount) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 7),
                      child: ChoiceChip(
                        selected: _tip == amount,
                        label: Text(amount == 0 ? 'No tip' : 'RM $amount'),
                        onSelected: (_) => _controller.setTip(amount),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 18),
          const Align(
            alignment: Alignment.centerLeft,
            child: _FieldLabel('QUICK FEEDBACK'),
          ),
          const SizedBox(height: 8),
          const Wrap(
            spacing: 7,
            runSpacing: 7,
            children: [
              Chip(label: Text('Safe driving')),
              Chip(label: Text('Clean car')),
              Chip(label: Text('Friendly')),
              Chip(label: Text('Easy pickup')),
            ],
          ),
          const Spacer(),
          PrimaryButton(
            label: 'Submit rating',
            onPressed: () {
              _controller.resetToHome();
            },
          ),
        ],
      ),
    );
  }

  Widget _historyScreen() {
    return _Page(
      title: 'Your trips',
      step: '23/23',
      onBack: _back,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _MetricCard(label: 'Trips this month', value: '8'),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MetricCard(label: 'Total spent', value: 'RM 126'),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const _FieldLabel('RECENT TRIPS'),
          const SizedBox(height: 10),
          const _TripTile(
            date: 'Today · 10:26',
            route: 'Jalan Ampang → KL Sentral',
            fare: 'RM 15.80',
            driver: 'Aina · SwiftGo',
          ),
          const _TripTile(
            date: '12 Aug · 18:42',
            route: 'Pavilion KL → Taman Melati',
            fare: 'RM 22.40',
            driver: 'Hafiz · SwiftGo',
          ),
          const _TripTile(
            date: '08 Aug · 09:14',
            route: 'KL Sentral → The Exchange TRX',
            fare: 'RM 18.20',
            driver: 'Mira · SwiftPlus',
          ),
          const Spacer(),
          SecondaryButton(
            label: 'Back to map',
            icon: Icons.map_outlined,
            onPressed: () => _go(RiderStage.home),
          ),
        ],
      ),
    );
  }

  Widget _reconnectScreen() {
    return _Page(
      title: 'Location and connection',
      step: '24',
      onBack: _back,
      child: Column(
        children: [
          const SizedBox(height: 24),
          const _StateIcon(icon: Icons.gps_off_outlined),
          const SizedBox(height: 18),
          Text('We lost your live location', style: _title(21)),
          const SizedBox(height: 8),
          const Text(
            'Your trip information is safe. Check GPS and internet access, then reconnect.',
            textAlign: TextAlign.center,
            style: TextStyle(color: _muted, fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 28),
          const _ConnectionRow(
            icon: Icons.location_off_outlined,
            label: 'Location access',
            value: 'Needs attention',
            ok: false,
          ),
          const _ConnectionRow(
            icon: Icons.wifi,
            label: 'Internet connection',
            value: 'Connected',
            ok: true,
          ),
          const _ConnectionRow(
            icon: Icons.cloud_done_outlined,
            label: 'Trip data',
            value: 'Safely synced',
            ok: true,
          ),
          const Spacer(),
          PrimaryButton(
            label: 'Reconnect now',
            icon: Icons.refresh,
            onPressed: _back,
          ),
          const SizedBox(height: 8),
          SecondaryButton(label: 'Open device settings', onPressed: () {}),
        ],
      ),
    );
  }
}

class _Page extends StatelessWidget {
  const _Page({
    required this.title,
    required this.step,
    required this.child,
    this.onBack,
  });

  final String title;
  final String step;
  final Widget child;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
          child: Column(
            children: [
              Row(
                children: [
                  if (onBack != null) ...[
                    _CircleButton(
                      icon: Icons.arrow_back_ios_new_rounded,
                      onTap: onBack!,
                      small: true,
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(child: Text(title, style: _headline(22))),
                  _StepChip(step),
                ],
              ),
              const SizedBox(height: 22),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.destructive = false,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: destructive ? const Color(0xFFC84D3A) : _cobalt,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
            ),
            if (icon != null) ...[
              const SizedBox(width: 8),
              Icon(icon, size: 17),
            ],
          ],
        ),
      ),
    );
  }
}

class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 17),
        label: Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: _slate,
          side: const BorderSide(color: _line),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}

class ProviderButton extends StatelessWidget {
  const ProviderButton({
    super.key,
    required this.label,
    required this.logo,
    required this.onPressed,
  });
  final String label;
  final Widget logo;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: _line),
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Align(alignment: Alignment.centerLeft, child: logo),
            Text(
              label,
              style: const TextStyle(
                color: _ink,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GoogleMark extends StatelessWidget {
  const GoogleMark({super.key});
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: const Size(21, 21), painter: _GooglePainter());
}

class _GooglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4
      ..strokeCap = StrokeCap.square;
    final rect = Rect.fromLTWH(2.5, 2.5, size.width - 5, size.height - 5);
    stroke.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -.7, 1.8, false, stroke);
    stroke.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 1.1, 1.35, false, stroke);
    stroke.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 2.45, .75, false, stroke);
    stroke.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, 3.2, 1.35, false, stroke);
    stroke.color = const Color(0xFF4285F4);
    canvas.drawLine(
      Offset(size.width * .55, size.height * .52),
      Offset(size.width - 1.5, size.height * .52),
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SwiftRideLogo extends StatelessWidget {
  const SwiftRideLogo({super.key});
  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SwiftRideMark(size: 32),
        SizedBox(width: 9),
        Text(
          'SWIFTRIDE',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            letterSpacing: .8,
          ),
        ),
      ],
    );
  }
}

class SwiftRideMark extends StatelessWidget {
  const SwiftRideMark({super.key, this.size = 34});
  final double size;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(color: _cobalt, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Text(
        'S',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * .55,
          fontWeight: FontWeight.w800,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

class MapCanvas extends StatelessWidget {
  const MapCanvas({
    super.key,
    this.showRoute = false,
    this.searching = false,
    this.pickupCentered = false,
    this.inTrip = false,
    this.compact = false,
  });
  final bool showRoute;
  final bool searching;
  final bool pickupCentered;
  final bool inTrip;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset(
          'assets/maps/kl_google_map.png',
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
        ),
        Container(color: const Color(0x0A465AD9)),
        if (showRoute) CustomPaint(painter: _RoutePainter(inTrip: inTrip)),
        if (!pickupCentered)
          const Positioned(
            left: 78,
            top: 260,
            child: _MapMarker(color: Colors.white, borderColor: _ink),
          ),
        Positioned(
          right: pickupCentered ? null : 72,
          left: pickupCentered ? 0 : null,
          top: pickupCentered ? null : 180,
          bottom: pickupCentered ? 290 : null,
          child: pickupCentered
              ? const SizedBox(
                  width: 430,
                  child: Center(child: SizedBox.shrink()),
                )
              : const _MapMarker(color: _cobalt, borderColor: Colors.white),
        ),
        if (pickupCentered)
          const Center(
            child: Icon(Icons.location_pin, color: _cobalt, size: 50),
          ),
        if (searching)
          Positioned.fill(child: Container(color: const Color(0x220F1730))),
      ],
    );
  }
}

class _RoutePainter extends CustomPainter {
  const _RoutePainter({required this.inTrip});
  final bool inTrip;
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * .22, size.height * .48)
      ..cubicTo(
        size.width * .34,
        size.height * .34,
        size.width * .57,
        size.height * .47,
        size.width * .73,
        size.height * .25,
      );
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = _cobalt
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );
    if (inTrip) {
      canvas.drawCircle(
        Offset(size.width * .45, size.height * .39),
        10,
        Paint()..color = _cobalt,
      );
      canvas.drawCircle(
        Offset(size.width * .45, size.height * .39),
        4,
        Paint()..color = Colors.white,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RoutePainter oldDelegate) =>
      oldDelegate.inTrip != inTrip;
}

class _MapMarker extends StatelessWidget {
  const _MapMarker({required this.color, required this.borderColor});
  final Color color;
  final Color borderColor;
  @override
  Widget build(BuildContext context) => Container(
    width: 20,
    height: 20,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: borderColor, width: 3),
      boxShadow: const [BoxShadow(color: Color(0x3317233B), blurRadius: 8)],
    ),
  );
}

class BottomSheetSurface extends StatelessWidget {
  const BottomSheetSurface({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x2417233B),
            blurRadius: 28,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 46,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFC8CEE0),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _RideOption extends StatelessWidget {
  const _RideOption({
    required this.title,
    required this.meta,
    required this.price,
    required this.tag,
    required this.icon,
    required this.selected,
    required this.onTap,
  });
  final String title;
  final String meta;
  final String price;
  final String tag;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? _periwinkle : const Color(0xFFFAFBFD),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? _cobalt : _line,
            width: selected ? 1.4 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 40,
              decoration: BoxDecoration(
                color: selected ? _cobalt : const Color(0xFFE9ECF4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: selected ? Colors.white : _slate,
                size: 23,
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    meta,
                    style: const TextStyle(fontSize: 9, color: _muted),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  tag,
                  style: TextStyle(
                    fontSize: 8,
                    color: selected ? _cobalt : _muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DriverMapScreen extends StatelessWidget {
  const _DriverMapScreen({
    required this.title,
    required this.badge,
    required this.headline,
    required this.child,
    required this.onBack,
  });
  final String title;
  final String badge;
  final String headline;
  final Widget child;
  final VoidCallback onBack;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const Positioned.fill(child: MapCanvas(showRoute: true)),
          SafeArea(
            child: _MapTopBar(title: title, onBack: onBack),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: BottomSheetSurface(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(headline, style: _headline(22))),
                      _StatusPill(badge),
                    ],
                  ),
                  const SizedBox(height: 16),
                  child,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverIdentity extends StatelessWidget {
  const _DriverIdentity({this.compact = false});
  final bool compact;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(compact ? 12 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          AinaAvatar(size: compact ? 44 : 54),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aina Rahman',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 4),
                Text(
                  '4.9 ★ · 1,248 trips',
                  style: TextStyle(fontSize: 9, color: _muted),
                ),
                SizedBox(height: 3),
                Text(
                  'White Perodua Alza',
                  style: TextStyle(fontSize: 9, color: _muted),
                ),
              ],
            ),
          ),
          const Icon(Icons.verified_rounded, color: _cobalt, size: 20),
        ],
      ),
    );
  }
}

class AinaAvatar extends StatelessWidget {
  const AinaAvatar({super.key, this.size = 54});
  final double size;
  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _AinaPainter());
}

class _AinaPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 52;
    canvas.save();
    canvas.scale(scale);
    canvas.drawCircle(
      const Offset(26, 26),
      26,
      Paint()..color = const Color(0xFFDDE3F7),
    );
    final body = Path()
      ..moveTo(13, 52)
      ..quadraticBezierTo(15, 35, 26, 35)
      ..quadraticBezierTo(37, 35, 39, 52)
      ..close();
    canvas.drawPath(body, Paint()..color = _cobalt);
    canvas.drawOval(
      const Rect.fromLTWH(16, 11, 20, 24),
      Paint()..color = const Color(0xFFC98768),
    );
    final hair = Path()
      ..moveTo(16, 23)
      ..quadraticBezierTo(16, 7, 29, 7)
      ..quadraticBezierTo(39, 8, 38, 22)
      ..quadraticBezierTo(31, 20, 28, 14)
      ..quadraticBezierTo(23, 20, 16, 20)
      ..close();
    canvas.drawPath(hair, Paint()..color = _slate);
    canvas.drawCircle(const Offset(22, 23), 1, Paint()..color = _slate);
    canvas.drawCircle(const Offset(30, 23), 1, Paint()..color = _slate);
    canvas.drawArc(
      const Rect.fromLTWH(22, 26, 8, 5),
      .1,
      math.pi - .2,
      false,
      Paint()
        ..color = const Color(0xFF8B4F3C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _Action {
  const _Action(this.icon, this.label, this.onTap);
  final IconData icon;
  final String label;
  final VoidCallback onTap;
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({required this.actions});
  final List<_Action> actions;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: actions
          .map(
            (action) => InkWell(
              onTap: action.onTap,
              borderRadius: BorderRadius.circular(30),
              child: SizedBox(
                width: 62,
                child: Column(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: _soft,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(action.icon, color: _slate, size: 19),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      action.label,
                      style: const TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _MapTopBar extends StatelessWidget {
  const _MapTopBar({required this.title, required this.onBack, this.trailing});
  final String title;
  final VoidCallback onBack;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: _floatingDecoration(radius: 18),
        child: Row(
          children: [
            _CircleButton(
              icon: Icons.arrow_back_ios_new_rounded,
              onTap: onBack,
              small: true,
              flat: true,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ),
            trailing ?? const SizedBox.shrink(),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.icon,
    required this.onTap,
    this.small = false,
    this.flat = false,
  });
  final IconData icon;
  final VoidCallback onTap;
  final bool small;
  final bool flat;
  @override
  Widget build(BuildContext context) {
    final extent = small ? 34.0 : 44.0;
    return Material(
      color: flat ? _soft : Colors.white,
      shape: const CircleBorder(),
      elevation: flat ? 0 : 3,
      shadowColor: const Color(0x2417233B),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: extent,
          height: extent,
          child: Icon(icon, size: small ? 15 : 20, color: _slate),
        ),
      ),
    );
  }
}

class _StepChip extends StatelessWidget {
  const _StepChip(this.value);
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
    decoration: BoxDecoration(
      color: _periwinkle,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      value,
      style: const TextStyle(
        color: _cobalt,
        fontWeight: FontWeight.w800,
        fontSize: 9,
      ),
    ),
  );
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.value);
  final String value;
  @override
  Widget build(BuildContext context) => Text(
    value,
    style: const TextStyle(
      fontSize: 9,
      color: _muted,
      fontWeight: FontWeight.w800,
      letterSpacing: .7,
    ),
  );
}

class _CountryCode extends StatelessWidget {
  const _CountryCode();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 14),
    child: Center(
      child: Text(
        '+60',
        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
      ),
    ),
  );
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();
  @override
  Widget build(BuildContext context) => const Row(
    children: [
      Expanded(child: Divider(color: _line)),
      Padding(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Text(
          'OR',
          style: TextStyle(
            color: _muted,
            fontSize: 9,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      Expanded(child: Divider(color: _line)),
    ],
  );
}

class _NumberPad extends StatelessWidget {
  const _NumberPad({required this.onDigit, required this.onDelete});
  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) {
    final items = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', '⌫'];
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 1.8,
      children: items
          .map(
            (item) => item.isEmpty
                ? const SizedBox.shrink()
                : InkWell(
                    onTap: item == '⌫' ? onDelete : () => onDigit(item),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: _line),
                      ),
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
          )
          .toList(),
    );
  }
}

class _PermissionBenefit extends StatelessWidget {
  const _PermissionBenefit(this.icon, this.label);
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 13),
    child: Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: _periwinkle,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: _cobalt, size: 18),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

class _MapPermissionIcon extends StatelessWidget {
  const _MapPermissionIcon();
  @override
  Widget build(BuildContext context) => Stack(
    alignment: Alignment.center,
    children: [
      const Icon(Icons.map_outlined, size: 92, color: _slate),
      Positioned(
        top: 34,
        child: Container(
          width: 28,
          height: 28,
          decoration: const BoxDecoration(
            color: _cobalt,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.location_on, size: 18, color: Colors.white),
        ),
      ),
    ],
  );
}

class _SavedPlace extends StatelessWidget {
  const _SavedPlace({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(15),
    child: Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: _soft,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: _periwinkle,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 17, color: _cobalt),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: _muted, fontSize: 8),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.onHistory});
  final VoidCallback onHistory;
  @override
  Widget build(BuildContext context) => Container(
    height: 58,
    padding: const EdgeInsets.symmetric(horizontal: 20),
    decoration: _floatingDecoration(radius: 20),
    child: Row(
      children: [
        const Expanded(child: _NavIcon(Icons.map_rounded, 'Ride', true)),
        Expanded(
          child: _NavIcon(
            Icons.receipt_long_outlined,
            'Trips',
            false,
            onTap: onHistory,
          ),
        ),
        const Expanded(
          child: _NavIcon(
            Icons.account_balance_wallet_outlined,
            'Wallet',
            false,
          ),
        ),
        const Expanded(child: _NavIcon(Icons.person_outline, 'Account', false)),
      ],
    ),
  );
}

class _NavIcon extends StatelessWidget {
  const _NavIcon(this.icon, this.label, this.selected, {this.onTap});
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 19, color: selected ? _cobalt : _muted),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(
            fontSize: 8,
            color: selected ? _cobalt : _muted,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

class _LocationField extends StatelessWidget {
  const _LocationField({
    required this.color,
    required this.label,
    required this.value,
  });
  final Color color;
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(Icons.circle, size: 11, color: color),
      const SizedBox(width: 12),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 9, color: _muted)),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    ],
  );
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? _periwinkle : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? _cobalt : _line),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: selected ? _cobalt : _soft,
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: selected ? Colors.white : _slate,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 9, color: _muted),
                  ),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? _cobalt : _muted,
              size: 20,
            ),
          ],
        ),
      ),
    ),
  );
}

class _RouteSummary extends StatelessWidget {
  const _RouteSummary({this.compact = false});
  final bool compact;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: _soft,
      borderRadius: BorderRadius.circular(16),
    ),
    child: const Column(
      children: [
        _LocationField(
          color: _ink,
          label: 'Pickup',
          value: 'Jalan Ampang, KLCC',
        ),
        Padding(
          padding: EdgeInsets.only(left: 5),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              height: 18,
              child: VerticalDivider(
                width: 2,
                thickness: 2,
                color: Color(0xFFC8CEE0),
              ),
            ),
          ),
        ),
        _LocationField(
          color: _cobalt,
          label: 'Destination',
          value: 'KL Sentral, Brickfields',
        ),
      ],
    ),
  );
}

class _DropdownSummary extends StatelessWidget {
  const _DropdownSummary({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
  });
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(14),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _line),
      ),
      child: Row(
        children: [
          Icon(icon, size: 19, color: _slate),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 8,
                    color: _muted,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            const Icon(Icons.keyboard_arrow_down, size: 19, color: _muted),
        ],
      ),
    ),
  );
}

class _SearchingPulse extends StatefulWidget {
  const _SearchingPulse();
  @override
  State<_SearchingPulse> createState() => _SearchingPulseState();
}

class _SearchingPulseState extends State<_SearchingPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (_, __) {
      final scale = .8 + _controller.value * .7;
      final opacity = 1 - _controller.value;
      return Stack(
        alignment: Alignment.center,
        children: [
          Transform.scale(
            scale: scale,
            child: Opacity(
              opacity: opacity,
              child: Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  color: _cobalt,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          Container(
            width: 62,
            height: 62,
            decoration: const BoxDecoration(
              color: _cobalt,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(color: Color(0x55465AD9), blurRadius: 20)],
            ),
            child: const Icon(
              Icons.local_taxi_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
        ],
      );
    },
  );
}

class _StateIcon extends StatelessWidget {
  const _StateIcon({required this.icon});
  final IconData icon;
  @override
  Widget build(BuildContext context) => Container(
    width: 74,
    height: 74,
    decoration: const BoxDecoration(color: _periwinkle, shape: BoxShape.circle),
    child: Icon(icon, color: _cobalt, size: 34),
  );
}

class _StatusPill extends StatelessWidget {
  const _StatusPill(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: _periwinkle,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: _cobalt,
        fontSize: 8,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: _soft,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _cobalt, size: 17),
          ),
          const SizedBox(width: 11),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 8,
                  color: _muted,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SafetyTile extends StatelessWidget {
  const _SafetyTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: danger ? const Color(0xFFF3C7BF) : _line),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: danger ? const Color(0xFFFFF1EE) : _periwinkle,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: danger ? const Color(0xFFC84D3A) : _cobalt,
                size: 19,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 8, color: _muted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: _muted),
          ],
        ),
      ),
    ),
  );
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.initials,
    required this.name,
    required this.relation,
  });
  final String initials;
  final String name;
  final String relation;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 9),
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: _line),
    ),
    child: Row(
      children: [
        CircleAvatar(
          backgroundColor: _periwinkle,
          child: Text(
            initials,
            style: const TextStyle(
              color: _cobalt,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                relation,
                style: const TextStyle(color: _muted, fontSize: 8),
              ),
            ],
          ),
        ),
        Checkbox(value: true, onChanged: (_) {}),
      ],
    ),
  );
}

class _PolicyRow extends StatelessWidget {
  const _PolicyRow({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        child: Text(label, style: const TextStyle(fontSize: 11, color: _muted)),
      ),
      Text(
        value,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
      ),
    ],
  );
}

class _PolicyCheck extends StatelessWidget {
  const _PolicyCheck(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 20,
          height: 20,
          decoration: const BoxDecoration(
            color: Color(0xFFE9F7F0),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, size: 13, color: _green),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, height: 1.35),
          ),
        ),
      ],
    ),
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});
  final String label;
  final String value;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: _slate,
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Color(0xFFBFC7D9), fontSize: 9),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    ),
  );
}

class _TripTile extends StatelessWidget {
  const _TripTile({
    required this.date,
    required this.route,
    required this.fare,
    required this.driver,
  });
  final String date;
  final String route;
  final String fare;
  final String driver;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _line),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(date, style: const TextStyle(fontSize: 9, color: _muted)),
            const Spacer(),
            Text(
              fare,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          route,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(driver, style: const TextStyle(fontSize: 9, color: _muted)),
      ],
    ),
  );
}

class _ConnectionRow extends StatelessWidget {
  const _ConnectionRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.ok,
  });
  final IconData icon;
  final String label;
  final String value;
  final bool ok;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: _line),
    ),
    child: Row(
      children: [
        Icon(icon, color: ok ? _green : const Color(0xFFC84D3A), size: 21),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 9,
            color: ok ? _green : const Color(0xFFC84D3A),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

TextStyle _headline(double size, {double? height}) => TextStyle(
  fontSize: size,
  fontWeight: FontWeight.w800,
  letterSpacing: -.6,
  height: height,
);
TextStyle _title(double size) =>
    TextStyle(fontSize: size, fontWeight: FontWeight.w800, letterSpacing: -.3);

BoxDecoration _floatingDecoration({double radius = 16}) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(radius),
  boxShadow: const [
    BoxShadow(color: Color(0x2417233B), blurRadius: 18, offset: Offset(0, 5)),
  ],
);

import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/rider/presentation/pages/rider_flow_page.dart';

class SwiftRideApp extends StatelessWidget {
  const SwiftRideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SwiftRide',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      builder: (context, child) => ColoredBox(
        color: const Color(0xFFE9ECF3),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: child ?? const SizedBox.shrink(),
          ),
        ),
      ),
      home: const RiderFlow(),
    );
  }
}

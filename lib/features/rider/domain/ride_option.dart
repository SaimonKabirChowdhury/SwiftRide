import 'package:flutter/material.dart';

class RideOption {
  const RideOption({
    required this.id,
    required this.name,
    required this.arrivalDescription,
    required this.price,
    required this.badge,
    required this.icon,
  });

  final String id;
  final String name;
  final String arrivalDescription;
  final String price;
  final String badge;
  final IconData icon;
}

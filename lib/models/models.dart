import 'package:flutter/material.dart';

/// Core data models for FixinDays.

class ServiceCategory {
  final String id;
  final String name;
  final IconData icon;
  final String tagline;

  const ServiceCategory({
    required this.id,
    required this.name,
    required this.icon,
    required this.tagline,
  });
}

class Provider {
  final String id;
  final String categoryId;
  final String name;
  final double rating;
  final int reviewsCount;
  final int priceOnwards; // in INR
  final String distance;
  final bool verified;
  final List<String> services;

  const Provider({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.rating,
    required this.reviewsCount,
    required this.priceOnwards,
    required this.distance,
    required this.verified,
    required this.services,
  });
}

class Booking {
  final String id;
  final String providerName;
  final String serviceName;
  final String dateLabel;
  final String timeLabel;
  final String address;
  final int price;
  final String status; // Confirmed / Completed / Cancelled

  const Booking({
    required this.id,
    required this.providerName,
    required this.serviceName,
    required this.dateLabel,
    required this.timeLabel,
    required this.address,
    required this.price,
    this.status = 'Confirmed',
  });

  Booking copyWith({String? status}) => Booking(
        id: id,
        providerName: providerName,
        serviceName: serviceName,
        dateLabel: dateLabel,
        timeLabel: timeLabel,
        address: address,
        price: price,
        status: status ?? this.status,
      );
}

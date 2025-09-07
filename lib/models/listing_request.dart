import 'package:flutter/material.dart';

enum ListingRequestStatus {
  pending,
  approved,
  rejected,
}

class ListingRequest {
  final String id;
  final String userId;
  final String propertyId;
  final String propertyName;
  final String propertyAddress;
  final double askingPrice;
  final String description;
  final List<String> imageUrls;
  final ListingRequestStatus status;
  final String? adminNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ListingRequest({
    required this.id,
    required this.userId,
    required this.propertyId,
    required this.propertyName,
    required this.propertyAddress,
    required this.askingPrice,
    required this.description,
    required this.imageUrls,
    required this.status,
    this.adminNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  ListingRequest copyWith({
    String? id,
    String? userId,
    String? propertyId,
    String? propertyName,
    String? propertyAddress,
    double? askingPrice,
    String? description,
    List<String>? imageUrls,
    ListingRequestStatus? status,
    String? adminNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ListingRequest(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      propertyId: propertyId ?? this.propertyId,
      propertyName: propertyName ?? this.propertyName,
      propertyAddress: propertyAddress ?? this.propertyAddress,
      askingPrice: askingPrice ?? this.askingPrice,
      description: description ?? this.description,
      imageUrls: imageUrls ?? this.imageUrls,
      status: status ?? this.status,
      adminNotes: adminNotes ?? this.adminNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'propertyId': propertyId,
      'propertyName': propertyName,
      'propertyAddress': propertyAddress,
      'askingPrice': askingPrice,
      'description': description,
      'imageUrls': imageUrls,
      'status': status.name,
      'adminNotes': adminNotes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ListingRequest.fromJson(Map<String, dynamic> json) {
    return ListingRequest(
      id: json['id'] as String,
      userId: json['userId'] as String,
      propertyId: json['propertyId'] as String,
      propertyName: json['propertyName'] as String,
      propertyAddress: json['propertyAddress'] as String,
      askingPrice: (json['askingPrice'] as num).toDouble(),
      description: json['description'] as String,
      imageUrls: List<String>.from(json['imageUrls'] as List),
      status: _parseStatus(json['status'] as String),
      adminNotes: json['adminNotes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  static ListingRequestStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ListingRequestStatus.pending;
      case 'approved':
        return ListingRequestStatus.approved;
      case 'rejected':
        return ListingRequestStatus.rejected;
      default:
        return ListingRequestStatus.pending;
    }
  }

  String get statusDisplayName {
    switch (status) {
      case ListingRequestStatus.pending:
        return 'Pending Review';
      case ListingRequestStatus.approved:
        return 'Approved';
      case ListingRequestStatus.rejected:
        return 'Rejected';
    }
  }

  Color get statusColor {
    switch (status) {
      case ListingRequestStatus.pending:
        return Colors.orange;
      case ListingRequestStatus.approved:
        return Colors.green;
      case ListingRequestStatus.rejected:
        return Colors.red;
    }
  }

  String get formattedAskingPrice {
    return '\$${askingPrice.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    )}';
  }
}

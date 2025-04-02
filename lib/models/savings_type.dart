import 'package:flutter/material.dart';

class SavingsType {
  final int id;
  final String name;
  final String? description;
  final String? icon;
  final String? color;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SavingsType({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.color,
    this.createdAt,
    this.updatedAt,
  });

  factory SavingsType.fromJson(Map<String, dynamic> json) {
    return SavingsType(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      color: json['color'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'icon': icon,
    'color': color,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  // Helper method untuk mendapatkan warna dari string hex
  Color? get colorValue {
    if (color == null) return null;
    try {
      return Color(int.parse(color!.replaceAll('#', '0xFF')));
    } catch (e) {
      return null;
    }
  }

  // Helper method untuk mendapatkan icon dari string name
  IconData? get iconData {
    if (icon == null) return null;
    switch (icon) {
      case 'mosque':
        return Icons.mosque;
      case 'emergency':
        return Icons.emergency;
      case 'elderly':
        return Icons.elderly;
      default:
        return Icons.savings;
    }
  }
} 
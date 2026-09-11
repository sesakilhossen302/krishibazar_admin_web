import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AdminApiService {
  static const String serverBaseUrl = "http://127.0.0.1:8000";
  static const String baseUrl = "$serverBaseUrl/api/v1";

  /// Format image URL so it can be viewed on Web or Desktop browser
  static String formatMediaUrl(String? url) {
    if (url == null || url.trim().isEmpty) return "";
    String formatted = url.trim();
    if (formatted.startsWith("/")) {
      return "$serverBaseUrl$formatted";
    }
    if (!formatted.startsWith("http://") && !formatted.startsWith("https://")) {
      return "$serverBaseUrl/$formatted";
    }
    if (formatted.contains("10.0.2.2:8000")) {
      formatted = formatted.replaceAll("10.0.2.2:8000", "127.0.0.1:8000");
    }
    return formatted;
  }

  /// Fetch all registered users from backend
  static Future<List<Map<String, dynamic>>> fetchAllUsers() async {
    try {
      final uri = Uri.parse('$baseUrl/users/');
      final response = await http.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('⚠️ [ADMIN API ERROR - FETCH USERS]: $e');
    }
    return [];
  }

  /// Update verification status of a user (verified, rejected, pending, in_progress, suspended)
  /// and optionally NID verification status (verified, rejected, pending) and admin notes
  static Future<bool> updateUserStatus({
    required String userId,
    String? status,
    String? adminNote,
    String? nidStatus,
    String? nidRejectionNote,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/users/$userId/status');
      final Map<String, dynamic> body = {};
      if (status != null) body['status'] = status;
      if (adminNote != null) body['admin_note'] = adminNote;
      if (nidStatus != null) body['nid_status'] = nidStatus;
      if (nidRejectionNote != null) body['nid_rejection_note'] = nidRejectionNote;

      final response = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 8));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('⚠️ [ADMIN API ERROR - UPDATE STATUS]: $e');
      return false;
    }
  }

  /// Fetch all products from backend
  static Future<List<Map<String, dynamic>>> fetchAllProducts() async {
    try {
      final uri = Uri.parse('$baseUrl/products/');
      final response = await http.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('⚠️ [ADMIN API ERROR - FETCH PRODUCTS]: $e');
    }
    return [];
  }

  /// Update product status (active, rejected, pending, sold, archived)
  static Future<bool> updateProductStatus({
    required String productId,
    required String status,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/products/$productId');
      final response = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status}),
      ).timeout(const Duration(seconds: 8));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('⚠️ [ADMIN API ERROR - UPDATE PRODUCT STATUS]: $e');
      return false;
    }
  }

  /// Delete or archive product from backend
  static Future<bool> deleteProduct(String productId) async {
    try {
      final uri = Uri.parse('$baseUrl/products/$productId');
      final response = await http.delete(uri).timeout(const Duration(seconds: 8));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('⚠️ [ADMIN API ERROR - DELETE PRODUCT]: $e');
      return false;
    }
  }

  /// Fetch all demands from backend
  static Future<List<Map<String, dynamic>>> fetchAllDemands() async {
    try {
      final uri = Uri.parse('$baseUrl/demands/');
      final response = await http.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('⚠️ [ADMIN API ERROR - FETCH DEMANDS]: $e');
    }
    return [];
  }

  /// Fetch all orders from backend
  static Future<List<Map<String, dynamic>>> fetchAllOrders() async {
    try {
      final uri = Uri.parse('$baseUrl/orders/');
      final response = await http.get(uri).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final List data = jsonDecode(utf8.decode(response.bodyBytes));
        return data.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('⚠️ [ADMIN API ERROR - FETCH ORDERS]: $e');
    }
    return [];
  }

  /// Quality and weight verification from Admin Hub
  static Future<bool> verifyOrderQuality({
    required String orderId,
    required double actualWeight,
    required String qualityGrade,
    String? verifiedBy,
    String? verificationNotes,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/orders/$orderId/verify-quality');
      final body = {
        'actual_weight': actualWeight,
        'quality_grade': qualityGrade,
        if (verifiedBy != null && verifiedBy.isNotEmpty) 'verified_by': verifiedBy,
        if (verificationNotes != null && verificationNotes.isNotEmpty)
          'verification_notes': verificationNotes,
      };

      final response = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 8));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('⚠️ [ADMIN API ERROR - VERIFY QUALITY]: $e');
      return false;
    }
  }

  /// Update transport info and vehicle assignment
  static Future<bool> updateOrderTransport({
    required String orderId,
    String? driverName,
    String? driverPhone,
    String? vehicleNumber,
    String? transportStatus,
    String? pickupLocation,
    String? collectionCenter,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/orders/$orderId/transport');
      final Map<String, dynamic> body = {};
      if (driverName != null) body['driver_name'] = driverName;
      if (driverPhone != null) body['driver_phone'] = driverPhone;
      if (vehicleNumber != null) body['vehicle_number'] = vehicleNumber;
      if (transportStatus != null) body['transport_status'] = transportStatus;
      if (pickupLocation != null) body['pickup_location'] = pickupLocation;
      if (collectionCenter != null) body['collection_center'] = collectionCenter;

      final response = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 8));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('⚠️ [ADMIN API ERROR - UPDATE TRANSPORT]: $e');
      return false;
    }
  }

  /// Update order lifecycle status (e.g. pending, paymentConfirmed, collectionVerified, inTransit, delivered, completed)
  static Future<bool> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/orders/$orderId/status');
      final response = await http.patch(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'order_status': status}),
      ).timeout(const Duration(seconds: 8));

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('⚠️ [ADMIN API ERROR - UPDATE ORDER STATUS]: $e');
      return false;
    }
  }

  /// Pay deposit simulation from admin if needed
  static Future<bool> payOrderDeposit(String orderId) async {
    try {
      final uri = Uri.parse('$baseUrl/orders/$orderId/pay-deposit');
      final response = await http.post(uri).timeout(const Duration(seconds: 8));
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('⚠️ [ADMIN API ERROR - PAY DEPOSIT]: $e');
      return false;
    }
  }
}

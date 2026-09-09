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
}

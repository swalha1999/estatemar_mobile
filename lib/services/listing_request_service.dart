import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/listing_request.dart';

class ListingRequestService {
  static const String _key = 'listing_requests';

  static Future<List<ListingRequest>> getListingRequests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? requestsJson = prefs.getString(_key);
      
      if (requestsJson == null) {
        return [];
      }
      
      final List<dynamic> requestsList = json.decode(requestsJson);
      return requestsList
          .map((json) => ListingRequest.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  static Future<List<ListingRequest>> getUserListingRequests(String userId) async {
    final allRequests = await getListingRequests();
    return allRequests.where((request) => request.userId == userId).toList();
  }

  static Future<ListingRequest?> getListingRequestById(String id) async {
    final allRequests = await getListingRequests();
    try {
      return allRequests.firstWhere((request) => request.id == id);
    } catch (e) {
      return null;
    }
  }

  static Future<bool> addListingRequest(ListingRequest request) async {
    try {
      final allRequests = await getListingRequests();
      allRequests.add(request);
      
      final prefs = await SharedPreferences.getInstance();
      final requestsJson = json.encode(
        allRequests.map((request) => request.toJson()).toList(),
      );
      
      return await prefs.setString(_key, requestsJson);
    } catch (e) {
      return false;
    }
  }

  static Future<bool> updateListingRequest(ListingRequest updatedRequest) async {
    try {
      final allRequests = await getListingRequests();
      final index = allRequests.indexWhere((request) => request.id == updatedRequest.id);
      
      if (index == -1) {
        return false;
      }
      
      allRequests[index] = updatedRequest;
      
      final prefs = await SharedPreferences.getInstance();
      final requestsJson = json.encode(
        allRequests.map((request) => request.toJson()).toList(),
      );
      
      return await prefs.setString(_key, requestsJson);
    } catch (e) {
      return false;
    }
  }

  static Future<bool> deleteListingRequest(String id) async {
    try {
      final allRequests = await getListingRequests();
      allRequests.removeWhere((request) => request.id == id);
      
      final prefs = await SharedPreferences.getInstance();
      final requestsJson = json.encode(
        allRequests.map((request) => request.toJson()).toList(),
      );
      
      return await prefs.setString(_key, requestsJson);
    } catch (e) {
      return false;
    }
  }

  static Future<bool> hasExistingRequestForProperty(String propertyId) async {
    final allRequests = await getListingRequests();
    return allRequests.any((request) => 
        request.propertyId == propertyId && 
        request.status == ListingRequestStatus.pending);
  }
}

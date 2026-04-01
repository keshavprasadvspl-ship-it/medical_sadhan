import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/banner_model.dart';
import '../models/cart_item_model.dart';
import '../models/medicine_model.dart';
import '../models/product_model.dart';
import 'api_endpoints.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  static const String baseUrl = 'https://urjaguru.in/api';

  // Common headers
  Map<String, String> getHeaders({String? token}) {
    Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }


  Future<Map<String, dynamic>> getAllDivisions() async {
    try {
      print('🌐 Fetching all divisions with http...');

      final url = Uri.parse('$baseUrl/divisions');

      final response = await http.get(
        url
      );

      print('📡 Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('✅ Divisions fetched successfully');
        return responseData;
      } else {
        print('❌ Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return {
          'success': false,
          'message': 'Failed to load divisions. Status code: ${response.statusCode}',
          'data': []
        };
      }
    } catch (e) {
      print('❌ Error fetching divisions: $e');
      return {
        'success': false,
        'message': 'Failed to load divisions: $e',
        'data': []
      };
    }
  }

  // ✅ Alternative: Get divisions by company ID using http


  Future<Map<String, dynamic>> saveFavoriteAgencies(String buyerId ,List<String> selectedAgencyIds) async {
    try {
      print('🌐 Saving favorite agencies...');
      print('Selected Agency IDs: $selectedAgencyIds');

      final url = Uri.parse('${ApiEndpoints.baseUrl}/buyer/favorite-agencies');

      final requestBody = jsonEncode({
        'buyer_id': buyerId,
        'agency_ids': selectedAgencyIds,
      });

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          // Add authorization token if required
          // 'Authorization': 'Bearer ${getToken()}',
        },
        body: requestBody,
      );

      print('📡 Response status code: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        print('✅ Favorite agencies saved successfully');
        return responseData;
      } else {
        print('❌ Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return {
          'success': false,
          'message': 'Failed to save favorite agencies. Status code: ${response.statusCode}',
          'data': null
        };
      }
    } catch (e) {
      print('❌ Error saving favorite agencies: $e');
      return {
        'success': false,
        'message': 'Failed to save favorite agencies: $e',
        'data': null
      };
    }
  }

// Optional: Get saved favorite agencies
  Future<Map<String, dynamic>> getFavoriteAgencies(String buyerID) async {
    try {
      final buyerId = buyerID;
      print('🌐 Fetching favorite agencies...');

      final url = Uri.parse('${ApiEndpoints.baseUrl}/buyer/favorite-agencies?buyer_id=$buyerId');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer ${getToken()}',
        },
      );

      print('📡 Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('✅ Favorite agencies fetched successfully');
        return responseData;
      } else {
        print('❌ Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return {
          'success': false,
          'message': 'Failed to load favorite agencies. Status code: ${response.statusCode}',
          'data': []
        };
      }
    } catch (e) {
      print('❌ Error fetching favorite agencies: $e');
      return {
        'success': false,
        'message': 'Failed to load favorite agencies: $e',
        'data': []
      };
    }
  }

// Optional: Delete a favorite agency
  Future<Map<String, dynamic>> deleteFavoriteAgency(String agencyId) async {
    try {
      print('🌐 Deleting favorite agency: $agencyId');

      final url = Uri.parse('${ApiEndpoints.baseUrl}/buyer/favorite-agencies/$agencyId');

      final response = await http.delete(
        url,
        headers: {
          'Content-Type': 'application/json',
          // 'Authorization': 'Bearer ${getToken()}',
        },
      );

      print('📡 Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        print('✅ Favorite agency deleted successfully');
        return responseData;
      } else {
        print('❌ Error: ${response.statusCode}');
        print('Response body: ${response.body}');
        return {
          'success': false,
          'message': 'Failed to delete favorite agency. Status code: ${response.statusCode}',
          'data': null
        };
      }
    } catch (e) {
      print('❌ Error deleting favorite agency: $e');
      return {
        'success': false,
        'message': 'Failed to delete favorite agency: $e',
        'data': null
      };
    }
  }


  Future<List<BannerModel>> getBanners({String type = 'all', int limit = 10}) async {
    try {
      String url = '$baseUrl/banners';  // Removed extra /api since baseUrl already has /api

      // Add query parameters
      url += '?type=$type&limit=$limit';

      print('📡 GET Request: $url');

      final response = await http.get(
        Uri.parse(url),
        headers: getHeaders(),  // Using your existing getHeaders() method
      );

      print('📡 Response Status: ${response.statusCode}');
      print('📡 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        if (jsonData['success'] == true) {
          List<dynamic> data = jsonData['data'] ?? [];
          return data.map((item) => BannerModel.fromJson(item)).toList();
        } else {
          print('❌ API returned success false: ${jsonData['message']}');
          return [];
        }
      } else {
        print('❌ HTTP Error: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('❌ Error in getBanners: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> sendPhoneOtp(String phone) async {
    try {
      final url = Uri.parse('$baseUrl/phone/send-otp');

      final body = jsonEncode({
        'phone': phone,
      });
print('phone url');
print(url);
print(body);
      final response = await http.post(
        url,
        headers: getHeaders(),
        body: body,
      );
      print(response.body);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to send OTP'
        };
      }
    } catch (e) {
      print('Error in sendPhoneOtp: $e');
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }



  Future<Map<String, dynamic>> verifyPhoneOtp({
    required String phone,
    required String otp,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/phone/verify-otp');

      final body = jsonEncode({
        'phone': phone,
        'otp': otp,
      });

      final response = await http.post(
        url,
        headers: getHeaders(),
        body: body,
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'OTP verification failed'
        };
      }
    } catch (e) {
      print('Error in verifyPhoneOtp: $e');
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }

  // In your ApiService class
  Future<List<dynamic>> getVendors({int limit = 10}) async {
    try {
      final url = Uri.parse('$baseUrl/vendors/list?limit=$limit');

      final response = await http.get(
        url,
        headers: getHeaders(),
      );

      print('vendor url====>$url');
      print('vendor response====>${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData['status'] == true && responseData['data'] != null) {
          return responseData['data'] as List;
        }
      }

      return [];
    } catch (e) {
      print('Error fetching vendors: $e');
      return [];
    }
  }

  // In your ApiService class
  Future<List<dynamic>> getFavVendors(String userId) async {
    try {
      final url = Uri.parse('$baseUrl/buyers/favorite-vendors?buyer_id=$userId');

      final response = await http.get(
        url,
        headers: getHeaders(),
      );

      print('vendor url====>$url');
      print('vendor response====>${response.body}');

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        if (responseData['status'] == true && responseData['data'] != null) {
          return responseData['data'] as List;
        }
      }

      return [];
    } catch (e) {
      print('Error fetching vendors: $e');
      return [];
    }
  }

  // Register user
  Future<Map<String, dynamic>> registerUser({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    required String type,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/register'); // Adjust endpoint as needed

      final body = jsonEncode({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'type': type,
      });

      final response = await http.post(
        url,
        headers: getHeaders(),
        body: body,
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }


  Future<Map<String, dynamic>> getBuyerProfile({
    required int userId,
    String? token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/buyer/$userId');

      final response = await http.get(
        url,
        headers: getHeaders(token: token),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        return {
          'status': false,
          'message': responseData['message'] ?? 'Failed to load profile'
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Network error: $e'
      };
    }
  }

  Future<Map<String, dynamic>> saveBuyerProfile({
    required int userId,
    required Map<String, dynamic> data,
    String? token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/buyer');

      final requestBody = {
        "user_id": userId,
        ...data,
      };

      final response = await http.post(
        url,
        headers: getHeaders(token: token),
        body: jsonEncode(requestBody),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      } else {
        return {
          'status': false,
          'message': responseData['message'] ?? 'Failed to save profile'
        };
      }
    } catch (e) {
      return {
        'status': false,
        'message': 'Network error: $e'
      };
    }
  }


  // Login user
  Future<Map<String, dynamic>> loginUser({
    required String email,
    required String password,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/login'); // Adjust endpoint as needed

      final body = jsonEncode({
        'email': email,
        'password': password,
      });

      final response = await http.post(
        url,
        headers: getHeaders(),
        body: body,
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception(responseData['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get user profile
  Future<Map<String, dynamic>> getUserProfile(String token) async {
    try {
      final url = Uri.parse('$baseUrl/profile'); // Adjust endpoint as needed

      final response = await http.get(
        url,
        headers: getHeaders(token: token),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        throw Exception('Failed to load profile');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Get companies list
  Future<List<Map<String, dynamic>>> getCompanies() async {
    try {
      final url = Uri.parse('$baseUrl/company');

      final response = await http.get(
        url,
        headers: getHeaders(),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        final List<dynamic> companiesData = responseData['data'];

        // IMPORTANT: Return the FULL data including categories
        return companiesData.map((company) {
          return {
            'id': company['id'],
            'name': company['name'] ?? '',
            'image': company['image'] ?? '',
            'description': company['description'] ?? '',
            'is_active': company['is_active'] ?? false,
            'created_at': company['created_at'] ?? '',
            'updated_at': company['updated_at'] ?? '',
            'categories': company['categories'] ?? [], // THIS IS CRITICAL - KEEP THE CATEGORIES
          };
        }).toList();
      } else {
        throw Exception(responseData['message'] ?? 'Failed to load companies');
      }
    } catch (e) {
      throw Exception('Failed to load companies: $e');
    }
  }

  // Get categories with subcategories
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final url = Uri.parse('$baseUrl/category'); // Adjust endpoint if needed

      final response = await http.get(
        url,
        headers: getHeaders(),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        final List<dynamic> categoriesData = responseData['data'];
        return categoriesData.map((category) {
          // Map icons based on category name or code
          String icon = _getCategoryIcon(category['name'] ?? category['code'] ?? '');

          return {
            'id': category['id'].toString(),
            'name': category['name'] ?? '',
            'code': category['code'] ?? '',
            'icon': icon,
            'description': category['description'] ?? '',
            'is_active': category['is_active'] ?? false,
            'image': category['image'] ?? '',
            'subCategories': (category['sub_categories'] as List?)?.map((subCat) {
              return {
                'id': subCat['id'].toString(),
                'name': subCat['name'] ?? '',
                'code': subCat['code'] ?? '',
                'description': subCat['description'] ?? '',
                'image': subCat['image'] ?? '',
                'is_active': subCat['is_active'] ?? false,
              };
            }).toList() ?? [],
          };
        }).toList();
      } else {
        throw Exception(responseData['message'] ?? 'Failed to load categories');
      }
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  // Helper function to get appropriate icon for category
  String _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();

    if (name.contains('antibiotic') || name.contains('antibacterial')) return '💊';
    if (name.contains('pain') || name.contains('analgesic')) return '😷';
    if (name.contains('vitamin') || name.contains('supplement')) return '💪';
    if (name.contains('cardiac') || name.contains('heart')) return '❤️';
    if (name.contains('diabetes') || name.contains('blood sugar')) return '🩸';
    if (name.contains('gastro') || name.contains('stomach')) return '🤢';
    if (name.contains('neuro') || name.contains('brain')) return '🧠';
    if (name.contains('derma') || name.contains('skin')) return '🧴';
    if (name.contains('onco') || name.contains('cancer')) return '🦠';

    return '💊'; // Default icon
  }

  // Save vendor selections to API
  Future<void> saveVendorSelections({
    required String token,
    required List<String> companyIds,
    required List<Map<String, dynamic>> categories,
    required List<Map<String, dynamic>> subCategories,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/vendor/selections'); // Adjust endpoint as needed

      final body = jsonEncode({
        'company_ids': companyIds,
        'categories': categories.map((cat) => cat['id']).toList(),
        'sub_categories': subCategories.map((subCat) => subCat['id']).toList(),
      });

      final response = await http.post(
        url,
        headers: getHeaders(token: token),
        body: body,
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(responseData['message'] ?? 'Failed to save selections');
      }
    } catch (e) {
      throw Exception('Failed to save selections: $e');
    }
  }

  // Logout
  Future<void> logoutUser(String token) async {
    try {
      final url = Uri.parse('$baseUrl/logout'); // Adjust endpoint as needed

      final response = await http.post(
        url,
        headers: getHeaders(token: token),
      );

      if (response.statusCode != 200) {
        // Still proceed with local logout even if API fails
        print('API logout failed but proceeding with local logout');
      }
    } catch (e) {
      // Silently handle logout errors, still proceed with local logout
      print('Logout API error: $e');
    }
  }


// In ApiService class
  Future<List<Product>> getProducts({
    String? search,
    String? category,
    String? company,
    int? page,
    int? limit,
  }) async {
    try {
      final Map<String, String> queryParams = {};

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (category != null && category.isNotEmpty) {
        queryParams['category'] = category;
      }
      if (company != null && company.isNotEmpty) {
        queryParams['company'] = company;
      }
      if (page != null) {
        queryParams['page'] = page.toString();
      }
      if (limit != null) {
        queryParams['limit'] = limit.toString();
      }

      final url = Uri.parse('$baseUrl/product').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(
        url,
        headers: getHeaders(),
      );

      final responseData = jsonDecode(response.body);
print("urlproduct===>$url");
print("response product===>${responseData}");
      if (response.statusCode == 200 && responseData['success'] == true) {
        final List<dynamic> productsData = responseData['data'] ?? [];
        return productsData.map((productJson) {
          return Product.fromJson(productJson);
        }).toList();
      } else {
        throw Exception(responseData['message'] ?? 'Failed to load vendors_products');
      }
    } catch (e) {
      print(e);
      print('Failed to load vendors_products: $e');
      throw Exception('Failed to load vendors_products: $e');
    }
  }

// Get vendors_products by category
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    try {
      final url = Uri.parse('$baseUrl/product?category=$categoryId');

      final response = await http.get(
        url,
        headers: getHeaders(),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        final List<dynamic> productsData = responseData['data'] ?? [];
        return productsData.map((productJson) {
          return Product.fromJson(productJson);
        }).toList();
      } else {
        throw Exception(responseData['message'] ?? 'Failed to load category vendors_products');
      }
    } catch (e) {
      throw Exception('Failed to load category vendors_products: $e');
    }
  }

// Get vendors_products by company
  Future<List<Product>> getProductsByCompany(String companyId) async {
    try {
      final url = Uri.parse('$baseUrl/product?company=$companyId');

      final response = await http.get(
        url,
        headers: getHeaders(),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        final List<dynamic> productsData = responseData['data'] ?? [];
        return productsData.map((productJson) {
          return Product.fromJson(productJson);
        }).toList();
      } else {
        throw Exception(responseData['message'] ?? 'Failed to load company vendors_products');
      }
    } catch (e) {
      throw Exception('Failed to load company vendors_products: $e');
    }
  }

// In your api_provider.dart file, add this method:

  Future<Map<String, dynamic>> getProductById(int productId) async {
    try {
      final url = Uri.parse('${baseUrl}/productByid/$productId');
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          // Add your authorization header if needed
          // 'Authorization': 'Bearer $token',
        },
      );

      
      print('productdetail url===>$url');
      print('productdetail Headers===>${getHeaders()}');
      print('productdetail Response===>${response.body}');
       

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData;
      } else {
        throw Exception('Failed to load product details. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching product by ID: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getLatestProducts({int limit = 10}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/products/latest?limit=$limit'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('$baseUrl/products/latest?limit=$limit');
      print(response.body);

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);

        // ✅ FIX 1: check "success" instead of "status"
        if (jsonResponse['success'] == true) {

          // ✅ FIX 2: access nested data -> data -> data
          final List<dynamic> products =
              jsonResponse['data']['data'] ?? [];

          return products
              .map((item) => item as Map<String, dynamic>)
              .toList();
        }
      }

      return [];
    } catch (e) {
      print('Error fetching latest products: $e');
      return [];
    }
  }

Future<Map<String, dynamic>> getVendorsForProduct(
  int productId, {
  int? agencyId, // 👈 optional rakha
}) async {
  try {
    print(productId);

    // 🔥 Dynamic query params
    final queryParams = {
      'product_id': productId.toString(),
      if (agencyId != null) 'vendor_id': agencyId.toString(),
    };

    final uri = Uri.parse('$baseUrl/vendors-by-product')
        .replace(queryParameters: queryParams);

    print('url of vender for product====>url: $uri');

    final response = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
    );

    print('response of vender for product====>${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      return {
        'success': false,
        'message': 'Server error: ${response.statusCode}'
      };
    }
  } catch (e) {
    print('Error fetching vendors: $e');
    return {'success': false, 'message': e.toString()};
  }
}
  Future<Map<String, dynamic>> getPackingsForProduct(int productId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/vendors_products/$productId/packings'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } catch (e) {
      print('Error fetching packings: $e');
      return {'success': false, 'message': e.toString()};
    }
  }


  Future<Map<String, dynamic>> syncCartItem(
      String userId,
      CartItem item,
      ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/cart/sync'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'product_id': item.productId,
          'vendor_id': item.vendorId,
          'packing_id': item.packingId,
          'quantity': item.quantity,
          'special_instructions': item.specialInstructions,
        }),
      );

print('c art item url====>${Uri.parse('$baseUrl/cart/sync')}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        return {
          'success': false,
          'message': 'Server error: ${response.statusCode}'
        };
      }
    } catch (e) {
      print('Error syncing cart: $e');
      return {'success': false, 'message': e.toString()};
    }
  }


  Future<ApiResponse> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return ApiResponse.success(json.decode(response.body));
      } else {
        return ApiResponse.error('Server error: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }

  Future<ApiResponse> post(String endpoint, {Map<String, dynamic>? data}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$endpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: data != null ? json.encode(data) : null,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse.success(json.decode(response.body));
      } else {
        return ApiResponse.error('Server error: ${response.statusCode}');
      }
    } catch (e) {
      return ApiResponse.error('Network error: $e');
    }
  }


  Future<Map<String, dynamic>> assignVendorProducts({
    required String vendorId,
    required List<String> companyIds,
    required List<String> categoryIds,
    required List<String> subCategoryIds,
    String? token,
  }) async {
    try {

      print("vendorId");
      print(vendorId);
      print(companyIds);
      print(categoryIds);
      print(subCategoryIds);
      final response = await http.post(
        Uri.parse('$baseUrl/vendors/assign-products'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'vendor_id': vendorId,
          'company_ids': companyIds,
          'category_ids': categoryIds,
          'sub_category_ids': subCategoryIds,
        }),
      );
print(response.body);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to assign products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error assigning products: $e');
    }
  }



  Future<List<MedicineModel>> getSuggestions() async {
    try {
      print("Fetching suggestions...");
      final response = await http.get(
        Uri.parse('${baseUrl}/products/suggestions'),
        headers: {
          'Accept': 'application/json',
        },
      );

      print("Suggestions response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['type'] == 'popular_searches' && data['data'] != null) {
          final List suggestions = data['data'];
          return suggestions.map((item) => MedicineModel.fromSuggestionJson(item)).toList();
        }
      }
      return [];
    } catch (e) {
      print("Error fetching suggestions: $e");
      return [];
    }
  }

  Future<List<MedicineModel>> searchProducts(String query, {int limit = 20}) async {
    try {
      print("Searching products with query: $query");
      final response = await http.get(
        Uri.parse('${baseUrl}/products/search?q=$query&limit=$limit'),
        headers: {
          'Accept': 'application/json',
        },
      );

      print("Search response status: ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == true && data['data'] != null) {
          if (data['data']['data'] != null) {
            final List products = data['data']['data'];
            return products.map((item) => MedicineModel.fromSearchJson(item)).toList();
          }
        }
      }
      return [];
    } catch (e) {
      print("Error searching products: $e");
      return [];
    }
  }




  // Add to cart API method
  Future<Map<String, dynamic>> addToCart({
    required int productId,
    required int quantity,
    String? packingType,
    int? vendorId,
    String? userId,
    String? token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/cart/add');

      final body = jsonEncode({
        'product_id': productId,
        'quantity': quantity,
        if (packingType != null) 'packing_type': packingType,
        if (vendorId != null) 'vendor_id': vendorId,
        if (userId != null) 'user_id': userId,
      });

      final response = await http.post(
        url,
        headers: getHeaders(token: token),
        body: body,
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to add to cart'
        };
      }
    } catch (e) {
      print('Error in addToCart: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

// Update cart item quantity
  Future<void> updateCartItem({
    required String cartItemId, // Change to String
    required int quantity,
    required String? userId,
    required String? token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/cart/update/$cartItemId');

      final body = jsonEncode({
        'quantity': quantity,
        if (userId != null) 'user_id': userId,
      });

      final response = await http.put(
        url,
        headers: getHeaders(token: token),
        body: body,
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        return ;
      }
    } catch (e) {
      print('Error in updateCartItem: $e');
      return ;
    }

  }

// Remove from cart
  Future<void> removeFromCart({
    required String cartItemId, // Change to String
    required String? userId,
    required String? token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/cart/$cartItemId');

      final body = jsonEncode({
        if (userId != null) 'user_id': userId,
      });


      final response = await http.delete(
        url,
        headers: getHeaders(token: token),
        body: body,
      );
      print('debug');
      print(response.body);
      print(body);
      print(url);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        return ;
      }
    } catch (e) {
      print('Error in removeFromCart: $e');
      return;
    }
  }

// Get user cart
  Future<Map<String, dynamic>> getUserCart({
    required String userId, // Change to String
    required String? token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/cart/$userId');

      final response = await http.get(
        url,
        headers: getHeaders(token: token),
      );
print('get cart url====>$url');
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to get cart'
        };
      }
    } catch (e) {
      print('Error in getUserCart: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

// Get cart count
  Future<Map<String, dynamic>> getCartCount({
    required String userId,
    String? token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/count/$userId');

      final response = await http.get(
        url,
        headers: getHeaders(token: token),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        return {'count': 0, 'success': false};
      }
    } catch (e) {
      print('Error in getCartCount: $e');
      return {'count': 0, 'success': false};
    }
  }
Future<Map<String, dynamic>> updateCartItemQuantity({
  required int cartItemId,
  required int quantity,
  int? addon, // ✅ FIX: String se int
  int? userId,
  String? token,
}) async {
  try {
    final url = Uri.parse('$baseUrl/cart/$cartItemId');

    final bodyData = {
      "quantity": quantity,
      if (addon != null) "addon": addon, // ✅ only if not null
    };

    // 🔥 DEBUG PRINTS
    print("===== UPDATE CART ITEM API =====");
    print("URL => $url");
    print("METHOD => PUT");
    print("HEADERS => {");
    print("  Content-Type: application/json");
    print("  Accept: application/json");
    if (token != null) {
      print("  Authorization: Bearer $token");
    }
    print("}");

    print("BODY MAP => $bodyData"); // 👈 check type here
    print("BODY JSON => ${jsonEncode(bodyData)}");

    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: jsonEncode(bodyData),
    );

    // 🔥 RESPONSE PRINT
    print("STATUS CODE => ${response.statusCode}");
    print("RESPONSE BODY => ${response.body}");
    print("================================");

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      return {
        "success": false,
        "message": "Failed to update quantity",
      };
    }
  } catch (e) {
    print("❌ ERROR in updateCartItemQuantity: $e");
    return {
      "success": false,
      "message": "Network error: $e",
    };
  }
}

// Clear user cart
  Future<Map<String, dynamic>> clearCart({
    required String userId,
    String? token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/cart/clear/$userId');

      final response = await http.delete(
        url,
        headers: getHeaders(token: token),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to clear cart'
        };
      }
    } catch (e) {
      print('Error in clearCart: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

// Bulk sync cart items (for syncing local cart after login)
  Future<Map<String, dynamic>> syncCartItems({
    required String userId,
    required List<Map<String, dynamic>> cartItems,
    String? token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/cart/sync');

      final body = jsonEncode({
        'user_id': userId,
        'items': cartItems,
      });

      final response = await http.post(
        url,
        headers: getHeaders(token: token),
        body: body,
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to sync cart'
        };
      }
    } catch (e) {
      print('Error in syncCartItems: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

// Apply coupon to cart
  Future<Map<String, dynamic>> applyCoupon({
    required String userId,
    required String couponCode,
    String? token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/cart/apply-coupon');

      final body = jsonEncode({
        'user_id': userId,
        'coupon_code': couponCode,
      });

      final response = await http.post(
        url,
        headers: getHeaders(token: token),
        body: body,
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to apply coupon'
        };
      }
    } catch (e) {
      print('Error in applyCoupon: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

// Remove coupon from cart
  Future<Map<String, dynamic>> removeCoupon({
    required String userId,
    String? token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/cart/remove-coupon');

      final body = jsonEncode({
        'user_id': userId,
      });

      final response = await http.post(
        url,
        headers: getHeaders(token: token),
        body: body,
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to remove coupon'
        };
      }
    } catch (e) {
      print('Error in removeCoupon: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }
// Paste this method inside your ApiService class in api_provider.dart
// (replace the existing addToCartApi method)

  Future<Map<String, dynamic>> addToCartApi({
    required int productId,
    required int userId,
    required int vendorId,
    required int vendorProductId,
    required int quantity,
    required String token,
    int? addon, // ✅ new optional addon qty
  }) async {
    try {
      final url = Uri.parse('$baseUrl/cart/add');

      print('=== API CALL DEBUG ===');
      print('URL: $url');
      print('Token: $token');

      final body = {
        "product_id": productId,
        "user_id": userId,
        "vendor_id": vendorId,
        "vendor_product_id": vendorProductId,
        "quantity": quantity,
        if (addon != null && addon > 0) "addon": addon, // ✅ only send if > 0
      };

      print('Request Body: $body');

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      print('Response Status Code: ${response.statusCode}');
      print('Response Headers: ${response.headers}');
      print('Response Body (first 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');

      if (response.body.trim().startsWith('<!DOCTYPE html>')) {
        print('ERROR: Server returned HTML instead of JSON');
        return {
          "success": false,
          "message": "Server error: Please check if the API endpoint exists and you're properly authenticated",
        };
      }

      final responseData = jsonDecode(response.body);
      print("API Response Data: $responseData");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      } else {
        return {
          "success": false,
          "message": responseData["message"] ?? "Failed to add to cart (Status: ${response.statusCode})",
        };
      }
    } catch (e) {
      print("Error in addToCartApi: $e");
      return {
        "success": false,
        "message": "Network error: $e",
      };
    }
  }  Future<Map<String, dynamic>> getCompanyDivisions({
    required int companyId,
    required String token,
    int page = 1,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/companies/$companyId/divisions?page=$page');

      final response = await http.get(
        url,
        headers: getHeaders(token: token),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to load company divisions'
        };
      }
    } catch (e) {
      print('Error getting company divisions: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }



  Future<Map<String, dynamic>> getBuyerAddresses({
    required String buyerId,
    required String token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/buyers/$buyerId/addresses');

      final response = await http.get(
        url,
        headers: getHeaders(token: token),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to load addresses'
        };
      }
    } catch (e) {
      print('Error getting addresses: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }


  Future<Map<String, dynamic>> createBuyerAddress({
    required String buyerId,
    required Map<String, dynamic> addressData,
    required String token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/buyers/$buyerId/addresses');

      final response = await http.post(
        url,
        headers: getHeaders(token: token),
        body: jsonEncode(addressData),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return responseData;
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to create address'
        };
      }
    } catch (e) {
      print('Error creating address: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }


  Future<Map<String, dynamic>> updateBuyerAddress({
    required String buyerId,
    required int addressId,
    required Map<String, dynamic> addressData,
    required String token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/buyers/$buyerId/addresses/$addressId');

      final response = await http.put(
        url,
        headers: getHeaders(token: token),
        body: jsonEncode(addressData),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to update address'
        };
      }
    } catch (e) {
      print('Error updating address: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }



  Future<Map<String, dynamic>> deleteBuyerAddress({
    required String buyerId,
    required int addressId,
    required String token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/buyers/$buyerId/addresses/$addressId');

      final response = await http.delete(
        url,
        headers: getHeaders(token: token),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to delete address'
        };
      }
    } catch (e) {
      print('Error deleting address: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }


  Future<Map<String, dynamic>> setDefaultShippingAddress({
    required String buyerId,
    required int addressId,
    required String token,
  }) async {
    try {
      final url = Uri.parse(
        '$baseUrl/buyers/$buyerId/addresses/$addressId/default-shipping',
      );

      final response = await http.patch(
        url,
        headers: getHeaders(token: token),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        return {
          'success': false,
          'message':
          responseData['message'] ?? 'Failed to set default shipping'
        };
      }
    } catch (e) {
      print('Error setting default shipping: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }




Future<Map<String, dynamic>> placeOrder({
  required int buyerId,
  required int vendorId,
  required int shippingAddressId,
  required int billingAddressId,
  required String paymentMethod,
  required List<Map<String, dynamic>> items,
  String? referredBy,
  String? couponCode,
  String? token,
}) async {
  try {
    final url = Uri.parse('$baseUrl/buyers/$buyerId/orders');

    final Map<String, dynamic> requestBody = {
      "vendor_id": vendorId,
      "shipping_address_id": shippingAddressId,
      "billing_address_id": billingAddressId,
      "payment_method": paymentMethod,
      "referred_by": referredBy,
      "items": items.map((item) => {
        "vendor_product_id": item['packing_id'],
        "product_name": item['product_name'],
        "quantity": item['quantity'],
        "addon": item['addon'] ?? 0,
        "unit_price": item['price'],
        "gst_percentage": item['gst_percentage'],
      }).toList(),
    };

    // ✅ Coupon
    if (couponCode != null && couponCode.isNotEmpty) {
      requestBody['coupon_code'] = couponCode;
    }

    // ✅ 🔥 FIX: Referral add karo
    if (referredBy != null && referredBy.isNotEmpty) {
      requestBody['referred_by'] = referredBy;
    }

    // ================= DEBUG LOG =================
    print("🚀 ================= PLACE ORDER API =================");
    print("👉 URL: $url");

    print("👉 HEADERS:");
    print({
      "Content-Type": "application/json",
      "Accept": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    });

    print("👉 REQUEST BODY:");
    print(const JsonEncoder.withIndent('  ').convert(requestBody));

    // ================= API CALL =================
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        if (token != null) "Authorization": "Bearer $token",
      },
      body: jsonEncode(requestBody),
    );

    // ================= RESPONSE LOG =================
    print("✅ ================= RESPONSE =================");
    print("👉 Status Code: ${response.statusCode}");
    print("👉 Raw Body: ${response.body}");

    dynamic decoded;
    try {
      decoded = jsonDecode(response.body);
      print("👉 Decoded JSON:");
      print(const JsonEncoder.withIndent('  ').convert(decoded));
    } catch (e) {
      print("⚠️ Response is not valid JSON");
    }

    print("===============================================");

    // ================= RESULT =================
    if (response.statusCode == 200 || response.statusCode == 201) {
      return {
        "success": true,
        "data": decoded,
      };
    } else {
      return {
        "success": false,
        "message": decoded?['message'] ?? "Failed to place order",
      };
    }
  } catch (e) {
    print("❌ ERROR: $e");
    return {
      "success": false,
      "message": "Network error: $e",
    };
  }
}// In lib/app/data/providers/api_provider.dart

  Future<Map<String, dynamic>> getBuyerOrders({
    required String buyerId,
    required String token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/buyers/$buyerId/orders');

      final response = await http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );
print('url of order details====>$url');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "success": false,
          "message": "Failed to fetch orders",
        };
      }
    } catch (e) {
      print("Error fetching orders: $e");
      return {
        "success": false,
        "message": "Network error: $e",
      };
    }
  }

  Future<Map<String, dynamic>> cancelOrder({
    required String orderId,
    required String reason,
    required String token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/orders/$orderId/cancel');

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"cancellation_reason": reason}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"success": false, "message": "Failed to cancel order"};
      }
    } catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }
  }

  Future<Map<String, dynamic>> requestReturn({
    required String orderId,
    required String reason,
    required String token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/api/orders/$orderId/return');

      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({"return_reason": reason}),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {"success": false, "message": "Failed to request return"};
      }
    } catch (e) {
      return {"success": false, "message": "Network error: $e"};
    }
  }

  // In your ApiService class, update the syncCart method:

  Future<Map<String, dynamic>> syncCart({
    required List<Map<String, dynamic>> cartItems,
    required String token,
  }) async {
    try {
      // Get user ID from token or storage
      final userId = await getUserId();

      if (userId == null) {
        return {'success': false, 'message': 'User ID not found'};
      }

      // Transform cart items to match the required payload structure
      final List<Map<String, dynamic>> formattedCartItems = cartItems.map((item) {
        return {
          'product_id': item['productId'],
          'product_name': item['productName'],
          'vendor_id': item['vendorId'],
          'vendor_name': item['vendorName'],
          'packing_id': item['packingId'] ?? 1,
          'packing_type': item['packingName'] ?? 'Standard',
          'quantity': item['quantity'],
          'price': item['price'],
          'product_image': item['image'] ?? '',
          'gst_percentage': item['gstPercentage'] ?? 0.0,
        };
      }).toList();

      print('🔄 Syncing cart with server...');
      print('📦 User ID: $userId');
      print('📦 Formatted cart items: $formattedCartItems');

      final response = await http.post(
        Uri.parse('$baseUrl/cart/sync/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'user_id': userId,
          'cart_items': formattedCartItems,
        }),
      );

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['success'] == true) {
          print('✅ Cart synced successfully');
          print('✅ Added: ${responseData['data']?['added_count'] ?? 0} items');
          print('✅ Skipped: ${responseData['data']?['skipped_count'] ?? 0} items');
        } else {
          print('❌ Cart sync failed: ${responseData['message']}');
        }

        return responseData;
      } else {
        print('❌ Failed to sync cart: ${response.statusCode}');
        print('❌ Response: ${response.body}');

        // Try to parse error response
        try {
          final errorData = json.decode(response.body);
          return {
            'success': false,
            'message': errorData['message'] ?? 'Failed to sync cart',
            'errors': errorData['errors'] ?? {}
          };
        } catch (e) {
          return {
            'success': false,
            'message': 'Failed to sync cart. Status code: ${response.statusCode}'
          };
        }
      }
    } catch (e) {
      print('❌ Error syncing cart: $e');
      return {'success': false, 'message': e.toString()};
    }
  }

// Helper method to get user ID
  Future<int?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString('user_data');

      if (userDataString != null && userDataString.isNotEmpty) {
        final userData = json.decode(userDataString);

        // Try different possible ID fields
        int? userId = userData['id'] ??
            userData['user_id'] ??
            userData['userId'] ??
            null;

        print('📋 Retrieved user ID: $userId');
        return userId;
      }
    } catch (e) {
      print('❌ Error getting user ID: $e');
    }
    return null;
  }



  // ==================== FORGOT PASSWORD APIs ====================

  // Send OTP to email
  Future<Map<String, dynamic>> sendOtp(String email) async {
    try {
      final url = Uri.parse('$baseUrl/password/forgot/send-otp');

      final body = jsonEncode({
        'email': email,
      });

      final response = await http.post(
        url,
        headers: getHeaders(),
        body: body,
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to send OTP',
        };
      }
    } catch (e) {
      print('Error in sendOtp: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Verify OTP
  Future<Map<String, dynamic>> verifyOtp(String email, String otp) async {
    try {
      final url = Uri.parse('$baseUrl/password/forgot/verify-otp');

      final body = jsonEncode({
        'email': email,
        'otp': otp,
      });

      final response = await http.post(
        url,
        headers: getHeaders(),
        body: body,
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to verify OTP',
        };
      }
    } catch (e) {
      print('Error in verifyOtp: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Resend OTP
  Future<Map<String, dynamic>> resendOtp(String email) async {
    try {
      final url = Uri.parse('$baseUrl/password/forgot/resend-otp');

      final body = jsonEncode({
        'email': email,
      });

      final response = await http.post(
        url,
        headers: getHeaders(),
        body: body,
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to resend OTP',
        };
      }
    } catch (e) {
      print('Error in resendOtp: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Reset Password
  Future<Map<String, dynamic>> resetPassword({
    required String email,
    required String resetToken,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/password/forgot/reset');

      final body = jsonEncode({
        'email': email,
        'reset_token': resetToken,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });

      final response = await http.post(
        url,
        headers: getHeaders(),
        body: body,
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to reset password',
        };
      }
    } catch (e) {
      print('Error in resetPassword: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  // Change Password (Authenticated)
  Future<Map<String, dynamic>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
    String? token,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/password/change');

      final body = jsonEncode({
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      });

      final response = await http.post(
        url,
        headers: getHeaders(token: token),
        body: body,
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return responseData;
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to change password',
        };
      }
    } catch (e) {
      print('Error in changePassword: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }



  Future<Map<String, dynamic>> registerDeviceToken({
    required int userId,
    required String deviceToken,
    required String deviceType,
    required String authToken,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/device/register-token');

      final body = jsonEncode({
        'user_id': userId,
        'device_token': deviceToken,
        'device_type': deviceType, // 'ios', 'android', 'web'
        'device_name': await _getDeviceName(),
      });

      final response = await http.post(
        url,
        headers: getHeaders(token: authToken),
        body: body,
      );
print(url);
print(body);
print(response.body);
// print(url);
      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('✅ Device token registered successfully');
        return {'success': true, 'data': responseData};
      } else {
        print('❌ Failed to register device token: ${responseData['message']}');
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to register device token'
        };
      }
    } catch (e) {
      print('❌ Error registering device token: $e');
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Update device token (when FCM refreshes token)
  Future<Map<String, dynamic>> updateDeviceToken({
    required int userId,
    required String newToken,
    required String authToken,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/device/register-token');

      final body = jsonEncode({
        'user_id': userId,
        'device_token': newToken,
      });

      final response = await http.put(
        url,
        headers: getHeaders(token: authToken),
        body: body,
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('✅ Device token updated successfully');
        return {'success': true, 'data': responseData};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to update device token'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Remove device token (on logout)
  Future<Map<String, dynamic>> removeDeviceToken({
    required int userId,
    required String authToken,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/device/remove-token');

      final body = jsonEncode({
        'user_id': userId,
      });

      final response = await http.post(
        url,
        headers: getHeaders(token: authToken),
        body: body,
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        print('✅ Device token removed successfully');
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to remove device token'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }





  Future<String> _getDeviceName() async {
    // You can use device_info_plus package to get detailed device info
    // For now, return a simple string
    if (GetPlatform.isIOS) {
      return 'iOS Device';
    } else if (GetPlatform.isAndroid) {
      return 'Android Device';
    } else {
      return 'Unknown Device';
    }
  }

  // ==================== NOTIFICATION APIs ====================

  /// Get user notifications
  Future<Map<String, dynamic>> getUserNotifications({
    required int userId,
    required String authToken,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/notifications?user_id=$userId&page=$page&limit=$limit');

      final response = await http.get(
        url,
        headers: getHeaders(token: authToken),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': responseData['data'] ?? [],
          'total': responseData['total'] ?? 0,
          'unread_count': responseData['unread_count'] ?? 0,
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to get notifications'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Mark notification as read
  Future<Map<String, dynamic>> markNotificationAsRead({
    required int notificationId,
    required String authToken,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/notifications/$notificationId/read');

      final response = await http.patch(
        url,
        headers: getHeaders(token: authToken),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to mark as read'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Mark all notifications as read
  Future<Map<String, dynamic>> markAllNotificationsAsRead({
    required int userId,
    required String authToken,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/notifications/read-all');

      final body = jsonEncode({
        'user_id': userId,
      });

      final response = await http.post(
        url,
        headers: getHeaders(token: authToken),
        body: body,
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'count': responseData['count'] ?? 0
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to mark all as read'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }




  /// Delete notification
  Future<Map<String, dynamic>> deleteNotification({
    required int notificationId,
    required String authToken,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/notifications/$notificationId');

      final response = await http.delete(
        url,
        headers: getHeaders(token: authToken),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to delete notification'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  /// Get unread notification count
  Future<Map<String, dynamic>> getUnreadNotificationCount({
    required int userId,
    required String authToken,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/notifications/unread-count?user_id=$userId');

      final response = await http.get(
        url,
        headers: getHeaders(token: authToken),
      );

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'unread_count': responseData['unread_count'] ?? 0
        };
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to get unread count'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

}

class ApiResponse {
  final bool success;
  final dynamic data;
  final String? error;

  ApiResponse({required this.success, this.data, this.error});

  factory ApiResponse.success(dynamic data) => ApiResponse(
    success: true,
    data: data,
  );

  factory ApiResponse.error(String error) => ApiResponse(
    success: false,
    error: error,
  );
}
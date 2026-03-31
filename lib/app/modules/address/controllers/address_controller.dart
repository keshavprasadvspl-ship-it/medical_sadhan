// lib/app/modules/address/controllers/address_controller.dart
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import '../../../data/models/address_model.dart';
import '../../../data/providers/api_provider.dart';
import '../../../services/storage_service.dart';

class AddressController extends GetxController {
  final ApiService _apiService = Get.find<ApiService>();
  final StorageService _storageService = Get.find<StorageService>();

  final addresses = <AddressModel>[].obs;
  final isLoading = false.obs;
  final isAddingAddress = false.obs;
  final isEditingAddress = false.obs;
  final isGettingLocation = false.obs;
  final selectedAddress = Rxn<AddressModel>();

  // Location coordinates
  final currentLatitude = Rxn<double>();
  final currentLongitude = Rxn<double>();

  // Form controllers
  final labelController = TextEditingController();
  final contactPersonController = TextEditingController();
  final contactPhoneController = TextEditingController();
  final contactEmailController = TextEditingController();
  final addressLine1Controller = TextEditingController();
  final addressLine2Controller = TextEditingController();
  final landmarkController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();
  final countryController = TextEditingController(text: 'India');

  final selectedAddressLabel = 'Home'.obs;
  final makeDefault = false.obs;

  // Address label options
  final addressLabels = ['Home', 'Office', 'Other'];

  // Form key for validation
  final formKey = GlobalKey<FormState>();

  // Editing address ID
  int? editingAddressId;

  @override
  void onInit() {
    super.onInit();
    loadAddresses();
    _checkLocationPermission();
  }

  @override
  void onClose() {
    // Dispose all text controllers
    labelController.dispose();
    contactPersonController.dispose();
    contactPhoneController.dispose();
    contactEmailController.dispose();
    addressLine1Controller.dispose();
    addressLine2Controller.dispose();
    landmarkController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    countryController.dispose();
    super.onClose();
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar(
        'Location Services Disabled',
        'Please enable location services to use this feature',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar(
          'Location Permission Denied',
          'Please grant location permission to use this feature',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar(
        'Location Permission Permanently Denied',
        'Please enable location permission from app settings',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  Future<void> loadAddresses() async {
    isLoading.value = true;

    try {
      final user = await _storageService.getUser();
      final token = await _storageService.getToken();

      if (user != null && token != null) {
        final buyerId = user['id'];
        final result = await _apiService.getBuyerAddresses(
          buyerId: buyerId.toString(),
          token: token,
        );

        print('Addresses API Response: $result');

        if (result['success'] == true && result['data'] != null) {
          final List addressesData = result['data'];
          addresses.value = addressesData
              .map((json) => AddressModel.fromJson(json))
              .toList();

          // Auto-select default shipping address if available
          final defaultAddress = addresses.firstWhereOrNull(
                  (addr) => addr.isDefaultShipping
          );

          if (defaultAddress != null) {
            selectedAddress.value = defaultAddress;
          } else if (addresses.isNotEmpty) {
            selectedAddress.value = addresses.first;
          }
        }
      }
    } catch (e) {
      print('Error loading addresses: $e');
      Get.snackbar(
        'Error',
        'Failed to load addresses',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void selectAddress(AddressModel address) {
    selectedAddress.value = address;
    Get.back(result: address);
  }

  Future<void> setDefaultAddress(int addressId) async {
    try {
      final user = await _storageService.getUser();
      final token = await _storageService.getToken();

      if (user != null && token != null) {
        final buyerId = user['id'];
        final result = await _apiService.setDefaultShippingAddress(
          buyerId: buyerId.toString(),
          addressId: addressId,
          token: token,
        );

        if (result['success'] == true) {
          await loadAddresses();

          Get.snackbar(
            'Success',
            'Default address updated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      }
    } catch (e) {
      print('Error setting default address: $e');
      Get.snackbar(
        'Error',
        'Failed to set default address',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> deleteAddress(int addressId) async {
    // Don't allow deletion if it's the only address
    if (addresses.length <= 1) {
      Get.snackbar(
        'Cannot Delete',
        'You must have at least one delivery address',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final addressToDelete = addresses.firstWhere((addr) => addr.id == addressId);

    Get.defaultDialog(
      title: 'Delete Address',
      content: Column(
        children: [
          const Text('Are you sure you want to delete this address?'),
          const SizedBox(height: 10),
          Text(
            addressToDelete.fullAddress,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();

        try {
          final user = await _storageService.getUser();
          final token = await _storageService.getToken();

          if (user != null && token != null) {
            final buyerId = user['id'];
            final result = await _apiService.deleteBuyerAddress(
              buyerId: buyerId.toString(),
              addressId: addressId,
              token: token,
            );

            if (result['success'] == true) {
              await loadAddresses();

              Get.snackbar(
                'Address Deleted',
                'Address has been removed successfully',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );
            }
          }
        } catch (e) {
          print('Error deleting address: $e');
          Get.snackbar(
            'Error',
            'Failed to delete address',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      },
    );
  }

  void startAddingAddress() {
    resetForm();
    isAddingAddress.value = true;
    isEditingAddress.value = false;
    editingAddressId = null;
  }

  void startEditingAddress(AddressModel address) {
    // Fill form with address data
    labelController.text = address.addressLabel;
    contactPersonController.text = address.contactPerson;
    contactPhoneController.text = address.contactPhone;
    contactEmailController.text = address.contactEmail ?? '';
    addressLine1Controller.text = address.addressLine1;
    addressLine2Controller.text = address.addressLine2 ?? '';
    landmarkController.text = address.landmark ?? '';
    cityController.text = address.city;
    stateController.text = address.state;
    pincodeController.text = address.pincode;
    countryController.text = address.country;

    // Set coordinates if available
    if (address.locationLat != null) {
      currentLatitude.value = double.tryParse(address.locationLat!);
    }
    if (address.locationLng != null) {
      currentLongitude.value = double.tryParse(address.locationLng!);
    }

    selectedAddressLabel.value = address.addressLabel;
    makeDefault.value = address.isDefaultShipping;

    editingAddressId = address.id;
    isEditingAddress.value = true;
    isAddingAddress.value = true;
  }

  void resetForm() {
    labelController.clear();
    contactPersonController.clear();
    contactPhoneController.clear();
    contactEmailController.clear();
    addressLine1Controller.clear();
    addressLine2Controller.clear();
    landmarkController.clear();
    cityController.clear();
    stateController.clear();
    pincodeController.clear();
    countryController.text = 'India';

    currentLatitude.value = null;
    currentLongitude.value = null;

    selectedAddressLabel.value = 'Home';
    makeDefault.value = false;
    editingAddressId = null;
  }

  Future<void> useCurrentLocation() async {
    isGettingLocation.value = true;

    try {
      // Check and request permissions
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar(
          'Location Services Disabled',
          'Please enable location services',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar(
            'Permission Denied',
            'Location permission is required',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          'Permission Permanently Denied',
          'Please enable location from app settings',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      // Get current position
      Get.snackbar(
        'Getting Location',
        'Fetching your current location...',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      currentLatitude.value = position.latitude;
      currentLongitude.value = position.longitude;

      // Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // Fill form with address details
        addressLine1Controller.text = '${place.street ?? ''}'.trim();

        // Build thorough address
        String subLocality = place.subLocality ?? '';
        String locality = place.locality ?? '';
        if (subLocality.isNotEmpty && !addressLine1Controller.text.contains(subLocality)) {
          addressLine1Controller.text = addressLine1Controller.text.isNotEmpty
              ? '${addressLine1Controller.text}, $subLocality'
              : subLocality;
        }

        cityController.text = place.locality ?? place.subAdministrativeArea ?? '';
        stateController.text = place.administrativeArea ?? '';
        pincodeController.text = place.postalCode ?? '';
        countryController.text = place.country ?? 'India';

        // If no specific address line, use a combination
        if (addressLine1Controller.text.isEmpty) {
          List<String> addressParts = [];
          if (place.thoroughfare != null) addressParts.add(place.thoroughfare!);
          if (place.subThoroughfare != null) addressParts.add(place.subThoroughfare!);
          if (place.subLocality != null) addressParts.add(place.subLocality!);

          addressLine1Controller.text = addressParts.join(', ');
        }

        Get.snackbar(
          'Location Fetched',
          'Address details have been filled from your current location',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        throw Exception('Could not get address from coordinates');
      }

    } catch (e) {
      print('Error getting location: $e');

      String errorMessage = 'Failed to get your location';
      if (e.toString().contains('timeout')) {
        errorMessage = 'Location request timed out. Please try again.';
      }

      Get.snackbar(
        'Location Error',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isGettingLocation.value = false;
    }
  }

  Future<void> saveAddress() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      final user = await _storageService.getUser();
      final token = await _storageService.getToken();

      if (user == null || token == null) {
        Get.snackbar(
          'Error',
          'Please login to manage addresses',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final buyerId = user['id'].toString();

      final addressData = {
        'address_type': 'shipping',
        'address_label': selectedAddressLabel.value,
        'address_line1': addressLine1Controller.text.trim(),
        'address_line2': addressLine2Controller.text.trim().isEmpty
            ? null : addressLine2Controller.text.trim(),
        'landmark': landmarkController.text.trim().isEmpty
            ? null : landmarkController.text.trim(),
        'city': cityController.text.trim(),
        'state': stateController.text.trim(),
        'pincode': pincodeController.text.trim(),
        'country': countryController.text.trim(),
        'contact_person': contactPersonController.text.trim(),
        'contact_phone': contactPhoneController.text.trim(),
        'contact_email': contactEmailController.text.trim().isEmpty
            ? null : contactEmailController.text.trim(),
        'is_default_shipping': makeDefault.value,
        'is_default_billing': false,
        'location_lat': currentLatitude.value?.toString(),
        'location_lng': currentLongitude.value?.toString(),
      };

      Map<String, dynamic> result;

      if (isEditingAddress.value && editingAddressId != null) {
        // Update existing address
        result = await _apiService.updateBuyerAddress(
          buyerId: buyerId,
          addressId: editingAddressId!,
          addressData: addressData,
          token: token,
        );

        if (result['success'] == true) {
          Get.snackbar(
            'Success',
            'Address updated successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      } else {
        // Add new address
        result = await _apiService.createBuyerAddress(
          buyerId: buyerId,
          addressData: addressData,
          token: token,
        );

        if (result['success'] == true) {
          Get.snackbar(
            'Success',
            'Address added successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      }

      if (result['success'] == true) {
        await loadAddresses();
        resetForm();
        isAddingAddress.value = false;
        isEditingAddress.value = false;
      } else {
        throw Exception(result['message'] ?? 'Failed to save address');
      }

    } catch (e) {
      print('Error saving address: $e');
      Get.snackbar(
        'Error',
        'Failed to save address. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void cancelForm() {
    resetForm();
    isAddingAddress.value = false;
    isEditingAddress.value = false;
  }

  String? validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter full name';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter phone number';
    }
    final phoneRegex = RegExp(r'^[6-9]\d{9}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'\D'), ''))) {
      return 'Please enter a valid 10-digit Indian phone number';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value != null && value.isNotEmpty) {
      if (!GetUtils.isEmail(value)) {
        return 'Please enter a valid email';
      }
    }
    return null;
  }

  String? validateAddressLine1(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter address line 1';
    }
    if (value.length < 5) {
      return 'Address must be at least 5 characters';
    }
    return null;
  }

  String? validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter city';
    }
    return null;
  }

  String? validateState(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter state';
    }
    return null;
  }

  String? validatePincode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter pincode';
    }
    final pincodeRegex = RegExp(r'^\d{6}$');
    if (!pincodeRegex.hasMatch(value)) {
      return 'Please enter a valid 6-digit pincode';
    }
    return null;
  }

  void navigateBackWithSelectedAddress() {
    if (selectedAddress.value != null) {
      Get.back(result: selectedAddress.value);
    } else {
      Get.back();
    }
  }

  // Helper method to get color based on address label
  Color getAddressLabelColor(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return Colors.green;
      case 'office':
        return Colors.blue;
      case 'other':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  // Helper method to get icon based on address label
  IconData getAddressLabelIcon(String label) {
    switch (label.toLowerCase()) {
      case 'home':
        return Icons.home;
      case 'office':
        return Icons.work;
      case 'other':
        return Icons.location_on;
      default:
        return Icons.place;
    }
  }
}
// lib/app/modules/checkout/views/add_address_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../controllers/checkout_controller.dart';
import '../../../data/models/address_model.dart';

class AddAddressView extends GetView<CheckoutController> {
  final AddressModel? address;

  const AddAddressView({Key? key, this.address}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final isGettingLocation = false.obs;

    // Controllers
    final labelController = TextEditingController(
      text: address?.addressLabel ?? 'Home',
    );
    final contactPersonController = TextEditingController(
      text: address?.contactPerson ?? '',
    );
    final contactPhoneController = TextEditingController(
      text: address?.contactPhone ?? '',
    );
    final contactEmailController = TextEditingController(
      text: address?.contactEmail ?? '',
    );
    final addressLine1Controller = TextEditingController(
      text: address?.addressLine1 ?? '',
    );
    final addressLine2Controller = TextEditingController(
      text: address?.addressLine2 ?? '',
    );
    final landmarkController = TextEditingController(
      text: address?.landmark ?? '',
    );
    final cityController = TextEditingController(text: address?.city ?? '');
    final stateController = TextEditingController(text: address?.state ?? '');
    final pincodeController = TextEditingController(
      text: address?.pincode ?? '',
    );
    final countryController = TextEditingController(
      text: address?.country ?? 'India',
    );

    // Location coordinates
    final currentLatitude =
        (address?.locationLat != null
                ? double.tryParse(address!.locationLat!)
                : null)
            .obs;
    final currentLongitude =
        (address?.locationLng != null
                ? double.tryParse(address!.locationLng!)
                : null)
            .obs;

    // Observable values
    final selectedType = (address?.addressLabel ?? 'Home').obs;
    final isDefaultShipping = (address?.isDefaultShipping ?? false).obs;

    // Address type options
    final addressTypes = ['Home', 'Office', 'Other'];

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
              color: Color(0xFF111261),
            ),
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          address == null ? 'Add New Address' : 'Edit Address',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF111261),
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () => _saveAddress(formKey, {
              'labelController': labelController,
              'contactPersonController': contactPersonController,
              'contactPhoneController': contactPhoneController,
              'contactEmailController': contactEmailController,
              'addressLine1Controller': addressLine1Controller,
              'addressLine2Controller': addressLine2Controller,
              'landmarkController': landmarkController,
              'cityController': cityController,
              'stateController': stateController,
              'pincodeController': pincodeController,
              'countryController': countryController,
              'selectedType': selectedType,
              'isDefaultShipping': isDefaultShipping,
              'currentLatitude': currentLatitude,
              'currentLongitude': currentLongitude,
            }),
            child: Text(
              address == null ? 'Save' : 'Update',
              style: const TextStyle(
                color: Color(0xFF0B630B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Address Label Selection
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF111261).withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Address Label *',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111261),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: addressTypes.map((type) {
                      return Expanded(
                        child: Obx(
                          () => GestureDetector(
                            onTap: () => selectedType.value = type,
                            child: Container(
                              margin: EdgeInsets.only(
                                right: type != addressTypes.last ? 8 : 0,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: selectedType.value == type
                                    ? _getAddressLabelColor(
                                        type,
                                      ).withOpacity(0.1)
                                    : const Color(0xFFF5F5F5),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: selectedType.value == type
                                      ? _getAddressLabelColor(type)
                                      : Colors.transparent,
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _getAddressLabelIcon(type),
                                    size: 16,
                                    color: selectedType.value == type
                                        ? _getAddressLabelColor(type)
                                        : Colors.grey,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    type,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: selectedType.value == type
                                          ? FontWeight.w600
                                          : FontWeight.normal,
                                      color: selectedType.value == type
                                          ? _getAddressLabelColor(type)
                                          : Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Contact Details Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF111261).withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contact Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111261),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Full Name
                  TextFormField(
                    controller: contactPersonController,
                    decoration: InputDecoration(
                      labelText: 'Full Name *',
                      hintText: 'Enter your full name',
                      prefixIcon: const Icon(Icons.person_outline, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    validator: _validateFullName,
                  ),

                  const SizedBox(height: 16),

                  // Phone Number
                  TextFormField(
                    controller: contactPhoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    decoration: InputDecoration(
                      labelText: 'Mobile Number *',
                      hintText: 'Enter 10-digit mobile number',
                      prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      counterText: '',
                    ),
                    validator: _validatePhoneNumber,
                  ),

                  const SizedBox(height: 16),

                  // Email
                  TextFormField(
                    controller: contactEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email (Optional)',
                      hintText: 'Enter email address',
                      prefixIcon: const Icon(Icons.email_outlined, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    validator: _validateEmail,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Address Details Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF111261).withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Address Details',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF111261),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Address Line 1
                  TextFormField(
                    controller: addressLine1Controller,
                    decoration: InputDecoration(
                      labelText: 'Address Line 1 *',
                      hintText: 'House/Flat No., Building Name',
                      prefixIcon: const Icon(Icons.home_outlined, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    validator: _validateAddressLine1,
                  ),

                  const SizedBox(height: 16),

                  // Address Line 2
                  TextFormField(
                    controller: addressLine2Controller,
                    decoration: InputDecoration(
                      labelText: 'Address Line 2 (Optional)',
                      hintText: 'Street, Area',
                      prefixIcon: const Icon(
                        Icons.location_on_outlined,
                        size: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Landmark
                  TextFormField(
                    controller: landmarkController,
                    decoration: InputDecoration(
                      labelText: 'Landmark (Optional)',
                      hintText: 'Nearby famous place',
                      prefixIcon: const Icon(Icons.place_outlined, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: const Color(0xFFF5F5F5),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // City, State Row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: cityController,
                          decoration: InputDecoration(
                            labelText: 'City *',
                            hintText: 'City',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          validator: _validateCity,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: stateController,
                          decoration: InputDecoration(
                            labelText: 'State *',
                            hintText: 'State',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          validator: _validateState,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Pincode and Country Row
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: pincodeController,
                          keyboardType: TextInputType.number,
                          maxLength: 6,
                          decoration: InputDecoration(
                            labelText: 'Pincode *',
                            hintText: '6-digit pincode',
                            prefixIcon: const Icon(Icons.pin_drop, size: 20),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            counterText: '',
                          ),
                          validator: _validatePincode,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: countryController,
                          decoration: InputDecoration(
                            labelText: 'Country *',
                            hintText: 'Country',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF5F5F5),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                          ),
                          readOnly: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Coordinates display if available
                  Obx(() {
                    if (currentLatitude.value != null &&
                        currentLongitude.value != null) {
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.blue,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Location Coordinates',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue,
                                    ),
                                  ),
                                  Text(
                                    '${currentLatitude.value?.toStringAsFixed(6)}, ${currentLongitude.value?.toStringAsFixed(6)}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Use Current Location Button
            Obx(
              () => isGettingLocation.value
                  ? Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(color: Color(0xFF0B630B)),
                            SizedBox(height: 12),
                            Text(
                              'Fetching your location...',
                              style: TextStyle(
                                color: Color(0xFF111261),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF111261).withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: OutlinedButton.icon(
                        onPressed: () => _useCurrentLocation(
                          isGettingLocation,
                          addressLine1Controller,
                          addressLine2Controller,
                          cityController,
                          stateController,
                          pincodeController,
                          countryController,
                          currentLatitude,
                          currentLongitude,
                        ),
                        icon: const Icon(Icons.my_location),
                        label: const Text('Use Current Location'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF111261),
                          side: const BorderSide(color: Color(0xFF111261)),
                          minimumSize: const Size(double.infinity, 48),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
            ),

            const SizedBox(height: 16),

            // Default Address Option
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF111261).withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Obx(
                () => Row(
                  children: [
                    Checkbox(
                      value: isDefaultShipping.value,
                      onChanged: (value) {
                        isDefaultShipping.value = value ?? false;
                      },
                      activeColor: const Color(0xFF0B630B),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Set as default shipping address',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF111261),
                            ),
                          ),
                          Text(
                            'This address will be selected by default for checkout',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 80), // Extra space for bottom padding
          ],
        ),
      ),
    );
  }

  // Geolocation Methods
  Future<void> _useCurrentLocation(
    RxBool isGettingLocation,
    TextEditingController addressLine1Controller,
    TextEditingController addressLine2Controller,
    TextEditingController cityController,
    TextEditingController stateController,
    TextEditingController pincodeController,
    TextEditingController countryController,
      Rx<double?> currentLatitude,
      Rx<double?> currentLongitude,

      ) async {
    isGettingLocation.value = true;

    try {
      // Check location services
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showErrorSnackbar(
          'Location Services Disabled',
          'Please enable location services',
        );
        return;
      }

      // Check permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showErrorSnackbar(
            'Permission Denied',
            'Location permission is required',
          );
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showErrorSnackbar(
          'Permission Permanently Denied',
          'Please enable location from app settings',
        );
        return;
      }

      // Get current position
      _showInfoSnackbar(
        'Getting Location',
        'Fetching your current location...',
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

        // Build address line 1
        List<String> addressParts = [];
        if (place.street != null && place.street!.isNotEmpty) {
          addressParts.add(place.street!);
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }
        addressLine1Controller.text = addressParts.join(', ');

        // Address line 2 (locality)
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressLine2Controller.text = place.locality!;
        }

        // City
        cityController.text =
            place.locality ?? place.subAdministrativeArea ?? '';

        // State
        stateController.text = place.administrativeArea ?? '';

        // Pincode
        pincodeController.text = place.postalCode ?? '';

        // Country
        if (place.country != null && place.country!.isNotEmpty) {
          countryController.text = place.country!;
        }

        _showSuccessSnackbar(
          'Location Fetched',
          'Address details filled from your location',
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

      _showErrorSnackbar('Location Error', errorMessage);
    } finally {
      isGettingLocation.value = false;
    }
  }

  // Validation Methods
  String? _validateFullName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter full name';
    }
    if (value.length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  String? _validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter phone number';
    }
    final phoneRegex = RegExp(r'^[6-9]\d{9}$');
    if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'\D'), ''))) {
      return 'Please enter a valid 10-digit Indian phone number';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value != null && value.isNotEmpty) {
      if (!GetUtils.isEmail(value)) {
        return 'Please enter a valid email';
      }
    }
    return null;
  }

  String? _validateAddressLine1(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter address line 1';
    }
    if (value.length < 5) {
      return 'Address must be at least 5 characters';
    }
    return null;
  }

  String? _validateCity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter city';
    }
    return null;
  }

  String? _validateState(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter state';
    }
    return null;
  }

  String? _validatePincode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter pincode';
    }
    final pincodeRegex = RegExp(r'^\d{6}$');
    if (!pincodeRegex.hasMatch(value)) {
      return 'Please enter a valid 6-digit pincode';
    }
    return null;
  }

  // Snackbar Helpers
  void _showErrorSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void _showSuccessSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _showInfoSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      duration: const Duration(seconds: 1),
    );
  }

  // Color and Icon Helpers
  Color _getAddressLabelColor(String label) {
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

  IconData _getAddressLabelIcon(String label) {
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

  void _saveAddress(GlobalKey<FormState> formKey, Map controllers) {
    if (formKey.currentState!.validate()) {
      final addressData = {
        'address_type': 'shipping',
        'address_label': controllers['selectedType'].value,
        'address_line1': controllers['addressLine1Controller'].text.trim(),
        'address_line2':
            controllers['addressLine2Controller'].text.trim().isEmpty
            ? null
            : controllers['addressLine2Controller'].text.trim(),
        'landmark': controllers['landmarkController'].text.trim().isEmpty
            ? null
            : controllers['landmarkController'].text.trim(),
        'city': controllers['cityController'].text.trim(),
        'state': controllers['stateController'].text.trim(),
        'pincode': controllers['pincodeController'].text.trim(),
        'country': controllers['countryController'].text.trim(),
        'contact_person': controllers['contactPersonController'].text.trim(),
        'contact_phone': controllers['contactPhoneController'].text.trim(),
        'contact_email':
            controllers['contactEmailController'].text.trim().isEmpty
            ? null
            : controllers['contactEmailController'].text.trim(),
        'is_default_shipping': controllers['isDefaultShipping'].value,
        'is_default_billing': false,
        'location_lat': controllers['currentLatitude'].value?.toString(),
        'location_lng': controllers['currentLongitude'].value?.toString(),
      };

      if (address == null) {
        controller.addAddress(addressData);
      } else {
        controller.updateAddress(address!.id, addressData);
      }
    }
  }
}

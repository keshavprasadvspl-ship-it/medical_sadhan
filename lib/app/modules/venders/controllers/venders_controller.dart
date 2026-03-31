import 'package:get/get.dart';

// Controller
class VendorsController extends GetxController {
  final vendors = <Map<String, dynamic>>[
    {
      'name': 'MediCare Distributors',
      'logo': '🏥',
      'location': 'Mumbai, Maharashtra',
      'rating': 4.8,
      'reviews': '1.2k',
      'isVerified': true,
      'totalProducts': 500,
      'deliveryTime': '2-3 days',
      'yearsInBusiness': '10+ years',
      'vendors_products': [
        {
          'name': 'Liver Cleanse Detox & Repair',
          'category': 'Supplements',
          'price': '899',
          'originalPrice': '1299',
          'discount': 30,
          'moq': 10,
          'image': 'assets/images/liver_support.png',
        },
        {
          'name': 'Non-Drowsy Cold Flu Relief',
          'category': 'Medicine',
          'price': '245',
          'originalPrice': null,
          'discount': null,
          'moq': 20,
          'image': 'assets/images/daytime.png',
        },
        {
          'name': 'Vitamin D3 Supplement',
          'category': 'Supplements',
          'price': '450',
          'originalPrice': '650',
          'discount': 30,
          'moq': 15,
          'image': 'assets/images/liver_support.png',
        },
      ],
    },
    {
      'name': 'PharmaTrade Solutions',
      'logo': '💊',
      'location': 'Delhi NCR',
      'rating': 4.6,
      'reviews': '890',
      'isVerified': true,
      'totalProducts': 350,
      'deliveryTime': '1-2 days',
      'yearsInBusiness': '8+ years',
      'vendors_products': [
        {
          'name': 'Pain Relief Tablets',
          'category': 'Medicine',
          'price': '120',
          'originalPrice': null,
          'discount': null,
          'moq': 50,
          'image': 'assets/images/daytime.png',
        },
        {
          'name': 'Multivitamin Complex',
          'category': 'Supplements',
          'price': '550',
          'originalPrice': '750',
          'discount': 25,
          'moq': 10,
          'image': 'assets/images/liver_support.png',
        },
      ],
    },
    {
      'name': 'HealthFirst Supplies',
      'logo': '⚕️',
      'location': 'Bangalore, Karnataka',
      'rating': 4.9,
      'reviews': '2.1k',
      'isVerified': true,
      'totalProducts': 750,
      'deliveryTime': '2-4 days',
      'yearsInBusiness': '15+ years',
      'vendors_products': [
        {
          'name': 'Immunity Booster',
          'category': 'Supplements',
          'price': '699',
          'originalPrice': '999',
          'discount': 30,
          'moq': 12,
          'image': 'assets/images/liver_support.png',
        },
        {
          'name': 'Antiseptic Solution',
          'category': 'Medical Supplies',
          'price': '180',
          'originalPrice': null,
          'discount': null,
          'moq': 25,
          'image': 'assets/images/daytime.png',
        },
        {
          'name': 'Calcium Tablets',
          'category': 'Supplements',
          'price': '380',
          'originalPrice': '500',
          'discount': 24,
          'moq': 20,
          'image': 'assets/images/liver_support.png',
        },
      ],
    },
  ].obs;

  @override
  void onInit() {
    super.onInit();
  }
}
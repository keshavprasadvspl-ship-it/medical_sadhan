import 'package:get/get.dart';

import '../../splash_screen.dart';
import '../../vendor_app/app/modules/dashboard/bindings/dashboard_binding.dart';
import '../../vendor_app/app/modules/dashboard/views/dashboard_view.dart';
import '../../vendor_app/app/modules/order_details/bindings/orders_details_binding.dart';
import '../../vendor_app/app/modules/order_details/views/orders_details_view.dart';
import '../../vendor_app/app/modules/orders/bindings/orders_binding.dart';
import '../../vendor_app/app/modules/orders/views/orders_view.dart';
import '../../vendor_app/app/modules/vendors_products/bindings/vendors_products_binding.dart';
import '../../vendor_app/app/modules/vendors_profile/bindings/vendorsprofile_binding.dart';
import '../../vendor_app/app/modules/vendors_profile/views/profile_view.dart';
import '../middlewares/auth_middleware.dart';
import '../modules/VendorsListView/bindings/vendors_list_view_binding.dart';
import '../modules/VendorsListView/views/vendors_list_view_view.dart';
import '../modules/address/bindings/address_binding.dart';
import '../modules/address/views/address_view.dart';
import '../modules/auth/bindings/auth_binding.dart';
import '../modules/auth/controllers/auth_controller.dart';
import '../modules/auth/views/auth_view.dart';
import '../modules/auth/views/category_selection_view.dart';
import '../modules/auth/views/company_division_selection_view.dart';
import '../modules/auth/views/company_selection_view.dart';
import '../modules/auth/views/login_view.dart';
import '../modules/auth/views/phone_login_view.dart';
import '../modules/auth/views/register_view.dart';
import '../modules/bussiness_ditails/bindings/bussiness_ditails_binding.dart';
import '../modules/bussiness_ditails/views/bussiness_ditails_view.dart';
import '../modules/cart/bindings/cart_binding.dart';
import '../modules/cart/views/cart_view.dart';
import '../modules/categories/bindings/categories_binding.dart';
import '../modules/categories/views/categories_view.dart';
import '../modules/checkout/bindings/checkout_binding.dart';
import '../modules/checkout/views/checkout_view.dart';
import '../modules/companies_list/bindings/companies_list_binding.dart';
import '../modules/companies_list/views/companies_list_view.dart';
import '../modules/company_division/bindings/company_division_binding.dart';
import '../modules/company_division/views/company_division_view.dart';
import '../modules/edit_profile/bindings/edit_profile_binding.dart';
import '../modules/edit_profile/bindings/edit_profile_binding.dart';
import '../modules/edit_profile/views/edit_profile_view.dart';
import '../modules/edit_profile/views/edit_profile_view.dart';
import '../modules/helpSupport/bindings/help_support_binding.dart';
import '../modules/helpSupport/views/help_support_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/main/bindings/main_binding.dart';
import '../modules/main/views/main_view.dart';
import '../modules/notifications/bindings/notifications_binding.dart';
import '../modules/notifications/views/notification_settings_view.dart';
import '../modules/notifications/views/notifications_view.dart';
import '../modules/offline/bindings/offline_binding.dart';
import '../modules/offline/views/offline_view.dart';
import '../modules/order_success/bindings/order_success_binding.dart';
import '../modules/order_success/views/order_success_view.dart';
import '../modules/orders/bindings/orders_binding.dart';
import '../modules/orders/views/orders_view.dart';
import '../modules/privacyPolicy/bindings/privacy_policy_binding.dart';
import '../modules/privacyPolicy/views/privacy_policy_view.dart';
import '../modules/product_details/bindings/product_details_binding.dart';
import '../modules/product_details/controllers/product_details_controller.dart';
import '../modules/product_details/views/product_details_view.dart';
import '../modules/products/bindings/products_binding.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/search/bindings/search_binding.dart';
import '../modules/search/views/search_view.dart';
import '../modules/subscription/bindings/subscription_binding.dart';
import '../modules/subscription/views/subscription_view.dart';
import '../modules/venders/bindings/venders_binding.dart';
import '../modules/venders/views/venders_view.dart';
import '../modules/vendor_product_store/bindings/vendor_product_store_binding.dart';
import '../modules/vendor_product_store/views/vendor_product_store_view.dart';

import '../modules/products/views/products_view.dart'
    hide VendorProductStoreView;

import '../../vendor_app/app/modules/vendors_products/views/products_view.dart'
    hide ProductsView;

part 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: Routes.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.CART,
      page: () => const CartView(),
      binding: CartBinding(),
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: Routes.PRODUCT_DETAILS,
      page: () => ProductDetailView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<ProductDetailController>(() => ProductDetailController());
      }),
    ),
    GetPage(
      name: _Paths.MAIN,
      page: () => MainView(),
      binding: MainBinding(),
    ),
    GetPage(
      name: _Paths.SEARCH,
      page: () => const SearchView(),
      binding: SearchBinding(),
    ),
    GetPage(
      name: _Paths.PRODUCTS,
      page: () => ProductsView(),
      binding: ProductsBinding(),
    ),
    GetPage(
      name: _Paths.ORDERS,
      page: () => OrdersView(),
      binding: OrdersBinding(),
      middlewares: [AuthMiddleware()], // Add middleware here
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => ProfileView(),
      binding: ProfileBinding(),
      middlewares: [AuthMiddleware()], // Add middleware here
    ),
    GetPage(
      name: _Paths.ADDRESS,
      page: () => const AddressView(),
      binding: AddressBinding(),
    ),
    GetPage(
      name: _Paths.HELP_SUPPORT,
      page: () => const HelpSupportView(),
      binding: HelpSupportBinding(),
    ),
    GetPage(
      name: _Paths.PRIVACY_POLICY,
      page: () => const PrivacyPolicyView(),
      binding: PrivacyPolicyBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFICATIONS,
      page: () => const NotificationsView(),
      binding: NotificationsBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFICATIONS_SETTING,
      page: () => const NotificationSettingsView(),
      // binding: NotificationsBinding(),
    ),
    GetPage(
      name: _Paths.VENDERS,
      page: () => VendorsView(),
      binding: VendersBinding(),
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => LoginView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => RegisterView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: _Paths.VENDERS_DASHBOARD,
      page: () => DashboardView(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: _Paths.VENDERS_ORDER_DETAIL,
      page: () => VendorsOrderDetailView(),
      binding: VendorsOrdersDetailsBinding(),
    ),
    GetPage(
      name: _Paths.VENDERS_ORDERS,
      page: () => VendorsOrdersView(),
      binding: VendorsOrdersBinding(),
    ),
    GetPage(
      name: _Paths.VERNDORS_COMPANY_SELECTION,
      page: () => CompanySelectionView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: _Paths.VERNDORS_CATEGORY_SELECTION,
      page: () => CategorySelectionView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: _Paths.COMPANY_DIVISION_SELECTION,
      page: () => CompanyDivisionSelectionView(),
      binding: BindingsBuilder(() {
        Get.lazyPut<AuthController>(() => AuthController());
      }),
    ),
    GetPage(
      name: _Paths.CATEGORIES,
      page: () => CategoriesView(),
      binding: CategoriesBinding(),
    ),
    GetPage(
      name: _Paths.VENDORS_PROFILE,
      page: () => VendorsProfileView(),
      binding: VendorsProfileBinding(),
    ),
    GetPage(
      name: _Paths.VENDORS_PORDUCTS,
      page: () => VendorsProductsView(),
      binding: VendorsProductsBinding(),
    ),
    GetPage(
      name: Routes.SPLASH,
      page: () => const SplashView(),
    ),
    GetPage(
      name: _Paths.CHECKOUT,
      page: () => const CheckoutView(),
      binding: CheckoutBinding(),
    ),
    GetPage(
      name: _Paths.ORDER_SUCCESS,
      page: () => OrderSuccessView(),
      binding: OrderSuccessBinding(),
    ),
    GetPage(
      name: _Paths.EDIT_PROFILE,
      page: () => EditProfileView(),
      binding: EditProfileBinding(),
    ),
    GetPage(
      name: _Paths.BUSSINESS_DITAILS,
      page: () => BusinessDetailsView(),
      binding: BussinessDitailsBinding(),
    ),
    GetPage(
      name: _Paths.SUBSCRIPTION,
      page: () => const SubscriptionView(),
      binding: SubscriptionBinding(),
    ),
    GetPage(
      name: _Paths.VENDORS_LIST_VIEW,
      page: () => VendorsListView(),
      binding: VendorsListViewBinding(),
    ),
    GetPage(
      name: _Paths.VENDOR_PRODUCT_STORE,
      page: () => const VendorProductStoreView(),
      binding: VendorProductStoreBinding(),
    ),
    GetPage(
      name: _Paths.PHONE_LOGIN,
      page: () => PhoneLoginView(),
    ),
    GetPage(
      name: _Paths.OFFLINE,
      page: () => OfflineView(),
      binding: OfflineBinding(),
    ),
    GetPage(
      name: _Paths.COMPANIES_LIST,
      page: () => const CompaniesListView(),
      binding: CompaniesListBinding(),
    ),
    GetPage(
      name: _Paths.COMPANY_DIVISION,
      page: () => const CompanyDivisionView(),
      binding: CompanyDivisionBinding(),
    ),
  ];
}

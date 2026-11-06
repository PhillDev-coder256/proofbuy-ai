import 'package:go_router/go_router.dart';

import '../features/checkout/checkout_return_screen.dart';
import '../features/checkout/checkout_cancel_screen.dart';
import '../features/checkout/checkout_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/auth/signin_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/reset_password_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/product_comparison/product_comparison_screen.dart';
import '../features/product_details/product_details_screen.dart';
import '../features/product_search/product_search_screen.dart';
import '../features/product_search/review_requirements_screen.dart';
import '../features/purchase_review/purchase_review_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/shopping_brief/shopping_brief_screen.dart';
import '../features/transaction_history/history_screen.dart';
import '../features/transaction_result/transaction_result_screen.dart';

/// Whether the user has not yet completed onboarding.
/// Resets to false after the first navigation so subsequent
/// cold-starts go directly to the shopping brief.
bool _firstLaunch = true;

final appRouter = GoRouter(
  initialLocation: '/',
  // Handle proofbuy:// deep links: strip the custom scheme and map
  // to an internal path GoRouter can match.
  // e.g. proofbuy://checkout/return?token=XYZ  → /checkout/return?token=XYZ
  //      proofbuy://checkout/cancel             → /checkout/cancel
  redirect: (context, state) {
    final uri = state.uri;
    if (uri.scheme == 'proofbuy') {
      // Reconstruct as a regular path with query parameters preserved.
      final path = uri.path.startsWith('/') ? uri.path : '/${uri.path}';
      final query = uri.query.isNotEmpty ? '?${uri.query}' : '';
      return '$path$query';
    }
    return null; // no redirect needed for normal paths
  },
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) {
        if (_firstLaunch) {
          _firstLaunch = false;
          return '/onboarding';
        }
        return '/brief';
      },
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignUpScreen(),
    ),
    GoRoute(
      path: '/signin',
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? {};
        return ResetPasswordScreen(
          email: extra['email'] as String? ?? '',
          devOtp: extra['dev_otp'] as String?,
        );
      },
    ),
    GoRoute(
      path: '/brief',
      builder: (context, state) => const ShoppingBriefScreen(),
    ),
    GoRoute(
      path: '/loading/:sessionId',
      builder: (context, state) => ProductSearchScreen(
        sessionId: state.pathParameters['sessionId']!,
      ),
    ),
    GoRoute(
      path: '/review-requirements/:sessionId',
      builder: (context, state) => ReviewRequirementsScreen(
        sessionId: state.pathParameters['sessionId']!,
      ),
    ),
    GoRoute(
      path: '/results/:sessionId',
      builder: (context, state) => ProductComparisonScreen(
        sessionId: state.pathParameters['sessionId']!,
      ),
    ),
    GoRoute(
      path: '/product/:productResultId',
      builder: (context, state) => ProductDetailsScreen(
        productResultId: state.pathParameters['productResultId']!,
      ),
    ),
    GoRoute(
      path: '/review/:productResultId',
      builder: (context, state) => PurchaseReviewScreen(
        productResultId: state.pathParameters['productResultId']!,
      ),
    ),
    // '/checkout/return' must be listed BEFORE '/checkout/:purchaseId'
    // so GoRouter's first-match logic picks the static segment.
    GoRoute(
      path: '/checkout/return',
      builder: (context, state) => CheckoutReturnScreen(
        // PayPal returns token (= orderId) and PayerID as query params
        token: state.uri.queryParameters['token'] ?? '',
        payerId: state.uri.queryParameters['PayerID'] ?? '',
      ),
    ),
    GoRoute(
      path: '/checkout/cancel',
      builder: (context, state) => const CheckoutCancelScreen(),
    ),
    GoRoute(
      path: '/checkout/:purchaseId',
      builder: (context, state) => CheckoutScreen(
        purchaseId: state.pathParameters['purchaseId']!,
        orderId: state.uri.queryParameters['orderId'] ?? '',
      ),
    ),
    GoRoute(
      path: '/transaction/:purchaseId',
      builder: (context, state) => TransactionResultScreen(
        purchaseId: state.pathParameters['purchaseId']!,
      ),
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryScreen(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
);

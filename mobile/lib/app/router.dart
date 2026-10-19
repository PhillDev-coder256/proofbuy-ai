import 'package:go_router/go_router.dart';

import '../features/checkout/checkout_return_screen.dart';
import '../features/checkout/checkout_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/auth/signin_screen.dart';
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
  // Handle proofbuy:// deep links by transforming the URI scheme.
  // GoRouter 14.x uses [routerNeglect] / path matching; deep-link URIs
  // with a custom scheme are passed through the platform channel and
  // resolved against the path portion directly.
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
      builder: (context, state) => const CheckoutReturnScreen(),
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

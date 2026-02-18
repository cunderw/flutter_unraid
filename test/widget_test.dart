import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:flutter_unraid/app.dart';
import 'package:flutter_unraid/data/repositories/auth_repository.dart';
import 'package:flutter_unraid/di/injection.dart';
import 'package:flutter_unraid/graphql/client.dart';

import 'helpers/get_it_helpers.dart';
import 'helpers/mocks.dart';

void main() {
  late MockAuthRepository mockAuthRepo;
  late MockGraphQLClientManager mockClientManager;

  setUp(() async {
    await resetGetIt();
    mockAuthRepo = MockAuthRepository();
    mockClientManager = MockGraphQLClientManager();

    // Stub so checkAuthStatus() can proceed → emits Unauthenticated
    when(() => mockAuthRepo.getCredentials()).thenAnswer((_) async => null);

    getIt.registerSingleton<AuthRepository>(mockAuthRepo);
    getIt.registerSingleton<GraphQLClientManager>(mockClientManager);
  });

  tearDown(() async {
    await resetGetIt();
  });

  testWidgets('App renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const UnraidApp());
    await tester.pumpAndSettle();
    // Verify the app starts (loading or login screen)
    expect(find.byType(UnraidApp), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../lib/domain/repositories/auth_repository.dart';
import '../lib/domain/repositories/task_repository.dart';
import '../lib/domain/repositories/session_repository.dart';

class MockRepositories {
  static MockAuthRepository createMockAuthRepository() {
    final mock = MockAuthRepository();
    when(mock.currentUser).thenReturn(null);
    when(mock.isAuthenticated).thenReturn(false);
    return mock;
  }

  static MockTaskRepository createMockTaskRepository() {
    final mock = MockTaskRepository();
    when(mock.getProjects(any)).thenAnswer((_) async => []);
    when(mock.getTasks(any)).thenAnswer((_) async => []);
    return mock;
  }

  static MockSessionRepository createMockSessionRepository() {
    final mock = MockSessionRepository();
    when(mock.getSessions(any)).thenAnswer((_) async => []);
    when(mock.getActiveSession(any)).thenAnswer((_) async => null);
    return mock;
  }
}

class TestHelpers {
  static void expectWidgetExists(WidgetTester tester, String text) {
    expect(find.text(text), findsOneWidget);
  }

  static void expectWidgetNotExists(WidgetTester tester, String text) {
    expect(find.text(text), findsNothing);
  }

  static Future<void> tapButton(WidgetTester tester, String buttonText) async {
    await tester.tap(find.text(buttonText));
    await tester.pumpAndSettle();
  }

  static Future<void> enterText(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextFormField), text);
    await tester.pumpAndSettle();
  }
}

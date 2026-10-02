import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spotit/services/db_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('continue as guest creates a profile without any account', () async {
    SharedPreferences.setMockInitialValues({});
    await DbService.init();
    expect(await DbService.getUserProfile(), isNull);

    await DbService.continueAsGuest();
    final profile = await DbService.getUserProfile();
    expect(profile?.username, '@ospite');
    expect(profile?.location, 'Madrid');
  });

  test('the old hard-coded admin and test accounts no longer work', () async {
    SharedPreferences.setMockInitialValues({});
    await DbService.init();
    expect(await DbService.login('admin@spotit.com', 'admin123'), isFalse);
    expect(await DbService.login('alex@spotit.com', 'password123'), isFalse);
  });

  test('sign up then login works', () async {
    SharedPreferences.setMockInitialValues({});
    await DbService.init();
    expect(await DbService.signUp('a@b.it', 'secret1', 'Anna', 'anna'), isTrue);
    await DbService.clearSession();
    expect(await DbService.login('a@b.it', 'secret1'), isTrue);
    expect(await DbService.login('a@b.it', 'wrong'), isFalse);
  });
}

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uts/main.dart';

// Mock HttpClient to bypass NetworkImage HTTP requests in the test environment.
class MockHttpClient extends Fake implements HttpClient {
  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return MockHttpClientRequest();
  }
}

class MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async {
    return MockHttpClientResponse();
  }
}

class MockHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    // Return a transparent 1x1 PNG image representation.
    final transparentPng = Uint8List.fromList([
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
      0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
      0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
      0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
      0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
    ]);
    return Stream<List<int>>.fromIterable([transparentPng]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = _MockHttpOverrides();
  });

  testWidgets('Student Directory App Widget Flow Test', (WidgetTester tester) async {
    // 1. Build the application and trigger a frame.
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // 2. Verify the initial state: 5 students should be registered.
    expect(find.text('Student Directory'), findsOneWidget);
    expect(find.text('5 Mahasiswa terdaftar'), findsOneWidget);
    expect(find.text('Budi Santoso'), findsOneWidget);
    expect(find.text('Sari Dewi'), findsOneWidget);
    expect(find.text('Dian Pratama'), findsOneWidget);

    // 3. Test navigation to student details (ProfilePage) for "Budi Santoso"
    await tester.tap(find.text('Budi Santoso'));
    await tester.pumpAndSettle();

    // Verify profile page details
    expect(find.text('Profil'), findsOneWidget);
    expect(find.text('Mahasiswa dari Jakarta Selatan'), findsOneWidget);
    expect(find.text('081234567890'), findsOneWidget);

    // Try deleting Budi Santoso when total students is 5 (which is > 3, so deletion is enabled).
    // Let's click cancel first in the confirmation dialog.
    await tester.tap(find.text('Hapus Akun Ini'));
    await tester.pumpAndSettle();
    expect(find.text('Apakah Anda yakin ingin menghapus data Budi Santoso dari daftar?'), findsOneWidget);
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();
    expect(find.text('Profil'), findsOneWidget); // still on profile page

    // Go back to the home page.
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    // 4. Test Add Student flow.
    // Tap the FloatingActionButton to open the add student form.
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    expect(find.text('Tambah Mahasiswa'), findsOneWidget);

    // Submit without inputting anything -> shouldn't work because button is disabled by default
    // until consent is checked. Let's try filling in the form first.
    final nameField = find.byType(TextField).first;
    final phoneField = find.byType(TextField).last;

    await tester.enterText(nameField, 'Eka Wijaya');
    await tester.enterText(phoneField, '081399998888');
    await tester.pump();

    // The save button is disabled until consent is checked.
    // Let's verify that tapping it doesn't submit.
    await tester.tap(find.text('Simpan Mahasiswa'));
    await tester.pumpAndSettle();
    // We should still be on 'Tambah Mahasiswa' page.
    expect(find.text('Tambah Mahasiswa'), findsOneWidget);

    // Toggle the consent checkbox.
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();

    // Now tap the save button.
    await tester.tap(find.text('Simpan Mahasiswa'));
    await tester.pumpAndSettle();

    // Verify we are back on the home page and count has increased to 6.
    expect(find.text('Student Directory'), findsOneWidget);
    expect(find.text('6 Mahasiswa terdaftar'), findsOneWidget);
    expect(find.text('Eka Wijaya'), findsOneWidget);

    // 5. Test deletion.
    // Navigate to the newly added student's profile page.
    await tester.tap(find.text('Eka Wijaya'));
    await tester.pumpAndSettle();

    // Tap delete and confirm.
    await tester.tap(find.text('Hapus Akun Ini'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();

    // Verify we are back on the home page and count has decreased to 5.
    expect(find.text('Student Directory'), findsOneWidget);
    expect(find.text('5 Mahasiswa terdaftar'), findsOneWidget);
    expect(find.text('Eka Wijaya'), findsNothing);

    // 6. Test delete disabled boundary condition.
    // Let's delete 2 more students to bring the total to 3.
    // Delete Budi Santoso
    await tester.tap(find.text('Budi Santoso'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus Akun Ini'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();

    expect(find.text('4 Mahasiswa terdaftar'), findsOneWidget);

    // Delete Sari Dewi
    await tester.tap(find.text('Sari Dewi'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus Akun Ini'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();

    expect(find.text('3 Mahasiswa terdaftar'), findsOneWidget);

    // Go to "Ahmad Fauzi" (one of the remaining 3) and check if delete is disabled.
    await tester.tap(find.text('Ahmad Fauzi'));
    await tester.pumpAndSettle();

    // Check if the warning message about minimum limit is present.
    expect(find.text('Tidak bisa menghapus karena batas minimal adalah 3 mahasiswa.'), findsOneWidget);

    // Try tapping delete (it should be disabled, thus doing nothing or having null callback).
    final deleteButton = tester.widget<OutlinedButton>(find.byType(OutlinedButton));
    expect(deleteButton.enabled, isFalse);
  });
}

class _MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return MockHttpClient();
  }
}

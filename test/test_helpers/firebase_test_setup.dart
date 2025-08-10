import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helper class for setting up Firebase in test environment
class FirebaseTestSetup {
  static bool _isInitialized = false;

  /// Sets up Firebase for testing environment
  static Future<void> setupFirebase() async {
    if (_isInitialized) {
      return;
    }

    TestWidgetsFlutterBinding.ensureInitialized();

    // Mock the Firebase initialization for testing
    // This prevents actual Firebase connection during tests
    setupFirebaseAuthMocks();

    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: 'test-api-key',
          appId: 'test-app-id',
          messagingSenderId: 'test-sender-id',
          projectId: 'test-project-id',
          storageBucket: 'test-storage-bucket',
        ),
      );
      _isInitialized = true;
    } catch (e) {
      // Firebase already initialized or mock initialization
      _isInitialized = true;
    }
  }

  /// Sets up Firebase Auth mocks for testing
  static void setupFirebaseAuthMocks() {
    // Mock Firebase Auth method calls
    const MethodChannel('plugins.flutter.io/firebase_auth')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'Auth#registerIdTokenListener':
          return null;
        case 'Auth#registerAuthStateListener':
          return null;
        case 'Auth#signInAnonymously':
          return {
            'user': {
              'uid': 'test-uid',
              'email': null,
              'isAnonymous': true,
            }
          };
        case 'Auth#signInWithEmailAndPassword':
          return {
            'user': {
              'uid': 'test-uid',
              'email': methodCall.arguments['email'],
              'isAnonymous': false,
            }
          };
        case 'Auth#createUserWithEmailAndPassword':
          return {
            'user': {
              'uid': 'test-uid',
              'email': methodCall.arguments['email'],
              'isAnonymous': false,
            }
          };
        case 'Auth#signOut':
          return null;
        default:
          return null;
      }
    });

    // Mock Firebase Core method calls
    const MethodChannel('plugins.flutter.io/firebase_core')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'Firebase#initializeCore':
          return [
            {
              'name': '[DEFAULT]',
              'options': {
                'apiKey': 'test-api-key',
                'appId': 'test-app-id',
                'messagingSenderId': 'test-sender-id',
                'projectId': 'test-project-id',
              },
              'pluginConstants': {},
            }
          ];
        case 'Firebase#initializeApp':
          return {
            'name': methodCall.arguments['appName'] ?? '[DEFAULT]',
            'options': methodCall.arguments['options'],
            'pluginConstants': {},
          };
        default:
          return null;
      }
    });

    // Mock Firestore method calls
    const MethodChannel('plugins.flutter.io/cloud_firestore')
        .setMockMethodCallHandler((MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'Firestore#settings':
          return null;
        case 'DocumentReference#set':
          return null;
        case 'DocumentReference#update':
          return null;
        case 'DocumentReference#get':
          return {
            'path': methodCall.arguments['path'],
            'data': {},
            'metadata': {
              'hasPendingWrites': false,
              'isFromCache': false,
            },
          };
        case 'Query#get':
          return {
            'paths': [],
            'documents': [],
            'documentChanges': [],
            'metadata': {
              'hasPendingWrites': false,
              'isFromCache': false,
            },
          };
        default:
          return null;
      }
    });
  }

  /// Tears down Firebase setup (for cleanup between tests if needed)
  static Future<void> tearDown() async {
    _isInitialized = false;
    // Reset method channel handlers
    const MethodChannel('plugins.flutter.io/firebase_auth')
        .setMockMethodCallHandler(null);
    const MethodChannel('plugins.flutter.io/firebase_core')
        .setMockMethodCallHandler(null);
    const MethodChannel('plugins.flutter.io/cloud_firestore')
        .setMockMethodCallHandler(null);
  }

  /// Check if Firebase is initialized
  static bool get isInitialized => _isInitialized;
}

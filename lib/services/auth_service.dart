import 'package:firebase_auth/firebase_auth.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // Stream để lắng nghe thay đổi authentication state
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  //đăng ký với thông tin đầy đủ
  Future<UserCredential?> signUpWithEmail(
    String email,
    String password, {
    String? firstName,
    String? lastName,
  }) async {
    try {
      UserCredential result =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Tạo user profile trong Firestore với thông tin đầy đủ
      if (result.user != null) {
        await _firestoreService.createUserProfile(
          userId: result.user!.uid,
          email: email,
          firstName: firstName,
          lastName: lastName,
        );
      }

      return result;
    } catch (e) {
      print('Lỗi đăng ký: $e');
      rethrow; // Ném lại exception để UI có thể xử lý
    }
  }

  //Đăng nhập
  Future<UserCredential?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } catch (e) {
      print('Lỗi đăng nhập: $e');
      rethrow; // Ném lại exception để UI có thể xử lý
    }
  }

  //Đăng xuất
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      print('Lỗi đăng xuất: $e');
      rethrow;
    }
  }

  //lấy user hiện tại
  User? get currentUser => _firebaseAuth.currentUser;

  // Kiểm tra user đã đăng nhập hay chưa
  bool get isSignedIn => currentUser != null;

  // Lấy thông tin user từ Firestore
  Future<Map<String, dynamic>?> getCurrentUserData() async {
    try {
      if (currentUser != null) {
        final userDoc =
            await _firestoreService.getUserProfile(currentUser!.uid);
        if (userDoc.exists) {
          return userDoc.data() as Map<String, dynamic>?;
        }
      }
      return null;
    } catch (e) {
      print('Lỗi lấy thông tin user: $e');
      return null;
    }
  }

  // Stream để lắng nghe thay đổi user data từ Firestore
  Stream<Map<String, dynamic>?> getCurrentUserDataStream() {
    if (currentUser != null) {
      return _firestoreService.getUserProfileStream(currentUser!.uid).map(
          (doc) => doc.exists ? doc.data() as Map<String, dynamic>? : null);
    }
    return Stream.value(null);
  }

  // Lấy thông báo lỗi dễ hiểu cho user
  String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'Không tìm thấy tài khoản với email này';
        case 'wrong-password':
          return 'Mật khẩu không đúng';
        case 'email-already-in-use':
          return 'Email này đã được sử dụng';
        case 'weak-password':
          return 'Mật khẩu quá yếu';
        case 'invalid-email':
          return 'Email không hợp lệ';
        case 'too-many-requests':
          return 'Quá nhiều lần thử. Vui lòng thử lại sau';
        default:
          return 'Đã xảy ra lỗi: ${error.message}';
      }
    }
    return 'Đã xảy ra lỗi không xác định';
  }
}

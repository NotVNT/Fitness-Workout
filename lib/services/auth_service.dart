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
    String? phone,
    String? dateOfBirth,
  }) async {
    try {
      UserCredential result =
          await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Tạo user profile trong Firestore
      if (result.user != null) {
        await _firestoreService.createUserProfile(
          userId: result.user!.uid,
          email: email,
          firstName: firstName,
          lastName: lastName,
          phone: phone,
          dateOfBirth: dateOfBirth,
          targetWeight: 0.0,
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
      print('AuthService: signOut() called');
      // Đăng xuất khỏi Firebase
      await _firebaseAuth.signOut();
      print('AuthService: Firebase signOut() completed');
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
        print('Đang lấy thông tin user với ID: ${currentUser!.uid}');
        final userDoc =
            await _firestoreService.getUserProfile(currentUser!.uid);
        print('User document exists: ${userDoc.exists}');
        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>?;
          print('User data: $data');

          // Cleanup old data if hashedPassword exists
          if (data != null && data.containsKey('hashedPassword')) {
            print('Found old hashedPassword field, cleaning up...');
            await _firestoreService.cleanupOldUserData(currentUser!.uid);
          }

          return data;
        } else {
          print('User document không tồn tại, tạo profile mới');
          // Nếu user document không tồn tại, tạo một profile cơ bản
          await _firestoreService.createUserProfile(
            userId: currentUser!.uid,
            email: currentUser!.email ?? '',
            targetWeight: 0.0,
          );
          // Lấy lại data sau khi tạo
          final newUserDoc =
              await _firestoreService.getUserProfile(currentUser!.uid);
          return newUserDoc.data() as Map<String, dynamic>?;
        }
      }
      return null;
    } catch (e) {
      print('Lỗi lấy thông tin user: $e');
      return null;
    }
  }

  // Xác minh mật khẩu hiện tại bằng cách thử đăng nhập lại
  Future<bool> verifyCurrentPassword(String password) async {
    try {
      if (currentUser != null && currentUser!.email != null) {
        // Thử đăng nhập lại với mật khẩu hiện tại để xác minh
        UserCredential credential =
            await _firebaseAuth.signInWithEmailAndPassword(
          email: currentUser!.email!,
          password: password,
        );
        return credential.user != null;
      }
      return false;
    } catch (e) {
      print('Lỗi xác minh mật khẩu: $e');
      return false;
    }
  }

  // Đổi mật khẩu
  Future<void> changePassword(
      String currentPassword, String newPassword) async {
    try {
      if (currentUser == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      // Xác minh mật khẩu hiện tại
      bool isCurrentPasswordValid =
          await verifyCurrentPassword(currentPassword);
      if (!isCurrentPasswordValid) {
        throw Exception('Mật khẩu hiện tại không đúng');
      }

      // Cập nhật mật khẩu trong Firebase Auth
      await currentUser!.updatePassword(newPassword);
    } catch (e) {
      print('Lỗi đổi mật khẩu: $e');
      rethrow;
    }
  }

  // Reset mật khẩu qua email
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      print('Lỗi reset mật khẩu: $e');
      rethrow;
    }
  }

  // Xóa tài khoản và tất cả dữ liệu
  Future<void> deleteAccount(String password) async {
    try {
      if (currentUser == null) {
        throw Exception('Người dùng chưa đăng nhập');
      }

      // Xác minh mật khẩu trước khi xóa
      bool isPasswordValid = await verifyCurrentPassword(password);
      if (!isPasswordValid) {
        throw Exception('Mật khẩu không đúng');
      }

      String userId = currentUser!.uid;

      // Xóa dữ liệu từ Firestore
      await _firestoreService.deleteUserData(userId);

      // Xóa tài khoản Firebase Auth
      await currentUser!.delete();
    } catch (e) {
      print('Lỗi xóa tài khoản: $e');
      rethrow;
    }
  }

  // Stream để lắng nghe thay đổi user data từ Firestore
  Stream<Map<String, dynamic>?> getCurrentUserDataStream() {
    if (currentUser != null) {
      return _firestoreService.getUserProfileStream(currentUser!.uid).asyncMap(
        (doc) async {
          if (doc.exists) {
            return doc.data() as Map<String, dynamic>?;
          } else {
            // Nếu document không tồn tại, tạo profile mới
            print(
                'Tạo user profile mới trong stream cho user: ${currentUser!.uid}');
            await _firestoreService.createUserProfile(
              userId: currentUser!.uid,
              email: currentUser!.email ?? '',
              targetWeight: 0.0,
            );
            // Trả về data mặc định
            return {
              'email': currentUser!.email ?? '',
              'firstName': '',
              'lastName': '',
              'dateOfBirth': '',
              'gender': '',
              'phone': '',
              'weight': 0.0,
              'height': 0.0,
              'targetWeight': 0.0,
            };
          }
        },
      );
    }
    return Stream.value(null);
  }

  // Lấy thông báo lỗi dễ hiểu cho user
  String getErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
        case 'invalid-login-credentials':
          return 'Tài khoản hoặc mật khẩu không chính xác';
        case 'email-already-in-use':
          return 'Email này đã được sử dụng';
        case 'weak-password':
          return 'Mật khẩu quá yếu (tối thiểu 6 ký tự)';
        case 'invalid-email':
          return 'Email không hợp lệ';
        case 'too-many-requests':
          return 'Quá nhiều lần thử. Vui lòng thử lại sau';
        case 'network-request-failed':
          return 'Lỗi kết nối mạng. Vui lòng kiểm tra internet';
        case 'user-disabled':
          return 'Tài khoản đã bị vô hiệu hóa';
        case 'missing-email':
          return 'Vui lòng nhập email';
        default:
          return 'Có lỗi xảy ra. Vui lòng thử lại';
      }
    }
    return 'Có lỗi xảy ra. Vui lòng thử lại';
  }
}

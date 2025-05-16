import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';

class DatabaseHelper {
  // Initialize Parse
  static Future<void> initializeParse() async {

    // these keys should pe removed before committing, this is provided only for prof reference for the assignment

    const keyApplicationId = 'wR5ny0fBG9Q9qAfCn2LcIkQ2Y1FaxdlGaJP0Q6Dw';
    const keyClientKey = 'iGvxxiQp38vZaxt2ECcOz6ZIK9BjeT42jVXAIj3u';
    const keyParseServerUrl = 'https://parseapi.back4app.com';


    await Parse().initialize(
      keyApplicationId,
      keyParseServerUrl,
      clientKey: keyClientKey,
      autoSendSessionId: true,
    );
  }

  // DB operations for signup user
  static Future<bool> signUpUser({
    required String username,
    required String email,
    required String password,
  }) async {
    final user = ParseUser(username, password, email);
    final response = await user.signUp();
    if (!response.success) {
      print("Sign-up error: ${response.error?.message}");
    }
    return response.success;
  }

  // Back4app apis for login user
  static Future<bool> loginUser({
    required String username,
    required String password,
  }) async {
    final user = ParseUser(username, password, null);
    final response = await user.login();
    return response.success;
  }

  // Back4app apis for logout user
  static Future<void> logoutUser() async {
    final user = await ParseUser.currentUser() as ParseUser?;
    await user?.logout();
  }

  // Back4app apis to get logged in user
  static Future<ParseUser?> getCurrentUser() async {
    return await ParseUser.currentUser() as ParseUser?;
  }

  // Back4app apis to reset the password
  // static Future<bool> resetPassword({required String email}) async {
  //   final user = ParseUser(null, null, email);
  //   final response = await user.requestPasswordReset();
  //   return response.success;
  // }


  // Back4app apis to reset the password
  static Future<bool> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final currentUser = await ParseUser.currentUser() as ParseUser?;
    if (currentUser == null || currentUser.username == null) return false;

    final tempUser = ParseUser(currentUser.username!, oldPassword, null);
    final loginResponse = await tempUser.login();

    if (loginResponse.success) {
      currentUser.password = newPassword;
      final saveResponse = await currentUser.save();
      return saveResponse.success;
    } else {
      return false;
    }
  }

  // DB operations to delete user records
  static Future<bool> deleteUserAccount() async {
    final user = await ParseUser.currentUser() as ParseUser?;
    if (user == null) return false;

    // 1. Delete the associated userRecords entry
    final query = QueryBuilder(ParseObject('userRecords'))
      ..whereEqualTo('owner', user)
      ..setLimit(1);

    final response = await query.query();
    if (response.success && response.results != null && response.results!.isNotEmpty) {
      final record = response.results!.first as ParseObject;
      final deleteProfile = await record.delete();
      if (!deleteProfile.success) {
        print("Failed to delete userRecords entry: ${deleteProfile.error?.message}");
      }
    }

    // 2. Now delete the user account from _User
    final deleteUserResponse = await user.delete();
    return deleteUserResponse.success;
  }



  // to create user records in DB such as fname, lname, age, email

  static Future<bool> createUserRecord({
    required String fname,
    required String lname,
    required int age,
  }) async {
    final currentUser = await getCurrentUser();
    if (currentUser == null) return false;

    final record = ParseObject('userRecords')
      ..set('fname', fname)
      ..set('lname', lname)
      ..set('age', age)
      ..set('owner', currentUser);

    final response = await record.save();
    // To Debug
    print("Sign-up error: ${response.error?.message}");
    return response.success;
  }

  // To retrieve user profile details
  static Future<ParseObject?> getUserProfile() async {
    final currentUser = await getCurrentUser();
    if (currentUser == null) return null;

    final query = QueryBuilder(ParseObject('userRecords'))
      ..whereEqualTo('owner', currentUser)
      ..setLimit(1);

    final response = await query.query();
    if (response.success && response.results != null && response.results!.isNotEmpty) {
      return response.results!.first as ParseObject;
    }
    return null;
  }


  // To update user records in DB

  static Future<bool> updateUserProfile({
    required String objectId,
    String? fname,
    String? lname,
    int? age,
  }) async {
    final record = ParseObject('userRecords')..objectId = objectId;

    if (fname != null) record.set('fname', fname);
    if (lname != null) record.set('lname', lname);
    if (age != null) record.set('age', age);

    final response = await record.save();
    return response.success;
  }

  // To update user email address
  static Future<bool> updateCurrentUserEmail(String email) async {
    final user = await ParseUser.currentUser() as ParseUser?;
    if (user == null) return false;

    user.emailAddress = email;
    final response = await user.save();
    return response.success;
  }

  // To get the list of books from DB
  static Future<List<ParseObject>> getBooks() async {
    final query = QueryBuilder(ParseObject('Books'))
      ..orderByAscending('title');

    final response = await query.query();
    if (response.success && response.results != null) {
      return response.results as List<ParseObject>;
    } else {
      return [];
    }
  }
}
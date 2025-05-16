// import 'package:flutter/material.dart';
// import 'package:pharma_now/features/profile/presentation/providers/profile_provider.dart';
// import 'package:provider/provider.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';

// class LogoutHelper {
//   // Helper method for logging out that ensures complete cleanup
//   static Future<void> performLogout(BuildContext context) async {
//     try {
//       // Start by clearing the provider data
//       await Provider.of<ProfileProvider>(context, listen: false)
//           .clearUserData();

//       // Sign out from Firebase Auth
//       await FirebaseAuth.instance.signOut();

//       // Sign out from Google (if signed in)
//       final googleSignIn = GoogleSignIn();
//       if (await googleSignIn.isSignedIn()) {
//         await googleSignIn.signOut();
//       }

//       // Wait a moment to ensure all sign-out processes complete
//       await Future.delayed(Duration(milliseconds: 100));

//       // Force refresh to get new user data after the next login
//       FirebaseAuth.instance.authStateChanges().first.then((user) {
//         if (user != null) {
//           Provider.of<ProfileProvider>(context, listen: false)
//               .refreshUserData();
//         }
//       });

//       // Navigate to login page
//       Navigator.of(context).pushNamedAndRemoveUntil(
//         'loginView', // Make sure this is the correct route name
//         (route) => false,
//       );
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Logout failed: ${e.toString()}')),
//       );
//     }
//   }
// }

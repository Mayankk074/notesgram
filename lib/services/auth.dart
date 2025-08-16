
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:notesgram/models/userUid.dart';

class AuthService{

  final FirebaseAuth _auth= FirebaseAuth.instance;

  //Creating User instance based on FirebaseUser
  UserUid? _userUidFromUser(User? user){
    return user != null ? UserUid(uid: user.uid): null;
  }

  //Sign Up with email and Password
  Future<UserUid?> signUpWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential? result= await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user=result.user;
      return _userUidFromUser(user);
    }  catch (e) {
      return null;
    }
  }

  //SignIn with Google
  Future<UserCredential?> signInWithGoogle() async {
    // Trigger the authentication flow
    await GoogleSignIn.instance.initialize();
    final GoogleSignInAccount googleUser = await GoogleSignIn.instance.authenticate();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(idToken: googleAuth.idToken);

    // Once signed in, return the UserCredential
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  //Sign In anon
  Future signInAnon() async {
    try{
      UserCredential result=await _auth.signInAnonymously();
      User? user=result.user;
      return _userUidFromUser(user);
    } catch(e){
      return null;
    }
  }

  //signOut
  Future signOut() async {
    await _auth.signOut();
  }

  //signIn
  Future signIn(String email, String password) async {
    try {
      UserCredential? result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return _userUidFromUser(user);
    } catch(e){
      return null;
    }
  }



  //Stream for user
  Stream<UserUid?> get user{
    return _auth.authStateChanges().map(
      _userUidFromUser
    );
  }
}
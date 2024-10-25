// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:ems/pages/list_events.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String email = '', password = '', userRole = 'normal_user';
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>(); 

  Future<void> handleAuth() async {
    if (_formKey.currentState?.validate() ?? false) {
     
      try {
        if (isLogin) {
          await _auth.signInWithEmailAndPassword(
              email: email, password: password);
        } else {
         
          UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
              email: email, password: password);

         
          await _firestore.collection('users').doc(userCredential.user!.uid).set({
            'email': email,
            'role': userRole,
          });
        }
        if (_auth.currentUser != null) {
         
          final userDoc = await _firestore.collection('users').doc(_auth.currentUser!.uid).get();
          String role = userDoc['role'];

         
          if (role == 'promoter') {
           
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const EventListPage()));
          } else {
          
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const EventListPage()));
          }
        }
      } catch (e) {
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset("assets/imgs/logo.png", width: 80),
            Text(
              'Event Management',
              style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        backgroundColor: Colors.deepPurple[800],
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            height: 550,
            width: size.width > 600 ? 400 : size.width * 0.8,
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromARGB(151, 86, 73, 158),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      isLogin ? 'Welcome Back' : 'Create Account',
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.deepPurple[800],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      onChanged: (val) => email = val,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color.fromRGBO(69, 39, 160, 1)),
                        ),
                        prefixIcon: const Icon(Icons.email, color: Color.fromRGBO(69, 39, 160, 1)),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.roboto(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        }
                        String pattern = r'^[^@]+@[^@]+\.[^@]+';
                        if (!RegExp(pattern).hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null; 
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      onChanged: (val) => password = val,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color.fromRGBO(69, 39, 160, 1)),
                        ),
                        prefixIcon: const Icon(Icons.lock, color: Color.fromRGBO(69, 39, 160, 1)),
                      ),
                      style: GoogleFonts.roboto(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null; 
                      },
                    ),
                    if (!isLogin) ...[
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        value: userRole,
                        decoration: InputDecoration(
                          labelText: 'User Role',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color.fromRGBO(69, 39, 160, 1)),
                          ),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'promoter', child: Text('Promoter')),
                          DropdownMenuItem(value: 'normal_user', child: Text('Normal User')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            userRole = value!;
                          });
                        },
                      ),
                    ],
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: handleAuth,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        backgroundColor: Colors.deepPurple[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isLogin ? 'Login' : 'Sign Up',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () => setState(() => isLogin = !isLogin),
                      child: Text(
                        isLogin
                            ? 'Create an Account'
                            : 'Already have an account? Login',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.deepPurple[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      backgroundColor: Colors.deepPurple[50],
    );
  }
}


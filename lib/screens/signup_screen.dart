import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController studentIdController =
      TextEditingController();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    nameController.dispose();
    studentIdController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> createAccount() async {
    // Validate all fields
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );

    final success = await authProvider.createAccount(
      name: nameController.text.trim(),
      studentId: studentIdController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Account created successfully!',
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // Go back to Sign In
      Navigator.pushReplacementNamed(
        context,
        '/login',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'An account already exists. Please sign in.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF0F172A),
          ),

          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              24,
              10,
              24,
              30,
            ),

            child: Form(
              key: _formKey,

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  // ---------------- LOGO ----------------

                  Center(
                    child: Container(
                      width: 80,
                      height: 80,

                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        borderRadius:
                            BorderRadius.circular(22),
                      ),

                      child: const Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ---------------- TITLE ----------------

                  const Center(
                    child: Text(
                      'Create Account',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Center(
                    child: Text(
                      'Join the FindIt campus community',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ---------------- FULL NAME ----------------

                  const Text(
                    'Full Name',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: nameController,

                    textCapitalization:
                        TextCapitalization.words,

                    decoration: InputDecoration(
                      hintText:
                          'Enter your full name',

                      prefixIcon: const Icon(
                        Icons.person_outline,
                      ),

                      filled: true,
                      fillColor: Colors.white,

                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),

                        borderSide: BorderSide.none,
                      ),
                    ),

                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Please enter your name';
                      }

                      if (value.trim().length < 3) {
                        return 'Name must contain at least 3 characters';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  // ---------------- STUDENT ID ----------------

                  const Text(
                    'Student ID',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller:
                        studentIdController,

                    decoration: InputDecoration(
                      hintText:
                          'Enter your student ID',

                      prefixIcon: const Icon(
                        Icons.badge_outlined,
                      ),

                      filled: true,
                      fillColor: Colors.white,

                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),

                        borderSide: BorderSide.none,
                      ),
                    ),

                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Please enter your student ID';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  // ---------------- EMAIL ----------------

                  const Text(
                    'College Email',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: emailController,

                    keyboardType:
                        TextInputType.emailAddress,

                    decoration: InputDecoration(
                      hintText:
                          'example@college.edu',

                      prefixIcon: const Icon(
                        Icons.email_outlined,
                      ),

                      filled: true,
                      fillColor: Colors.white,

                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),

                        borderSide: BorderSide.none,
                      ),
                    ),

                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Please enter your college email';
                      }

                      final email =
                          value.trim();

                      final emailRegex = RegExp(
                        r'^[\w\-.]+@[\w\-]+\.[a-zA-Z]{2,}$',
                      );

                      if (!emailRegex
                          .hasMatch(email)) {
                        return 'Enter a valid email address';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  // ---------------- PASSWORD ----------------

                  const Text(
                    'Password',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller:
                        passwordController,

                    obscureText:
                        obscurePassword,

                    decoration: InputDecoration(
                      hintText:
                          'Create a password',

                      prefixIcon: const Icon(
                        Icons.lock_outline,
                      ),

                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscurePassword =
                                !obscurePassword;
                          });
                        },

                        icon: Icon(
                          obscurePassword
                              ? Icons
                                  .visibility_off_outlined
                              : Icons
                                  .visibility_outlined,
                        ),
                      ),

                      filled: true,
                      fillColor: Colors.white,

                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),

                        borderSide: BorderSide.none,
                      ),
                    ),

                    validator: (value) {
                      if (value == null ||
                          value.isEmpty) {
                        return 'Please create a password';
                      }

                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 18),

                  // ---------------- CONFIRM PASSWORD ----------------

                  const Text(
                    'Confirm Password',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller:
                        confirmPasswordController,

                    obscureText:
                        obscureConfirmPassword,

                    decoration: InputDecoration(
                      hintText:
                          'Re-enter your password',

                      prefixIcon: const Icon(
                        Icons.lock_reset_outlined,
                      ),

                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            obscureConfirmPassword =
                                !obscureConfirmPassword;
                          });
                        },

                        icon: Icon(
                          obscureConfirmPassword
                              ? Icons
                                  .visibility_off_outlined
                              : Icons
                                  .visibility_outlined,
                        ),
                      ),

                      filled: true,
                      fillColor: Colors.white,

                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(14),

                        borderSide: BorderSide.none,
                      ),
                    ),

                    validator: (value) {
                      if (value == null ||
                          value.isEmpty) {
                        return 'Please confirm your password';
                      }

                      if (value !=
                          passwordController.text) {
                        return 'Passwords do not match';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 28),

                  // ---------------- CREATE ACCOUNT ----------------

                  SizedBox(
                    width: double.infinity,
                    height: 55,

                    child: ElevatedButton(
                      onPressed:
                          isLoading
                              ? null
                              : createAccount,

                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF2563EB),

                        foregroundColor:
                            Colors.white,

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),
                        ),
                      ),

                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,

                              child:
                                  CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Create Account',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ---------------- SIGN IN ----------------

                  Center(
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),

                        TextButton(
                          onPressed: () {
                            Navigator
                                .pushReplacementNamed(
                              context,
                              '/login',
                            );
                          },

                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              color:
                                  Color(0xFF2563EB),
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
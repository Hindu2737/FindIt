import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() =>
      _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController emailController =
      TextEditingController();

  final TextEditingController passwordController =
      TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  Future<void> login() async {
    // Validate form first
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

    final success = authProvider.login(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    if (!mounted) return;

    setState(() {
      isLoading = false;
    });

    if (success) {
      Navigator.pushReplacementNamed(
        context,
        '/home',
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Invalid email or password.',
          ),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8FAFC),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.all(24),

            child: Form(
              key: _formKey,

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  // ---------------- LOGO ----------------

                  Center(
                    child: Container(
                      width: 85,
                      height: 85,

                      decoration: BoxDecoration(
                        color:
                            const Color(0xFF2563EB),

                        borderRadius:
                            BorderRadius.circular(24),
                      ),

                      child: const Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 48,
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ---------------- TITLE ----------------

                  const Center(
                    child: Text(
                      'Welcome to FindIt',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            Color(0xFF0F172A),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Center(
                    child: Text(
                      'Sign in with your college account',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 15,
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),

                  // ---------------- EMAIL ----------------

                  const Text(
                    'College Email',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller:
                        emailController,

                    keyboardType:
                        TextInputType.emailAddress,

                    decoration:
                        InputDecoration(
                      hintText:
                          'example@college.edu',

                      prefixIcon:
                          const Icon(
                        Icons.email_outlined,
                      ),

                      filled: true,
                      fillColor:
                          Colors.white,

                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                        borderSide:
                            BorderSide.none,
                      ),
                    ),

                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Please enter your college email';
                      }

                      final email =
                          value.trim();

                      final emailRegex =
                          RegExp(
                        r'^[\w\-.]+@[\w\-]+\.[a-zA-Z]{2,}$',
                      );

                      if (!emailRegex
                          .hasMatch(email)) {
                        return 'Enter a valid email address';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  // ---------------- PASSWORD ----------------

                  const Text(
                    'Password',
                    style: TextStyle(
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller:
                        passwordController,

                    obscureText:
                        obscurePassword,

                    decoration:
                        InputDecoration(
                      hintText:
                          'Enter your password',

                      prefixIcon:
                          const Icon(
                        Icons.lock_outline,
                      ),

                      suffixIcon:
                          IconButton(
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
                      fillColor:
                          Colors.white,

                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          14,
                        ),
                        borderSide:
                            BorderSide.none,
                      ),
                    ),

                    validator: (value) {
                      if (value == null ||
                          value.isEmpty) {
                        return 'Please enter your password';
                      }

                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 12),

                  // ---------------- FORGOT PASSWORD ----------------

                  Align(
                    alignment:
                        Alignment.centerRight,

                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger
                            .of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Password recovery will be added later.',
                            ),
                          ),
                        );
                      },

                      child: const Text(
                        'Forgot Password?',
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // ---------------- SIGN IN ----------------

                  SizedBox(
                    width:
                        double.infinity,
                    height: 55,

                    child:
                        ElevatedButton(
                      onPressed:
                          isLoading
                              ? null
                              : login,

                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            const Color(
                          0xFF2563EB,
                        ),

                        foregroundColor:
                            Colors.white,

                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
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
                                color:
                                    Colors.white,
                                strokeWidth:
                                    2,
                              ),
                            )
                          : const Text(
                              'Sign In',
                              style:
                                  TextStyle(
                                fontSize:
                                    17,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // ---------------- OR ----------------

                  Row(
                    children: [
                      Expanded(
                        child:
                            Divider(
                          color: Colors
                              .grey
                              .shade300,
                        ),
                      ),

                      const Padding(
                        padding:
                            EdgeInsets
                                .symmetric(
                          horizontal: 12,
                        ),
                        child: Text(
                          'OR',
                          style:
                              TextStyle(
                            color:
                                Colors.grey,
                          ),
                        ),
                      ),

                      Expanded(
                        child:
                            Divider(
                          color: Colors
                              .grey
                              .shade300,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

                  // ---------------- SSO ----------------

                  SizedBox(
                    width:
                        double.infinity,
                    height: 52,

                    child:
                        OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger
                            .of(context)
                            .showSnackBar(
                          const SnackBar(
                            content: Text(
                              'College SSO integration will be added later.',
                            ),
                          ),
                        );
                      },

                      icon: const Icon(
                        Icons
                            .school_outlined,
                      ),

                      label: const Text(
                        'Continue with College SSO',
                      ),

                      style:
                          OutlinedButton
                              .styleFrom(
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                            14,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ---------------- SIGN UP ----------------

                  Center(
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,

                      children: [
                        const Text(
                          'New to FindIt? ',
                          style: TextStyle(
                            color:
                                Colors.grey,
                          ),
                        ),

                        TextButton(
                          onPressed: () {
                            Navigator
                                .pushNamed(
                              context,
                              '/signup',
                            );
                          },

                          child:
                              const Text(
                            'Create an account',
                            style:
                                TextStyle(
                              color:
                                  Color(
                                0xFF2563EB,
                              ),
                              fontWeight:
                                  FontWeight
                                      .bold,
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
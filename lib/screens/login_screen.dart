import 'package:flutter/material.dart';
import 'package:expense_tracker/screens/home_screen.dart';
import 'package:expense_tracker/screens/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';



class Loginscreen extends StatefulWidget {
  @override
  State<Loginscreen> createState() => _LoginscreenState();
}

class _LoginscreenState extends State<Loginscreen> {
  final emailController= TextEditingController();
  final passwordController= TextEditingController();
  bool isPasswordVisible = false;
  bool isLoading = false;


  Future<void> loginUser() async {
    setState(() {
      isLoading=true;
    });
    try{
    await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
    );
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>HomeScreen()),
    );
  } catch(e){
    ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Login Failed: ${e.toString()}")),
    );
  }
  finally{
      setState(() {
        isLoading=false;
      });
  }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Icon(
                        Icons.account_balance_wallet,
                        color: Colors.blue,
                        size: 24,
                      ),
                      SizedBox(width: 8),
                      Text(
                        "Smart Expense Tracker",
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
          
                SizedBox(height: 25),
          
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Welcome Back 👋",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
          
                SizedBox(height: 35),
          
                Column(
                //  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
          
                    TextField(
                      keyboardType: TextInputType.emailAddress,
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: "Enter Email",
                        labelStyle: TextStyle(
                          color: Colors.black38,
                          fontSize: 18,
                        ),
                        prefixIcon: Icon(Icons.email, color: Colors.blue),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(21),
                          borderSide: BorderSide(
                            color: Colors.green,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                          borderSide: BorderSide(
                            color: Colors.deepPurple,
                            width: 1,
                          ),
                        ),
                        disabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                          borderSide: BorderSide(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
          
                    SizedBox(height: 15),
          
                    TextField(
                      keyboardType: TextInputType.visiblePassword,
                      controller: passwordController,
                      obscureText: !isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: "Enter Password",
                        labelStyle: TextStyle(
                          color: Colors.black38,
                          fontSize: 18,
                        ),
                        prefixIcon: Icon(Icons.lock, color: Colors.blue),
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.blue,
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(21),
                          borderSide: BorderSide(
                            color: Colors.green,
                            width: 2,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(11),
                          borderSide: BorderSide(
                            color: Colors.deepPurple,
                            width: 1,
                          ),
                        ),
                      ),
                    ),
          
                    SizedBox(height: 20),
          
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlueAccent,
                        foregroundColor: Colors.white,
                       minimumSize: Size(120, 45),
                        padding: EdgeInsets.symmetric(horizontal: 30),
          
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
          
                      ),
                      onPressed: isLoading ? null : loginUser,
                      child: isLoading ? SizedBox(height: 20,
                      width: 20, child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ) : Text(
                        "Login To Continue",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
          
                    SizedBox(height: 10,),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        "Don't have An account? Register",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
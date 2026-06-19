import 'package:expense_tracker/screens/home_screen.dart';
import 'package:expense_tracker/screens/login_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class RegisterScreen extends StatefulWidget {
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isPasswordVisible=false;
  bool isLoading = false;


  Future<void> registerUser() async{
    setState(() {
      isLoading=true;
    });
    try{
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Account Created Successfully")),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );

    }
    on FirebaseAuthException catch (e){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message?? "Registration Failed")),
      );
    }
    finally {
      setState(() {
        isLoading=false;
      });
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 30),
              Text("Create Your Account Here",style:
                TextStyle(color: Colors.blue,
                fontSize: 26,
                fontWeight: FontWeight.w800),
              ),
              SizedBox(
                height: 15,
              ),
        
              TextField(
                keyboardType: TextInputType.name,
                decoration: InputDecoration(
                  labelText: "Enter Name",
                  labelStyle: TextStyle(color: Colors.black38,fontSize: 18),
                  prefixIcon: Icon(Icons.person,color: Colors.blue,),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(21),
                    borderSide: BorderSide(
                        color: Colors.green,
                        width: 3
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                    borderSide: BorderSide(
                        color: Colors.indigo,
                        width: 1
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                    borderSide: BorderSide(
                        color: Colors.grey,
                        width: 1
                    ),
                  ),
                ),
                ) ,
        
              SizedBox(height: 15),
              TextField(
                keyboardType: TextInputType.emailAddress,
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "Enter Email",
                  labelStyle: TextStyle(color: Colors.black38,fontSize: 18),
                  prefixIcon: Icon(Icons.email,color: Colors.blue,),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(21),
                    borderSide: BorderSide(
                        color: Colors.green,
                        width: 3
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                    borderSide: BorderSide(
                        color: Colors.indigo,
                        width: 1
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                    borderSide: BorderSide(
                        color: Colors.grey,
                        width: 1
                    ),
                  ),
                ),
              ) ,
        
              SizedBox(height: 15),
        
              TextField(
                keyboardType: TextInputType.visiblePassword,
                controller: passwordController,
                obscureText: !isPasswordVisible,
                decoration: InputDecoration(
                  labelText: "Enter Password",
                  labelStyle: TextStyle(color: Colors.black38,fontSize: 18),
                  prefixIcon: Icon(Icons.lock,color: Colors.blue,),
                  suffixIcon:IconButton(icon: Icon(isPasswordVisible ? Icons.visibility: Icons.visibility_off ,color: Colors.blue),
                    onPressed: (){
                      setState(() {
                        isPasswordVisible=!isPasswordVisible;
                      });
                    },
                  ),
        
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(21),
                    borderSide: BorderSide(
                        color: Colors.green,
                        width: 3
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                    borderSide: BorderSide(
                        color: Colors.indigo,
                        width: 1
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(11),
                    borderSide: BorderSide(
                        color: Colors.grey,
                        width: 1
                    ),
                  ),
                ),
              ) ,
        
              SizedBox(height: 20),
        
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.yellowAccent,
                ),
                onPressed:  isLoading ? null : registerUser,
                child: isLoading ? SizedBox(height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                )
                : Text("Register User", style: TextStyle(
                  color: Colors.white,fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                ),
              ),

              SizedBox(height: 10,),

              TextButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Loginscreen()),
                  );
                },
                child: Text(
                  "Already have an account? Sign In",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontStyle: FontStyle.normal,

                  ),
                ),
              )


            ],
          ),
        ),
      ),
    );
  }
}
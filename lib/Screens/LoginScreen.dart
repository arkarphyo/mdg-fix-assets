import 'package:flutter/material.dart';
import 'package:mdg_fixasset/Utils/ApiService.dart';
import 'package:mdg_fixasset/WIdgets/CustomButton.dart';
import 'package:mdg_fixasset/WIdgets/CustomTextField.dart';
import 'package:ionicons/ionicons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.sizeOf(context);
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg-mdg-office.jpg"),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
            child: Center(
          child: SizedBox(
            width: size.width > 800 ? size.width / 3 : double.infinity,
            height: 400,
            child: Card(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.person),
                  Text(
                    "LOGIN",
                    style: TextStyle(fontSize: 24),
                  ),
                  Text("Signin to manage fix assets data."),
                  CustomTextField(
                    width: size.width > 600 ? size.width / 4 : size.width,
                    controller: _usernameController,
                    hint: "Username",
                    lable: "Username",
                    icon: Icon(Ionicons.person),
                    suffix: IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.remove_red_eye_outlined)),
                  ),
                  CustomTextField(
                    width: size.width > 600 ? size.width / 4 : size.width,
                    lable: "Password",
                    hint: "Password",
                    controller: _passwordController,
                    icon: Icon(Ionicons.lock_open_outline),
                    suffix: IconButton(
                        onPressed: () {},
                        icon: Icon(Icons.remove_red_eye_outlined)),
                  ),
                  CustomButton(
                    width: size.width > 600 ? size.width / 8 : size.width / 1.2,
                    text: "Login",
                    backgroundColor: Colors.blueGrey,
                    onTap: () {
                      ApiService apiService = ApiService();
                    },
                    textColor: Colors.white,
                  )
                ],
              ),
            ),
          ),
        )),
      ),
    );
  }
}

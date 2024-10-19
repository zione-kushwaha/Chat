import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:learning1/constant.dart';
import 'package:learning1/service/navigation_service.dart';
import 'package:learning1/widgets/custom_form_field.dart';

import '../service/alert_service.dart';
import '../service/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _loginFormKey = GlobalKey<FormState>();
  final GetIt getIt = GetIt.instance;
  late String email;
  late String password;
  late AuthService _authService;
  late AlertService _alertService;
  late NavigationService _navigationService;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _authService = getIt.get<AuthService>();
    _navigationService = getIt.get<NavigationService>();
    _alertService = getIt.get<AlertService>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _buildUi(),
    );
  }

  Widget _buildUi() {
    return SafeArea(
        child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 15.0,
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildHeader(),
          _loginForm(),
          _loginBottom(),
          _createAnAccountLink()
        ],
      ),
    ));
  }

  Widget _buildHeader() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child:
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Hi, Welcome Back!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
            )),
        Text('Hello again, you have been missed!',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey,
              fontWeight: FontWeight.w800,
            ))
      ]),
    );
  }

  Widget _loginForm() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.3,
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Form(
        key: _loginFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomFormField(
              hintText: 'Email',
              validateRegularExp: EMAIL_VALIDATION_REGEX,
              onSaved: (value) {
                setState(() {
                  email = value!;
                });
              },
            ),
            CustomFormField(
                hintText: 'Password',
                validateRegularExp: PASSWORD_VALIDATION_REGEX,
                obscureText: true,
                onSaved: (value) {
                  setState(() {
                    password = value!;
                  });
                })
          ],
        ),
      ),
    );
  }

  Widget _loginBottom() {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: MaterialButton(
          color: Theme.of(context).colorScheme.primary,
          onPressed: () async {
            if (_loginFormKey.currentState!.validate()) {
              _loginFormKey.currentState!.save();
              bool result = await _authService.Login(email, password);
              if (result) {
                _navigationService.pushReplacementNamed('home');
                _alertService.showToast(
                  message: 'Login Successful',
                  icon: Icons.check_circle,
                );
              } else {
                _alertService.showToast(
                  message: 'Login Failed',
                  icon: Icons.error,
                );
              }
            }
          },
          child: const Text('Login',
              style: TextStyle(
                color: Colors.white,
              )),
        ));
  }

  Widget _createAnAccountLink() {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Don\'t have an account?  ',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              )),
          GestureDetector(
            onTap: () {
              _navigationService.pushNamed('register');
            },
            child: const Text('Sign Up',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  fontWeight: FontWeight.w800,
                )),
          )
        ],
      ),
    );
  }
}

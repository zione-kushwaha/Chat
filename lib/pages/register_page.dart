import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:learning1/constant.dart';
import 'package:learning1/widgets/custom_form_field.dart';
import '../models/user_profile.dart';
import '../service/alert_service.dart';
import '../service/auth_service.dart';
import '../service/database_service.dart';
import '../service/media_service.dart';
import '../service/navigation_service.dart';
import '../service/storage_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GetIt getIt = GetIt.instance;
  String? email, password, name;
  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
  late AlertService _alertService;
  late NavigationService _navigationService;
  late AuthService _authService;
  late StorageService _storageService;
  File? _image;
  late DatabaseService _databaseService;
  late MediaService _mediaService;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _mediaService = getIt.get<MediaService>();
    _authService = getIt.get<AuthService>();
    _storageService = getIt.get<StorageService>();
    _navigationService = getIt.get<NavigationService>();
    _alertService = getIt.get<AlertService>();
    _databaseService = getIt.get<DatabaseService>();
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildHeader(),
            if (!isLoading) _registerForm(),
            if (!isLoading) _registerBottom(),
            if (!isLoading) _LoginLink(),
            if (isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child:
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Let\'s get started!',
            style: TextStyle(
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.w800,
            )),
        Text('Create an account to continue!',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey,
              fontWeight: FontWeight.w800,
            ))
      ]),
    );
  }

  Widget _registerForm() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Form(
        key: _registerFormKey,
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              _profilePicSelection(),
              CustomFormField(
                  hintText: 'Name',
                  validateRegularExp: NAME_VALIDATION_REGEX,
                  onSaved: (val) {
                    setState(() {
                      name = val;
                    });
                  }),
              CustomFormField(
                  hintText: 'Email',
                  validateRegularExp: EMAIL_VALIDATION_REGEX,
                  onSaved: (val) {
                    setState(() {
                      email = val;
                    });
                  }),
              CustomFormField(
                  hintText: 'password',
                  obscureText: true,
                  validateRegularExp: PASSWORD_VALIDATION_REGEX,
                  onSaved: (val) {
                    setState(() {
                      password = val;
                    });
                  })
            ]),
      ),
    );
  }

  Widget _profilePicSelection() {
    return GestureDetector(
      onTap: () async {
        final file = await _mediaService.getImageFromGallery();
        if (file != null) {
          setState(() {
            _image = file;
          });
        }
      },
      child: CircleAvatar(
        radius: 50,
        backgroundColor: Colors.white,
        backgroundImage: _image != null
            ? FileImage(_image!)
            : const NetworkImage(
                'https://cdn-icons-png.freepik.com/512/180/180656.png'),
      ),
    );
  }

  Widget _registerBottom() {
    return SizedBox(
        width: MediaQuery.of(context).size.width,
        child: MaterialButton(
          color: Theme.of(context).colorScheme.primary,
          onPressed: () async {
            setState(() {
              isLoading = true;
            });
            try {
              if (_registerFormKey.currentState!.validate()) {
                _registerFormKey.currentState!.save();
                bool result = await _authService.signUp(email!, password!);
                if (result) {
                  final downloadLink = await _storageService.uploadUserPfps(
                      _image!, _authService.user!.uid);
                  if (downloadLink != null) {
                    // update the user profile
                    await _databaseService.createUserProfile(
                        profile: UserProfile(
                      uid: _authService.user!.uid,
                      name: name!,
                      pfpURL: downloadLink,
                    ));

                    _alertService.showToast(
                      message: 'Registration Successful',
                      icon: Icons.check_circle,
                    );
                    _navigationService.pop();
                    _navigationService.pushReplacementNamed('home');
                  }
                }
              }
            } catch (e) {
              _alertService.showToast(
                message: e.toString(),
                icon: Icons.error,
              );
            }
            setState(() {
              isLoading = false;
            });
          },
          child: const Text('Register',
              style: TextStyle(
                color: Colors.white,
              )),
        ));
  }

  Widget _LoginLink() {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Already have an account?  ',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey,
              )),
          GestureDetector(
            onTap: () {
              _navigationService.pop();
            },
            child: const Text('Login',
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

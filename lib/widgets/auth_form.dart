import 'package:flutter/material.dart';
import 'package:instagram/screens/language.dart';
import 'package:instagram/screens/sign_up.dart';

class AuthForm extends StatefulWidget {
  const AuthForm(this.submitFn, this.isLoading, {Key? key}) : super(key: key);
  final bool isLoading;
  final void Function(
    String username,
    String password,
    BuildContext ctx,
  ) submitFn;

  @override
  State<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _userName;
  late TextEditingController _password;
  bool isEnabled = false;
  bool _showPassword = false;
  bool isLogin = true;

  void _trySubmit() {
    widget.submitFn(
      _userName.text.trim(),
      _password.text.trim(),
      context,
    );
    setState(() {
      isEnabled = false;
    });
  }

  void checkButtonStatus() {
    if (_userName.text != '' && _password.text != '') {
      setState(() {
        isEnabled = true;
      });
    }
    if (_userName.text == '' || _password.text == '') {
      setState(() {
        isEnabled = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();

    // KeyboardVisibilityController().onChange.listen((isVisible) {
    //   isKeyboard = isVisible;
    // });

    _userName = TextEditingController();
    _password = TextEditingController();
    _userName.addListener(() {
      checkButtonStatus();
    });
    _password.addListener(() {
      checkButtonStatus();
    });
  }

  @override
  void dispose() {
    super.dispose();
    _userName.dispose();
    _password.dispose();
  }

  Widget _bottom() {
    return Column(
      children: [
        const Divider(
          height: 3,
          thickness: 0.5,
          color: Colors.white38,
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 3),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isLogin ? 'Don\'t have an account' : 'Already have an account',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
              TextButton(
                onPressed: () => setState(() {
                  isLogin = !isLogin;
                }),
                child: Text(
                  isLogin ? 'Sign up.' : 'Sign in.',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: CustomScrollView(
          slivers: [
            if (isLogin)
              SliverToBoxAdapter(
                child: Container(
                  alignment: Alignment.topCenter,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (context) => const Language())),
                    child: const Text(
                      'English ▽',
                      style: TextStyle(
                        color: Colors.white60,
                      ),
                    ),
                  ),
                ),
              ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  Expanded(
                    child: isLogin
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 30),
                            width: MediaQuery.of(context).size.width,
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Instagram',
                                    style: TextStyle(
                                        color:
                                            Color.fromARGB(255, 240, 228, 228),
                                        fontFamily: 'Billabong',
                                        fontSize: 50,
                                        fontWeight: FontWeight.w500,
                                        letterSpacing: 1),
                                  ),
                                  const SizedBox(
                                    height: 25,
                                  ),
                                  TextFormField(
                                    controller: _userName,
                                    style: const TextStyle(color: Colors.white),
                                    cursorWidth: 0.5,
                                    cursorColor: Colors.white,
                                    decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 15, horizontal: 15),
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        filled: true,
                                        fillColor: const Color.fromARGB(
                                            255, 69, 68, 68),
                                        hintStyle: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.white54,
                                            fontWeight: FontWeight.w400),
                                        hintText: 'Email'),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  TextFormField(
                                    controller: _password,
                                    keyboardType: TextInputType.visiblePassword,
                                    obscureText: !_showPassword,
                                    style: const TextStyle(color: Colors.white),
                                    cursorWidth: 0.5,
                                    cursorColor: Colors.white,
                                    decoration: InputDecoration(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                                vertical: 15, horizontal: 15),
                                        suffixIcon: Padding(
                                          padding:
                                              const EdgeInsets.only(right: 5),
                                          child: IconButton(
                                            splashRadius: 25,
                                            icon: Icon(
                                              _showPassword
                                                  ? Icons.visibility
                                                  : Icons.visibility_off,
                                              color: _showPassword
                                                  ? Colors.blue
                                                  : Colors.white54,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                _showPassword = !_showPassword;
                                              });
                                            },
                                          ),
                                        ),
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide.none,
                                            borderRadius:
                                                BorderRadius.circular(5)),
                                        filled: true,
                                        fillColor: const Color.fromARGB(
                                            255, 69, 68, 68),
                                        hintStyle: const TextStyle(
                                            fontSize: 15,
                                            color: Colors.white54,
                                            fontWeight: FontWeight.w400),
                                        hintText: 'Password'),
                                  ),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width - 60,
                                    height: 40,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        disabledBackgroundColor:
                                            const Color.fromARGB(
                                                255, 26, 31, 93),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(7)),
                                      ),
                                      onPressed: isEnabled ? _trySubmit : null,
                                      child: widget.isLoading
                                          ? const SizedBox(
                                              height: 25,
                                              width: 25,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 3,
                                                color: Colors.white,
                                              ),
                                            )
                                          : Text(
                                              'Log in',
                                              style: TextStyle(
                                                color: isEnabled
                                                    ? Colors.white
                                                    : Colors.white38,
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Forgot your login details?',
                                        style: TextStyle(
                                            color: Colors.white54,
                                            fontSize: 12),
                                      ),
                                      TextButton(
                                        onPressed: () {},
                                        child: const Text(
                                          'Get help logging in.',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12),
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width:
                                            (MediaQuery.of(context).size.width -
                                                        60) /
                                                    2 -
                                                25,
                                        child: const Divider(
                                          height: 3,
                                          thickness: 0.5,
                                          color: Colors.white54,
                                        ),
                                      ),
                                      const Text(
                                        '  OR  ',
                                        style: TextStyle(
                                            color: Colors.white60,
                                            fontSize: 15),
                                      ),
                                      SizedBox(
                                        width:
                                            (MediaQuery.of(context).size.width -
                                                        60) /
                                                    2 -
                                                25,
                                        child: const Divider(
                                          height: 3,
                                          thickness: 0.5,
                                          color: Colors.white54,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  TextButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(
                                      Icons.facebook,
                                      size: 28,
                                    ),
                                    label: const Text('Log in with Facebook'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : const SignUp(),
                  ),
                  _bottom()
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

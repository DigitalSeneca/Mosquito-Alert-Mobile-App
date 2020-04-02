import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController _passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.topCenter,
          decoration: new BoxDecoration(
            color: Colors.white,
          ),
          child: SvgPicture.asset(
            'assets/img/bg_login_small.svg',
            fit: BoxFit.cover,
          ),
        ),
        Scaffold(
          appBar: AppBar(
            elevation: 0,
            centerTitle: true,
            backgroundColor: Colors.transparent,
            title: SvgPicture.asset('assets/img/logo_inverse.svg', width: 200),
          ),
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                SizedBox(
                  height: 80,
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Style.titleMedium(
                            MyLocalizations.of(context, "signup_user_title")),
                        SizedBox(
                          height: 20,
                        ),
                        Form(
                          child: Column(children: <Widget>[
                            Style.textField(
                                MyLocalizations.of(context, "email_txt"),
                                _passwordController,
                                context),
                            SizedBox(
                              height: 10,
                            ),
                            Style.textField(
                                MyLocalizations.of(context, "first_name_txt"),
                                _passwordController,
                                context),
                            SizedBox(
                              height: 10,
                            ),
                            Style.textField(
                                MyLocalizations.of(context, "last_name_txt"),
                                _passwordController,
                                context),
                            SizedBox(
                              height: 10,
                            ),
                            Style.textField(
                                MyLocalizations.of(context, "password_txt"),
                                _passwordController,
                                context),
                          ]),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Container(
                            width: double.infinity,
                            child: Style.button(
                                MyLocalizations.of(context, "signup_btn"),
                                () {})),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                      margin: EdgeInsets.all(10.0),
                      alignment: Alignment.bottomCenter,
                      child: Style.body(
                          MyLocalizations.of(
                              context, "terms_and_conditions_txt"),
                          color: Style.greyColor,
                          textAlign: TextAlign.center)),
                )
              ],
            ),
          ),
        ),
      ],
    );
  }
}
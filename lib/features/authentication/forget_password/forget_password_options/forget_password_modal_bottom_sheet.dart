import 'package:flutter/material.dart';
import 'package:EzRecycle/features/authentication/forget_password/forget_password_mail/forget_password_mail.dart';

import '../../../../constants/sizes.dart';
import '../../../../constants/text_strings.dart';
import 'forget_password_btn_widget.dart';

class forgetPasswordScreen{
  static Future<dynamic> buildShadowModalBottomSheet(BuildContext context){
    return showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(40),topRight: Radius.circular(40))),
        builder: (context) => Container(
          height: 250,
          padding: const EdgeInsets.all(tDefaultSize),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                tForgetPasswordTitle,
                style: Theme.of(context).textTheme.headline4,
              ),
              const SizedBox(height: 10),
              /*Text(
                tForgetPasswordSubTitle,
                style: Theme.of(context).textTheme.bodyText1, textAlign: TextAlign.center,
              ),*/
              const SizedBox(
                height: 30,
              ),
              ForgetPasswordBtnWidget(
                btnIcon: Icons.mail_outline_rounded,
                title: 'Email',
                subTitle: tResetViaEmail,
                onTap: () {
                  Navigator.pushNamed(context, '/forgetpasswordmailscreen');
                },
              ),
              /*const SizedBox(
                height: 20.0,
              ),
              ForgetPasswordBtnWidget(
                btnIcon: Icons.mobile_friendly,
                title: 'Phone No',
                subTitle: tResetViaPhone,
                onTap: () {
                  Navigator.pushNamed(context, '/forgetpasswordphonescreen');
                },
              ),*/
            ],
          ),
        ));
  }

}
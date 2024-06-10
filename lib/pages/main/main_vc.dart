import 'dart:async';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:badges/badges.dart' as badges;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:mosquito_alert_app/api/api.dart';
import 'package:mosquito_alert_app/models/notification.dart';
import 'package:mosquito_alert_app/pages/forms_pages/adult_report_page.dart';
import 'package:mosquito_alert_app/pages/forms_pages/biting_report_page.dart';
import 'package:mosquito_alert_app/pages/forms_pages/breeding_report_page.dart';
import 'package:mosquito_alert_app/pages/info_pages/info_page.dart';
import 'package:mosquito_alert_app/pages/main/components/custom_card_widget.dart';
import 'package:mosquito_alert_app/pages/my_reports_pages/my_reports_page.dart';
import 'package:mosquito_alert_app/pages/notification_pages/notifications_page.dart';
import 'package:mosquito_alert_app/pages/settings_pages/campaign_tutorial_page.dart';
import 'package:mosquito_alert_app/pages/settings_pages/settings_page.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/UserManager.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';
import 'package:mosquito_alert_app/utils/version_control.dart';

class MainVC extends StatefulWidget {
  @override
  _MainVCState createState() => _MainVCState();
}

class _MainVCState extends State<MainVC> {
  String? userName;

  StreamController<String?> nameStream = StreamController<String?>.broadcast();
  String? userUuid;
  StreamController<bool> loadingStream = StreamController<bool>.broadcast();
  int unreadNotifications = 0;

  @override
  void initState() {
    super.initState();
    initAuthStatus();
    _getNotificationCount();
  }

  @override
  void dispose() {
    nameStream.close();
    loadingStream.close();
    super.dispose();
  }

  void initAuthStatus() async {
    loadingStream.add(true);

    if (Platform.isIOS) {
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
    VersionControl.getInstance().packageApiKey =
        'uqFb4yrdZCPFXsvXrJHBbJg5B5TqvSCYmxR7aPuN2uCcCKyu9FDVWettvbtNV9HKm';
    VersionControl.getInstance().packageLanguageCode = 'es';
    var check = await VersionControl.getInstance().checkVersion(context);
    if (check != null && check) {
      _getData();
    }

    loadingStream.add(false);
  }

  void _getData() async {
    await UserManager.startFirstTime(context);
    userUuid = await UserManager.getUUID();
    UserManager.userScore = await ApiSingleton().getUserScores();
    await UserManager.setUserScores(UserManager.userScore);
    await Utils.loadFirebase();

    await Utils.getLocation(context);
    if (UserManager.user != null) {
      nameStream.add(UserManager.user!.email);
      setState(() {
        userName = UserManager.user!.email;
      });
    }
  }

  void _getNotificationCount() async {
    List<MyNotification> notifications = await ApiSingleton().getNotifications();
    var unacknowledgedCount = notifications.where((notification) => notification.acknowledged == false).length;
    updateNotificationCount(unacknowledgedCount);
  }

  void updateNotificationCount(int newCount) {
    setState(() {
      unreadNotifications = newCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(
                  Icons.settings,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            SettingsPage()),
                  );
                },
              ),
              title: Image.asset(
                'assets/img/ic_logo.png',
                height: 40,
              ),
              actions: <Widget>[
                IconButton(
                  icon: SvgPicture.asset(
                    'assets/img/sendmodule/ic_adn.svg',
                    height: 26,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => CampaignTutorialPage()),
                    );
                  },
                ),
                badges.Badge(
                  position: badges.BadgePosition.topEnd(top: 2, end: 2),
                  showBadge: unreadNotifications > 0,
                  badgeContent: Text('$unreadNotifications', style: TextStyle(color: Colors.white)),
                  child: IconButton(
                    padding: EdgeInsets.only(top: 6),
                    icon: Icon(Icons.notifications, size: 32, ), 
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => NotificationsPage(onNotificationUpdate: updateNotificationCount)),
                      );
                    },
                  )
                )
              ],
            ),
            body: LayoutBuilder(
              builder:
                  (BuildContext context, BoxConstraints viewportConstraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: viewportConstraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Stack(
                        children: <Widget>[
                          Container(
                            alignment: Alignment.bottomCenter,
                            child: Image.asset(
                              'assets/img/bottoms/bottom_main.png',
                              width: double.infinity,
                              fit: BoxFit.fitWidth,
                              alignment: Alignment.bottomCenter,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: SingleChildScrollView(
                              child: Column(
                                children: <Widget>[
                                  SizedBox(
                                    height: 24,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: <Widget>[
                                      Expanded(
                                        flex: 2,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Style.body(
                                                MyLocalizations.of(context, 'what_to_do_txt'),
                                                fontSize: 16),
                                          ]),
                                      )                                      
                                    ]),
                                  SizedBox(height: 25),
                                  Material(
                                    elevation: 5.0,
                                    borderRadius: BorderRadius.circular(25),
                                    child: Container(
                                      height: 60.0,
                                      decoration: BoxDecoration(
                                        color: Color(int.parse('40DFD458', radix: 16)),
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                      child: ListTile(
                                        leading: Image.asset('assets/img/ic_mosquito_report.png'),
                                        title: Text(MyLocalizations.of(context, 'report_adults_txt')),
                                        onTap: () {
                                          loadingStream.add(true);
                                          _createAdultReport();
                                        },
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 15),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: <Widget>[
                                      Material(
                                        elevation: 5.0,
                                        borderRadius: BorderRadius.circular(25),
                                        child: Container(
                                          height: 60.0,
                                          decoration: BoxDecoration(
                                            color: Color(int.parse('40D28A73', radix: 16)),
                                            borderRadius: BorderRadius.circular(25),
                                          ),
                                          child: ListTile(
                                            leading: Image.asset('assets/img/ic_bite_report.png'),
                                            title: Text(MyLocalizations.of(context, 'report_biting_txt')),
                                            onTap: () {
                                              loadingStream.add(true);
                                              _createBiteReport();
                                            },
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 15),
                                      Material(
                                        elevation: 5.0,
                                        borderRadius: BorderRadius.circular(25),
                                        child: Container(
                                          height: 60.0,
                                          decoration: BoxDecoration(
                                            color: Color(int.parse('407D9393', radix: 16)),
                                            borderRadius: BorderRadius.circular(25),
                                          ),
                                          child: ListTile(
                                            leading: Image.asset('assets/img/ic_breeding_report.png'),
                                            title: Text(MyLocalizations.of(context, 'report_nest_txt')),
                                            onTap: () {
                                              loadingStream.add(true);
                                              _createSiteReport();
                                            },
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )),
        Positioned.fill(
          child: StreamBuilder<bool>(
            stream: loadingStream.stream,
            initialData: true,
            builder: (BuildContext ctxt, AsyncSnapshot<bool> snapshot) {
              if (snapshot.hasData == false || snapshot.data == false) {
                return Container();
              }
              return Utils.loading(
                snapshot.data,
              );
            },
          ),
        )
      ],
    );
  }

  _createBiteReport() async {
    var createReport = await Utils.createNewReport('bite');
    loadingStream.add(false);
    if (createReport) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BitingReportPage()),
      );
    } else {
      print('Bite report was not created');
      loadingStream.add(false);
      await Utils.showAlert(MyLocalizations.of(context, 'app_name'),
          MyLocalizations.of(context, 'server_down'), context);
    }
  }

  _createAdultReport() async {
    var createReport = await Utils.createNewReport('adult');
    loadingStream.add(false);
    if (createReport) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AdultReportPage()),
      );
    } else {
      print('Adult report was not created');
      loadingStream.add(false);
      await Utils.showAlert(MyLocalizations.of(context, 'app_name'),
          MyLocalizations.of(context, 'server_down'), context);
    }
  }

  _createSiteReport() async {
    var createReport = await Utils.createNewReport('site');
    loadingStream.add(false);
    if (createReport) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BreedingReportPage()),
      );
    } else {
      print('Site report was not created');
      loadingStream.add(false);
      await Utils.showAlert(MyLocalizations.of(context, 'app_name'),
          MyLocalizations.of(context, 'server_down'), context);
    }
  }
}

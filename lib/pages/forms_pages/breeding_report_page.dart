import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mosquito_alert_app/models/report.dart';
import 'package:mosquito_alert_app/pages/forms_pages/adult_report_page.dart';
import 'package:mosquito_alert_app/pages/forms_pages/biting_report_page.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/add_other_report_form.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/biting_location_form.dart';
import 'package:mosquito_alert_app/pages/forms_pages/components/questions_breeding_form.dart';
import 'package:mosquito_alert_app/utils/MyLocalizations.dart';
import 'package:mosquito_alert_app/utils/Utils.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class BreedingReportPage extends StatefulWidget {
  final Report editReport;
  final Function loadData;

  BreedingReportPage({this.editReport, this.loadData});

  @override
  _BreedingReportPageState createState() => _BreedingReportPageState();
}

class _BreedingReportPageState extends State<BreedingReportPage> {
  PageController _pagesController;
  List<Widget> _formsRepot;
  StreamController<bool> loadingStream = new StreamController<bool>.broadcast();
  StreamController<bool> validStream = new StreamController<bool>.broadcast();
  StreamController<double> percentStream =
      new StreamController<double>.broadcast();

  List<Map> displayQuestions = [
    {
      "question": {
        "id": 9,
        "text": {
          "en": "It's a public or a private location?",
          "ca": "Estàs a un lloc públic o propietat privada?",
          "es": "Estás en un lugar público o propiedad privada?"
        }
      },
      "answers": [
        {
          "id": 91,
          "text": {
            "en": "Public place",
            "ca": "Lloc públic",
            "es": "Lloc públic",
          }
        },
        {
          "id": 92,
          "text": {
            "en": "Private location",
            "ca": "Propietat privada",
            "es": "Propietat privada",
          }
        }
      ]
    },
    {
      "question": {
        "id": 10,
        "text": {
          "en": "Does it have water?",
          "ca": "Hi ha aigua?",
          "es": "¿Tiene agua?",
        }
      },
      "answers": [
        {
          "id": 101,
          "text": {"en": "Yes", "ca": "Sí", "es": "Sí"}
        },
        {
          "id": 81,
          "text": {"en": "No", "ca": "No", "es": "No"}
        }
      ]
    },
    {
      "question": {
        "id": 11,
        "text": {
          "en": "Have you seen mosquitoes around?",
          "ca": "Has vist mosquits a la vora?",
          "es": "¿Has visto mosquitos alrededor?"
        }
      },
      "answers": [
        {
          "id": 111,
          "text": {"en": "Mosquito", "ca": "Mosquit", "es": "Mosquito"}
        },
        {
          "id": 112,
          "text": {"en": "Bite", "ca": "Picada", "es": "Picadura"}
        },
        {
          "id": 81,
          "text": {"en": "No", "ca": "No", "es": "No"}
        },
      ]
    },
    {
      "question": {
        "id": 12,
        "text": {
          "en": "Is it a storm drain or other type of breeding site?",
          "ca": "Com és el lloc de cria detectat a la via pública?",
          "es": "¿Cómo es el lugar de cría detectado en la vía pública?"
        }
      },
      "answers": [
        {
          'img': "assets/img/ic_imbornal.png",
          "id": 121,
          "text": {
            "en": "Storm drain",
            "ca": "Embornal",
            "es": "Imbornal",
          }
        },
        {
          'img': "assets/img/ic_other_site.png",
          "id": 122,
          "text": {
            "en": "Other breeding site",
            "ca": "Altres tipus",
            "es": "Otro tipo"
          }
        }
      ]
    },
    {
      "question": {
        "id": 6,
        "text": {
          "en": "Where is the breeding site?",
          "ca": "On es troba el lloc de cria?",
          "es": " ¿Dónde se encuentra el lugar de cría?"
        }
      },
      "answers": [
        {
          "id": 61, //Location - value equals WKT of point
          "text": {"en": "", "ca": ""}
        }
      ]
    },
  ];

  bool skipReport = false;
  bool addMosquito = false;
  bool validContent = false;
  bool showCamera = false;
  String otherReport;

  double index = 1.0;

  @override
  void initState() {
    super.initState();
    if (widget.editReport != null) {
      Utils.setEditReport(widget.editReport);
      validContent = true;
    }
    _pagesController = PageController();

    _formsRepot = [
      QuestionsBreedingForm(
          displayQuestions.elementAt(3), setValid, true, _chooseTypeImage),
      QuestionsBreedingForm(
          displayQuestions.elementAt(1), setValid, false, goNextPage),
      BitingLocationForm(
          setValid,
          displayQuestions.elementAt(4)['question']['text']
              [Utils.getLanguage()]),
      AddOtherReportPage(_createReport, setValid, percentStream),
    ];
  }

  setSkipReport(skip) {
    setState(() {
      skipReport = skip;
    });
  }

  addAdultReport(addReport) {
    setState(() {
      addMosquito = addReport;
    });
  }

  addOtherReport(String reportType) {
    setState(() {
      otherReport = reportType;
    });
  }

  setShowCamera(data) {
    setState(() {
      showCamera = data;
    });
  }

  setValid(isValid) {
    validStream.add(isValid);
  }

  goNextPage() {
    _pagesController
        .nextPage(duration: Duration(microseconds: 300), curve: Curves.ease)
        .then((value) => setValid(widget.editReport != null));
    setState(() {
      index = _pagesController.page + 1;
    });
  }

  navigateOtherReport() async {
    switch (otherReport) {
      case "bite":
        Utils.addOtherReport('bite');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BitingReportPage()),
        );
        break;
      // case "site":
      //   Utils.addOtherReport('site');
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (context) => BreedingReportPage()),
      //   );
      //   break;
      case "adult":
        Utils.addOtherReport('adult');
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AdultReportPage()),
        );
        break;
      default:
        break;
    }
  }

  _createReport() async {
    setState(() {
      percentStream.add(0.8);
    });
    loadingStream.add(true);
    bool res = await Utils.createReport();

    if (widget.editReport != null) {
      widget.loadData();
    }
    if (!res) {
      _showAlertKo();
    } else {
      _showAlertOk();
      setState(() {
        percentStream.add(1.0);
      });
    }
  }

  _saveReports() async {
    loadingStream.add(true);
    bool res = await Utils.saveReports();
    res == null || !res ? _showAlertKo() : _showAlertOk();
    Utils.resetReport();
  }

  @override
  void dispose() {
    _pagesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _onWillPop();
        return false;
      },
      child: Stack(
        children: <Widget>[
          Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              centerTitle: true,
              leading: IconButton(
                icon: Style.iconBack,
                onPressed: () {
                  double currentPage = _pagesController.page;

                  if (currentPage == 0.0) {
                    if (Utils.reportsList != null &&
                        Utils.reportsList.isNotEmpty) {
                      Utils.deleteLastReport();
                    } else {
                      Utils.resetReport();
                    }
                    Navigator.pop(context);
                  } else {
                    _pagesController
                        .previousPage(
                            duration: Duration(microseconds: 300),
                            curve: Curves.ease)
                        .then((value) => addOtherReport(null));
                  }
                  setState(() {
                    index = currentPage - 1;
                  });
                },
              ),
              title: Style.title(
                  MyLocalizations.of(context, "breeding_report_title"),
                  fontSize: 16),
            ),
            body: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                PageView(
                  controller: _pagesController,
                  // itemCount: _formsRepot.length,
                  physics: NeverScrollableScrollPhysics(),
                  // itemBuilder: (BuildContext context, int index) {
                  //   return _formsRepot[index];
                  // }),
                  children: _formsRepot,
                ),
                index <= 1.0
                    ? Container()
                    : index != _formsRepot.length.toDouble() - 1
                        ? SafeArea(
                            child: Align(
                            alignment: Alignment.bottomCenter,
                            child: StreamBuilder<bool>(
                                stream: validStream.stream,
                                initialData: false,
                                builder: (BuildContext ctxt,
                                    AsyncSnapshot<bool> snapshot) {
                                  return snapshot.data
                                      ? Container(
                                          width: double.infinity,
                                          height: 54,
                                          margin: EdgeInsets.symmetric(
                                              vertical: 6, horizontal: 12),
                                          child: Style.button(
                                              MyLocalizations.of(
                                                  context, "continue_txt"), () {
                                            double currentPage =
                                                _pagesController.page;

                                            if (skipReport) {
                                              _saveReports();
                                            } else {
                                              if (currentPage == 0.0) {
                                                _chooseTypeImage();
                                                setState(() {
                                                  index = currentPage + 1;
                                                });
                                              } else if (currentPage == 3.0 &&
                                                      otherReport == 'adult' ||
                                                  otherReport == 'bite') {
                                                navigateOtherReport();
                                              } else {
                                                setState(() {
                                                  index = currentPage + 1;
                                                });
                                                _pagesController
                                                    .nextPage(
                                                        duration: Duration(
                                                            microseconds: 300),
                                                        curve: Curves.ease)
                                                    .then((value) => setValid(
                                                        widget.editReport !=
                                                            null));
                                              }
                                            }
                                          }),
                                        )
                                      : Container(
                                          width: double.infinity,
                                          height: 54,
                                          margin: EdgeInsets.symmetric(
                                              vertical: 6, horizontal: 12),
                                          child: Style.button(
                                              MyLocalizations.of(
                                                  context, "continue_txt"),
                                              null),
                                        );
                                }),
                          ))
                        : Container(
                            width: double.infinity,
                            height: 54,
                            margin: EdgeInsets.symmetric(
                                vertical: 6, horizontal: 12),
                            child: Style.button(
                              MyLocalizations.of(context, "send_data"),
                              () {
                                _createReport();
                              },
                            ),
                          ),
              ],
            ),
          ),
          StreamBuilder<bool>(
            stream: loadingStream.stream,
            initialData: false,
            builder: (BuildContext ctxt, AsyncSnapshot<bool> snapshot) {
              if (snapshot.hasData == false || snapshot.data == false) {
                return Container();
              }
              return Utils.loading(
                snapshot.data,
              );
            },
          )
        ],
      ),
    );
  }

  _chooseTypeImage() {
    if (widget.editReport == null) {
      List<Widget> listForiOS = <Widget>[
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            Utils.infoBreedingCamera(context, getGalleryImages, gallery: true);
          },
          child: Text(
            MyLocalizations.of(context, 'gallery'),
            style: TextStyle(color: Colors.blue),
          ),
        ),
        CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
            Utils.infoBreedingCamera(context, getImage);
          },
          child: Text(
            MyLocalizations.of(context, 'camara'),
            style: TextStyle(color: Colors.blue),
          ),
        ),
      ];
      List<Widget> listForAndroid = <Widget>[
        InkWell(
          onTap: () {
            Navigator.pop(context);
            Utils.infoBreedingCamera(context, getImage);
            // _showInfoImage();
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            child: Text(MyLocalizations.of(context, 'camara'),
                style: TextStyle(color: Colors.blue, fontSize: 15)),
          ),
        ),
        Divider(height: 1.0),
        InkWell(
          onTap: () {
            Navigator.pop(context);
            Utils.infoBreedingCamera(context, getGalleryImages, gallery: true);
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            child: Text(MyLocalizations.of(context, 'gallery'),
                style: TextStyle(color: Colors.blue, fontSize: 15)),
          ),
        ),
      ];

      Utils.modalDetailTrackingforPlatform(
        Theme.of(context).platform == TargetPlatform.iOS
            ? listForiOS
            : listForAndroid,
        Theme.of(context).platform,
        context,
        () {
          Navigator.pop(context);
        },
        title: '${MyLocalizations.of(context, 'bs_info_adult_title')}:',
      );
    } else {
      _pagesController
          .nextPage(duration: Duration(microseconds: 300), curve: Curves.ease)
          .then((value) => setValid(widget.editReport != null));
    }
  }

  getGalleryImages() async {
    List<File> files = await FilePicker.getMultiFile(
      type: FileType.image,
    );

    if (files != null) {
      setShowCamera(false);
      _pagesController
          .nextPage(duration: Duration(microseconds: 300), curve: Curves.ease)
          .then((value) => setValid(widget.editReport != null));
      setState(() {
        index = _pagesController.page + 1;
      });
    }

    if (files != null) {
      files.forEach((image) {
        Utils.saveImgPath(image);
      });
    }
  }

  Future getImage(source) async {
    var image = await ImagePicker.pickImage(
      source: source,
    );

    if (image != null) {
      Utils.saveImgPath(image);
      setShowCamera(false);
      _pagesController
          .nextPage(duration: Duration(microseconds: 300), curve: Curves.ease)
          .then((value) => setValid(widget.editReport != null));
      setState(() {
        index = _pagesController.page + 1;
      });
    }
  }

  _showAlertOk() {
    loadingStream.add(false);
    Utils.showAlert(
      MyLocalizations.of(context, "app_name"),
      widget.editReport == null ? MyLocalizations.of(context, 'save_report_ok_txt') :  MyLocalizations.of(context, 'edited_report_ok_txt'),
      context,
      onPressed: () {
        Navigator.pop(context);
        if (widget.editReport != null) {
          Navigator.pop(context);
        } else {
          Navigator.of(context).popUntil((r) => r.isFirst);
        }
      },
      barrierDismissible: false,
    );
  }

  _showAlertKo() {
    loadingStream.add(false);
    Utils.showAlert(
      MyLocalizations.of(context, "app_name"),
      MyLocalizations.of(context, 'save_report_ko_txt'),
      context,
      onPressed: () {
        Navigator.pop(context);
        if (widget.editReport != null) {
          Navigator.pop(context);
        } else {
          Navigator.of(context).popUntil((r) => r.isFirst);
        }
      },
      barrierDismissible: false,
    );
  }

  _onWillPop() {
    Utils.showAlertYesNo(MyLocalizations.of(context, 'app_name'),
        MyLocalizations.of(context, 'close_report_no_save_txt'), () {
      if (Utils.reportsList != null && Utils.reportsList.isNotEmpty) {
        Utils.deleteLastReport();
      } else {
        Utils.resetReport();
        Utils.imagePath = null;
      }
      Navigator.pop(context);
    }, context);
  }
}

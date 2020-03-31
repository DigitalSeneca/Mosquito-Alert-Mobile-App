import 'package:flutter/material.dart';
import 'package:mosquito_alert_app/utils/style.dart';

class SmallQuestionOption extends StatelessWidget {
  final bool selected;
  final String text;
  SmallQuestionOption(
    this.text, {
    this.selected,
  });

  @override
  Widget build(BuildContext context) {
    return selected == null || !selected
        ? Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  new BoxShadow(
                    color: Colors.grey,
                    blurRadius: 2,
                  )
                ]),
            child: Style.body(text),
          )
        : Container(
            alignment: Alignment.center,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Style.colorPrimary,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                false
                    ? Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(3),
                          color: Colors.white.withOpacity(0.4),
                        ),
                        padding: EdgeInsets.all(5),
                        child: Style.body('2', color: Colors.white),
                      )
                    : Container(),
                Style.body(
                  text,
                  color: Colors.white,
                ),
                SizedBox(
                  width: 10,
                )
              ],
            ),
          );
  }
}

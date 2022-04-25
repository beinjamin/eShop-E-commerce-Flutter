import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Color.dart';

class SimBtn extends StatelessWidget {
  final String? title;
  final VoidCallback? onBtnSelected;
  double? size;

  SimBtn({Key? key, this.title, this.onBtnSelected, this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {

    size=MediaQuery.of(context).size.width *size!;
    return _buildBtnAnimation(context);
  }

  Widget _buildBtnAnimation(BuildContext context) {
    return CupertinoButton(
      child: Container(
          width: size,
          height: 35,
          alignment: FractionalOffset.center,
          decoration: const BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.all(Radius.circular(10.0)),
          ),
          child: Text(title!,
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .subtitle1!
                  .copyWith(color: white, fontWeight: FontWeight.normal))),
      onPressed: () {
        onBtnSelected!();
      },
    );
  }
}

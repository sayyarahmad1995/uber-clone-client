import 'package:flutter/material.dart';

class SlideUpPageTransitionsBuilder extends PageTransitionsBuilder {
  const SlideUpPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return SlideTransition(
      position: animation
          .drive(CurveTween(curve: Curves.easeInOutCubic))
          .drive(Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)),
      child: child,
    );
  }
}

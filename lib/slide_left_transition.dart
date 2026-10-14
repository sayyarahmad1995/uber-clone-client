import 'package:flutter/material.dart';

class SlideLeftPageTransitionsBuilder extends PageTransitionsBuilder {
  const SlideLeftPageTransitionsBuilder();

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
          .drive(Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)),
      child: child,
    );
  }
}

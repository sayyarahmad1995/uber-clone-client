import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/auth_shell.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: MobileFrame(
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/higo-background.png',
              fit: BoxFit.cover,
              alignment: Alignment.topCenter,
              excludeFromSemantics: true,
            ),
          ),
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    hiGoBlue,
                    hiGoBlue,
                  ],
                  stops: [0, .55, .82, 1],
                ),
              ),
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: (constraints.maxHeight - 226).clamp(
                            0,
                            double.infinity,
                          ),
                        ),
                        const Text(
                          'Welcome to HiGO',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Book rides. Drive and earn.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                        const SizedBox(height: 28),
                        FilledButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/register'),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Flexible(
                                child: Text(
                                  'Get Started',
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              SizedBox(width: 14),
                              Icon(Icons.chevron_right, size: 20),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          alignment: WrapAlignment.center,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            const Text(
                              'Already have an account?',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            TextButton(
                              key: const Key('home-login'),
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/login'),
                              child: const Text(
                                'Log In',
                                style: TextStyle(
                                  color: Color(0xFF9DA8FF),
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

import 'package:flutter/material.dart';

import 'routing/app_router.dart';

void main() {
  runApp(const ConnectCallApp());
}

class ConnectCallApp extends StatelessWidget {
  const ConnectCallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'ConnectCall',
      routerConfig: appRouter,
    );
  }
}
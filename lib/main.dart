import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_unraid/app.dart';
import 'package:flutter_unraid/blocs/app_bloc_observer.dart';
import 'package:flutter_unraid/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = const AppBlocObserver();
  await setupDependencies();
  runApp(const UnraidApp());
}

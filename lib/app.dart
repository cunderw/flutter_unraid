import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_unraid/blocs/auth/auth_cubit.dart';
import 'package:flutter_unraid/blocs/auth/auth_state.dart';
import 'package:flutter_unraid/config/theme.dart';
import 'package:flutter_unraid/data/repositories/auth_repository.dart';
import 'package:flutter_unraid/di/injection.dart';
import 'package:flutter_unraid/graphql/client.dart';
import 'package:flutter_unraid/ui/screens/home_screen.dart';
import 'package:flutter_unraid/ui/screens/login_screen.dart';

class UnraidApp extends StatelessWidget {
  const UnraidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          AuthCubit(getIt<AuthRepository>(), getIt<GraphQLClientManager>())
            ..checkAuthStatus(),
      child: MaterialApp(
        title: 'Unraid Manager',
        debugShowCheckedModeBanner: false,
        theme: unraidDarkTheme,
        home: BlocBuilder<AuthCubit, AuthState>(
          builder: (context, state) => switch (state) {
            AuthInitial() || AuthLoading() => const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: AppColors.unraidOrange),
              ),
            ),
            Authenticated() => const HomeScreen(),
            Unauthenticated() || AuthError() => const LoginScreen(),
          },
        ),
      ),
    );
  }
}

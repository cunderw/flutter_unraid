import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_unraid/utils/log.dart';

/// Global BlocObserver that logs all state transitions and errors.
class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onTransition(
    Bloc<dynamic, dynamic> bloc,
    Transition<dynamic, dynamic> transition,
  ) {
    super.onTransition(bloc, transition);
    Log.d(
      '${transition.currentState.runtimeType} → ${transition.nextState.runtimeType}',
      tag: bloc.runtimeType.toString(),
    );
  }

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    if (bloc is! Bloc) {
      // Log Cubit changes (Bloc transitions are already logged above).
      Log.d(
        '${change.currentState.runtimeType} → ${change.nextState.runtimeType}',
        tag: bloc.runtimeType.toString(),
      );
    }
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    super.onError(bloc, error, stackTrace);
    Log.e(
      'Unhandled error in ${bloc.runtimeType}',
      tag: bloc.runtimeType.toString(),
      error: error,
      stackTrace: stackTrace,
    );
  }
}

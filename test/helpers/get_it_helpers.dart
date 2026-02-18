import 'package:get_it/get_it.dart';

/// Resets [GetIt] to a clean state. Call in [setUp] or [tearDown].
void resetGetIt() {
  GetIt.instance.reset();
}

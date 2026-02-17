import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_unraid/blocs/shares/shares_state.dart';
import 'package:flutter_unraid/data/repositories/share_repository.dart';
import 'package:flutter_unraid/utils/app_exception.dart';
import 'package:flutter_unraid/utils/log.dart';

class SharesCubit extends Cubit<SharesState> {
  static const _tag = 'SharesCubit';
  final ShareRepository _repository;

  SharesCubit(this._repository) : super(const SharesInitial());

  Future<void> load() async {
    emit(const SharesLoading());
    try {
      final shares = await _repository.getShares();
      emit(SharesLoaded(shares));
    } catch (e, st) {
      final error = AppException.from(
        e,
        operation: 'loading shares',
        stackTrace: st,
      );
      Log.e('Failed to load shares', tag: _tag, error: e, stackTrace: st);
      emit(SharesError(error.message));
    }
  }

  Future<void> refresh() => load();
}

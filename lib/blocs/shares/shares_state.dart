import 'package:equatable/equatable.dart';

import 'package:flutter_unraid/data/models/share.dart';

sealed class SharesState extends Equatable {
  const SharesState();

  @override
  List<Object?> get props => [];
}

final class SharesInitial extends SharesState {
  const SharesInitial();
}

final class SharesLoading extends SharesState {
  const SharesLoading();
}

final class SharesLoaded extends SharesState {
  final List<Share> shares;

  const SharesLoaded(this.shares);

  @override
  List<Object?> get props => [shares];
}

final class SharesError extends SharesState {
  final String message;

  const SharesError(this.message);

  @override
  List<Object?> get props => [message];
}

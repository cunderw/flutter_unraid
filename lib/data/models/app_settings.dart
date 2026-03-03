import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  final bool openLinksExternally;

  const AppSettings({this.openLinksExternally = false});

  AppSettings copyWith({bool? openLinksExternally}) {
    return AppSettings(
      openLinksExternally: openLinksExternally ?? this.openLinksExternally,
    );
  }

  @override
  List<Object?> get props => [openLinksExternally];
}

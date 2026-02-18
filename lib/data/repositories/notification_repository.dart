import 'package:graphql/client.dart';

import 'package:flutter_unraid/data/models/notification.dart';
import 'package:flutter_unraid/graphql/client.dart';
import 'package:flutter_unraid/graphql/mutations.dart';
import 'package:flutter_unraid/graphql/queries.dart';
import 'package:flutter_unraid/utils/log.dart';

class NotificationRepository {
  static const _tag = 'NotificationRepository';
  final GraphQLClientManager _clientManager;

  NotificationRepository(this._clientManager);

  Future<List<Notification>> getNotifications() async {
    Log.d('Fetching notifications', tag: _tag);
    final result = await _clientManager.client.query(
      QueryOptions(
        document: gql(Queries.notifications),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) throw result.exception!;
    final notifications = result.data!['notifications'] as List<dynamic>;
    Log.d('Fetched ${notifications.length} notifications', tag: _tag);
    return notifications
        .map((e) => Notification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAsRead(String id) async {
    Log.i('Marking notification $id as read', tag: _tag);
    final result = await _clientManager.client.mutate(
      MutationOptions(
        document: gql(Mutations.markNotificationAsRead),
        variables: {'id': id},
      ),
    );
    if (result.hasException) throw result.exception!;
    Log.i('Notification $id marked as read', tag: _tag);
  }

  Future<void> markAllAsRead() async {
    Log.i('Marking all notifications as read', tag: _tag);
    final result = await _clientManager.client.mutate(
      MutationOptions(document: gql(Mutations.markAllNotificationsAsRead)),
    );
    if (result.hasException) throw result.exception!;
    Log.i('All notifications marked as read', tag: _tag);
  }

  Future<void> deleteNotification(String id) async {
    Log.i('Deleting notification $id', tag: _tag);
    final result = await _clientManager.client.mutate(
      MutationOptions(
        document: gql(Mutations.deleteNotification),
        variables: {'id': id},
      ),
    );
    if (result.hasException) throw result.exception!;
    Log.i('Notification $id deleted', tag: _tag);
  }

  Future<void> deleteAll() async {
    Log.i('Deleting all notifications', tag: _tag);
    final result = await _clientManager.client.mutate(
      MutationOptions(document: gql(Mutations.deleteAllNotifications)),
    );
    if (result.hasException) throw result.exception!;
    Log.i('All notifications deleted', tag: _tag);
  }
}

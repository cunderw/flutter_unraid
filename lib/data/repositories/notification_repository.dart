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

  Future<List<Notification>> getNotifications({
    String type = 'UNREAD',
    int offset = 0,
    int limit = 100,
  }) async {
    Log.d('Fetching notifications (type: $type)', tag: _tag);
    final result = await _clientManager.client.query(
      QueryOptions(
        document: gql(Queries.notifications),
        variables: {'type': type, 'offset': offset, 'limit': limit},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) throw result.exception!;
    final notificationsData =
        result.data!['notifications'] as Map<String, dynamic>;
    final notifications = notificationsData['list'] as List<dynamic>;
    Log.d('Fetched ${notifications.length} notifications', tag: _tag);
    return notifications
        .map((e) => Notification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> archiveNotification(String id) async {
    Log.i('Archiving notification $id', tag: _tag);
    final result = await _clientManager.client.mutate(
      MutationOptions(
        document: gql(Mutations.archiveNotification),
        variables: {'id': id},
      ),
    );
    if (result.hasException) throw result.exception!;
    Log.i('Notification $id archived', tag: _tag);
  }

  Future<void> archiveAllNotifications(List<String> ids) async {
    Log.i('Archiving ${ids.length} notifications', tag: _tag);
    final result = await _clientManager.client.mutate(
      MutationOptions(
        document: gql(Mutations.archiveNotifications),
        variables: {'ids': ids},
      ),
    );
    if (result.hasException) throw result.exception!;
    Log.i('Archived ${ids.length} notifications', tag: _tag);
  }

  Future<void> unreadNotification(String id) async {
    Log.i('Marking notification $id as unread', tag: _tag);
    final result = await _clientManager.client.mutate(
      MutationOptions(
        document: gql(Mutations.unreadNotification),
        variables: {'id': id},
      ),
    );
    if (result.hasException) throw result.exception!;
    Log.i('Notification $id marked as unread', tag: _tag);
  }

  Future<void> deleteNotification(String id, {String type = 'UNREAD'}) async {
    Log.i('Deleting notification $id', tag: _tag);
    final result = await _clientManager.client.mutate(
      MutationOptions(
        document: gql(Mutations.deleteNotification),
        variables: {'id': id, 'type': type},
      ),
    );
    if (result.hasException) throw result.exception!;
    Log.i('Notification $id deleted', tag: _tag);
  }

  Future<void> deleteArchivedNotifications() async {
    Log.i('Deleting all archived notifications', tag: _tag);
    final result = await _clientManager.client.mutate(
      MutationOptions(document: gql(Mutations.deleteArchivedNotifications)),
    );
    if (result.hasException) throw result.exception!;
    Log.i('All archived notifications deleted', tag: _tag);
  }
}

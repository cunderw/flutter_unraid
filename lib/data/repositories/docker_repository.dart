import 'package:graphql/client.dart';

import 'package:flutter_unraid/data/models/docker_container.dart';
import 'package:flutter_unraid/graphql/client.dart';
import 'package:flutter_unraid/graphql/mutations.dart';
import 'package:flutter_unraid/graphql/queries.dart';
import 'package:flutter_unraid/utils/log.dart';

class DockerRepository {
  static const _tag = 'DockerRepository';
  final GraphQLClientManager _clientManager;

  DockerRepository(this._clientManager);

  Future<List<DockerContainer>> getContainers() async {
    Log.d('Fetching containers', tag: _tag);
    final result = await _clientManager.client.query(
      QueryOptions(
        document: gql(Queries.dockerContainers),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) throw result.exception!;
    final containers = result.data!['docker']['containers'] as List<dynamic>;
    Log.d('Fetched ${containers.length} containers', tag: _tag);
    return containers
        .map((e) => DockerContainer.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _mutateContainer(
    String id,
    String action,
    String mutation,
  ) async {
    Log.i('$action container $id', tag: _tag);
    final result = await _clientManager.client.mutate(
      MutationOptions(document: gql(mutation), variables: {'id': id}),
    );
    if (result.hasException) throw result.exception!;
    Log.i('Container $id ${action.toLowerCase()} succeeded', tag: _tag);
  }

  Future<void> startContainer(String id) =>
      _mutateContainer(id, 'Starting', Mutations.startContainer);

  Future<void> stopContainer(String id) =>
      _mutateContainer(id, 'Stopping', Mutations.stopContainer);

  Future<void> restartContainer(String id) =>
      _mutateContainer(id, 'Restarting', Mutations.restartContainer);

  Future<void> removeContainer(String id, {bool withImage = false}) async {
    Log.i('Removing container $id (withImage: $withImage)', tag: _tag);
    final result = await _clientManager.client.mutate(
      MutationOptions(
        document: gql(Mutations.removeContainer),
        variables: {'id': id, 'withImage': withImage},
      ),
    );
    if (result.hasException) throw result.exception!;
    Log.i('Container $id removed', tag: _tag);
  }

  Future<List<Map<String, dynamic>>> getContainerLogs(
    String id, {
    int tail = 100,
  }) async {
    Log.d('Fetching logs for container $id (tail: $tail)', tag: _tag);
    final result = await _clientManager.client.query(
      QueryOptions(
        document: gql(Queries.dockerContainerLogs),
        variables: {'id': id, 'tail': tail},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) throw result.exception!;
    Log.d('Fetched logs for container $id', tag: _tag);
    final logs = result.data!['docker']['containerLogs'] as Map<String, dynamic>?;
    final lines = logs?['lines'] as List<dynamic>? ?? [];
    return lines.cast<Map<String, dynamic>>();
  }
}

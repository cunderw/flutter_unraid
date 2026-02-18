import 'package:graphql/client.dart';

import 'package:flutter_unraid/data/models/array_data.dart';
import 'package:flutter_unraid/data/models/system_info.dart';
import 'package:flutter_unraid/graphql/client.dart';
import 'package:flutter_unraid/graphql/mutations.dart';
import 'package:flutter_unraid/graphql/queries.dart';
import 'package:flutter_unraid/utils/log.dart';

class SystemRepository {
  static const _tag = 'SystemRepository';
  final GraphQLClientManager _clientManager;

  SystemRepository(this._clientManager);

  /// Fetches system info (os, cpu) and memory utilization in a single query.
  Future<({SystemInfo systemInfo, MemoryUtilization? memory})>
  getSystemInfo() async {
    Log.d('Fetching system info', tag: _tag);
    final result = await _clientManager.client.query(
      QueryOptions(
        document: gql(Queries.systemInfo),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) throw result.exception!;
    Log.d('System info loaded', tag: _tag);

    final info = SystemInfo.fromJson(
      result.data!['info'] as Map<String, dynamic>,
    );
    final metricsJson = result.data!['metrics'] as Map<String, dynamic>?;
    final memoryJson = metricsJson?['memory'] as Map<String, dynamic>?;
    final memory = memoryJson != null
        ? MemoryUtilization.fromJson(memoryJson)
        : null;

    return (systemInfo: info, memory: memory);
  }

  Future<ArrayData> getArrayData() async {
    Log.d('Fetching array data', tag: _tag);
    final result = await _clientManager.client.query(
      QueryOptions(
        document: gql(Queries.arrayStatus),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) throw result.exception!;
    Log.d('Array data loaded', tag: _tag);
    return ArrayData.fromJson(result.data!['array'] as Map<String, dynamic>);
  }

  Future<void> setArrayState(String desiredState) async {
    Log.i('Setting array state to $desiredState', tag: _tag);
    final result = await _clientManager.client.mutate(
      MutationOptions(
        document: gql(Mutations.setArrayState),
        variables: {'desiredState': desiredState},
      ),
    );
    if (result.hasException) throw result.exception!;
    Log.i('Array state set to $desiredState', tag: _tag);
  }

  Future<List<Map<String, dynamic>>> getSystemLogs({int? tail}) async {
    Log.d('Fetching system logs (tail: $tail)', tag: _tag);
    final result = await _clientManager.client.query(
      QueryOptions(
        document: gql(Queries.systemLogs),
        variables: {'tail': tail},
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) throw result.exception!;
    Log.d('System logs loaded', tag: _tag);
    final lines = result.data!['info']['logs']['lines'] as List;
    return lines.cast<Map<String, dynamic>>();
  }
}

import 'package:graphql/client.dart';

import 'package:flutter_unraid/data/models/vm_domain.dart';
import 'package:flutter_unraid/graphql/client.dart';
import 'package:flutter_unraid/graphql/mutations.dart';
import 'package:flutter_unraid/graphql/queries.dart';
import 'package:flutter_unraid/utils/log.dart';

class VmRepository {
  static const _tag = 'VmRepository';
  final GraphQLClientManager _clientManager;

  VmRepository(this._clientManager);

  Future<List<VmDomain>> getVms() async {
    Log.d('Fetching VMs', tag: _tag);
    final result = await _clientManager.client.query(
      QueryOptions(
        document: gql(Queries.virtualMachines),
        fetchPolicy: FetchPolicy.networkOnly,
      ),
    );
    if (result.hasException) throw result.exception!;
    final domains = result.data!['vms']['domains'] as List<dynamic>;
    Log.d('Fetched ${domains.length} VMs', tag: _tag);
    return domains
        .map((e) => VmDomain.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _mutateVm(String id, String action, String mutation) async {
    Log.i('$action VM $id', tag: _tag);
    final result = await _clientManager.client.mutate(
      MutationOptions(document: gql(mutation), variables: {'id': id}),
    );
    if (result.hasException) throw result.exception!;
    Log.i('VM $id ${action.toLowerCase()} succeeded', tag: _tag);
  }

  Future<void> startVm(String id) =>
      _mutateVm(id, 'Starting', Mutations.startVm);

  Future<void> stopVm(String id) => _mutateVm(id, 'Stopping', Mutations.stopVm);

  Future<void> forceStopVm(String id) =>
      _mutateVm(id, 'Force stopping', Mutations.forceStopVm);

  Future<void> pauseVm(String id) =>
      _mutateVm(id, 'Pausing', Mutations.pauseVm);

  Future<void> resumeVm(String id) =>
      _mutateVm(id, 'Resuming', Mutations.resumeVm);

  Future<void> rebootVm(String id) =>
      _mutateVm(id, 'Rebooting', Mutations.rebootVm);
}

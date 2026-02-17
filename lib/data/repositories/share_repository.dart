import 'package:graphql/client.dart';

import 'package:flutter_unraid/data/models/share.dart';
import 'package:flutter_unraid/graphql/client.dart';
import 'package:flutter_unraid/graphql/queries.dart';
import 'package:flutter_unraid/utils/app_exception.dart';
import 'package:flutter_unraid/utils/log.dart';

class ShareRepository {
  static const _tag = 'ShareRepository';
  final GraphQLClientManager _clientManager;

  ShareRepository(this._clientManager);

  Future<List<Share>> getShares() async {
    Log.d('Fetching shares', tag: _tag);
    try {
      final result = await _clientManager.client.query(
        QueryOptions(
          document: gql(Queries.shares),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );
      if (result.hasException) throw result.exception!;
      final shares = result.data!['shares'] as List<dynamic>;
      Log.d('Fetched ${shares.length} shares', tag: _tag);
      return shares
          .map((e) => Share.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e, st) {
      Log.e('Failed to fetch shares', tag: _tag, error: e, stackTrace: st);
      throw AppException.from(e, operation: 'fetching shares', stackTrace: st);
    }
  }
}

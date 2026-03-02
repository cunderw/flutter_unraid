import 'package:graphql/client.dart';

/// Builds a successful [QueryResult] with the given [data].
QueryResult<Object?> makeQueryResult(Map<String, dynamic> data) {
  return QueryResult(
    data: data,
    source: QueryResultSource.network,
    options: QueryOptions(document: gql('query {}')),
  );
}

/// Builds a [QueryResult] whose [hasException] is true.
QueryResult<Object?> makeErrorQueryResult(OperationException exception) {
  return QueryResult(
    exception: exception,
    source: QueryResultSource.network,
    options: QueryOptions(document: gql('query {}')),
  );
}

// ---------------------------------------------------------------------------
// JSON response fixtures matching GraphQL response structure
// ---------------------------------------------------------------------------

Map<String, dynamic> makeContainersResponseJson({int count = 2}) {
  return {
    'docker': {
      'containers': List.generate(
        count,
        (i) => {
          'id': 'container-$i',
          'names': ['/container-$i'],
          'image': 'nginx:latest',
          'imageId': 'sha256:abc$i',
          'state': i.isEven ? 'RUNNING' : 'EXITED',
          'status': 'Up 2 hours',
          'autoStart': true,
          'ports': [
            {
              'ip': '0.0.0.0',
              'privatePort': 80,
              'publicPort': 8080 + i,
              'type': 'TCP',
            },
          ],
          'iconUrl': null,
          'webUiUrl': null,
          'templatePath': null,
        },
      ),
    },
  };
}

Map<String, dynamic> makeSystemInfoResponseJson() {
  return {
    'info': {
      'os': {
        'platform': 'linux',
        'distro': 'Unraid',
        'release': '6.12.0',
        'uptime': '2025-01-01T00:00:00.000Z',
      },
      'cpu': {
        'manufacturer': 'Intel',
        'brand': 'Xeon E-2288G',
        'cores': 8,
        'threads': 16,
      },
    },
    'metrics': {
      'memory': {
        'total': 34359738368,
        'free': 17179869184,
        'used': 17179869184,
        'active': 12884901888,
        'available': 21474836480,
        'percentTotal': 50.0,
      },
    },
  };
}

Map<String, dynamic> makeArrayDataResponseJson() {
  return {
    'array': {
      'state': 'STARTED',
      'capacity': {
        'kilobytes': {'free': '1000000', 'used': '500000', 'total': '1500000'},
        'disks': {'free': '2', 'used': '3', 'total': '5'},
      },
      'disks': [
        {
          'id': 'disk1',
          'name': 'Disk 1',
          'device': 'sda',
          'size': 4000000000000,
          'status': 'DISK_OK',
          'temp': 35,
          'fsFree': 500,
          'fsUsed': 500,
          'fsSize': 1000,
          'type': 'Data',
          'color': 'green-on',
          'comment': null,
          'fsType': 'xfs',
          'numReads': 1000,
          'numWrites': 500,
          'numErrors': 0,
        },
      ],
      'parities': [
        {
          'id': 'parity1',
          'name': 'Parity',
          'device': 'sdb',
          'size': 4000000000000,
          'status': 'DISK_OK',
          'temp': 33,
          'fsFree': null,
          'fsUsed': null,
          'fsSize': null,
          'type': 'Parity',
          'color': 'green-on',
          'comment': null,
          'fsType': null,
          'numReads': 2000,
          'numWrites': 1000,
          'numErrors': 0,
        },
      ],
      'caches': [],
    },
  };
}

Map<String, dynamic> makeVmsResponseJson({int count = 2}) {
  return {
    'vms': {
      'domains': List.generate(
        count,
        (i) => {
          'id': 'vm-$i',
          'name': 'VM-$i',
          'state': i.isEven ? 'RUNNING' : 'SHUTOFF',
          'cpus': 4,
          'memory': 4294967296,
          'autostart': true,
          'template': 'Ubuntu',
          'description': 'Test VM $i',
        },
      ),
    },
  };
}

Map<String, dynamic> makeVmDetailsResponseJson({
  String id = 'vm-1',
  String name = 'TestVM',
  String state = 'RUNNING',
  int cpus = 4,
  int memory = 4294967296,
  bool autostart = true,
  String template = 'Ubuntu',
  String description = 'Test VM',
}) {
  return {
    'vms': {
      'domain': {
        'id': id,
        'name': name,
        'state': state,
        'cpus': cpus,
        'memory': memory,
        'autostart': autostart,
        'template': template,
        'description': description,
      },
    },
  };
}

Map<String, dynamic> makeSharesResponseJson({int count = 2}) {
  return {
    'shares': List.generate(
      count,
      (i) => {
        'id': 'share-$i',
        'name': 'share-$i',
        'free': 500,
        'used': 500,
        'size': 1000,
        'comment': 'Share $i',
        'cache': false,
        'include': <String>[],
        'exclude': <String>[],
        'allocator': 'highwater',
        'splitLevel': null,
        'floor': null,
        'cow': null,
        'color': 'green-on',
        'luksStatus': null,
      },
    ),
  };
}

Map<String, dynamic> makeContainerLogsResponseJson({int lineCount = 3}) {
  return {
    'docker': {
      'logs': {
        'lines': List.generate(
          lineCount,
          (i) => {
            'timestamp': '2025-01-01T00:00:0${i}Z',
            'message': 'Log line $i',
            'stream': 'stdout',
          },
        ),
      },
    },
  };
}

Map<String, dynamic> makeSystemLogsResponseJson({int lineCount = 3}) {
  final lines = List.generate(
    lineCount,
    (i) => 'Jan  1 00:00:0$i tower kernel: System log line $i',
  );
  return {
    'logFile': {'content': lines.join('\n'), 'totalLines': lineCount},
  };
}

Map<String, dynamic> makeTestConnectionResponseJson() {
  return {
    'info': {
      'os': {'platform': 'linux'},
    },
  };
}

Map<String, dynamic> makeMutationResponseJson() {
  return {'success': true};
}

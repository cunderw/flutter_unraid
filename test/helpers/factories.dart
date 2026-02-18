import 'package:flutter_unraid/data/models/array_data.dart';
import 'package:flutter_unraid/data/models/docker_container.dart';
import 'package:flutter_unraid/data/models/share.dart';
import 'package:flutter_unraid/data/models/system_info.dart';
import 'package:flutter_unraid/data/models/vm_domain.dart';

// -- ContainerPort --

ContainerPort makeContainerPort({
  String? ip = '0.0.0.0',
  int? privatePort = 80,
  int? publicPort = 8080,
  String type = 'TCP',
}) => ContainerPort(
  ip: ip,
  privatePort: privatePort,
  publicPort: publicPort,
  type: type,
);

// -- DockerContainer --

DockerContainer makeDockerContainer({
  String id = 'container-1',
  List<String> names = const ['/test-container'],
  String image = 'nginx:latest',
  String imageId = 'sha256:abc123',
  String state = 'RUNNING',
  String status = 'Up 2 hours',
  bool autoStart = true,
  List<ContainerPort>? ports,
  String? iconUrl,
  String? webUiUrl,
  String? templatePath,
}) => DockerContainer(
  id: id,
  names: names,
  image: image,
  imageId: imageId,
  state: state,
  status: status,
  autoStart: autoStart,
  ports: ports ?? [makeContainerPort()],
  iconUrl: iconUrl,
  webUiUrl: webUiUrl,
  templatePath: templatePath,
);

DockerContainer makeRunningContainer({String id = 'container-1'}) =>
    makeDockerContainer(id: id, state: 'RUNNING', status: 'Up 2 hours');

DockerContainer makeStoppedContainer({String id = 'container-2'}) =>
    makeDockerContainer(
      id: id,
      state: 'EXITED',
      status: 'Exited (0) 1 hour ago',
    );

DockerContainer makePausedContainer({String id = 'container-3'}) =>
    makeDockerContainer(id: id, state: 'PAUSED', status: 'Up 2 hours (Paused)');

// -- OsInfo --

OsInfo makeOsInfo({
  String? platform = 'linux',
  String? distro = 'Unraid',
  String? release = '6.12.0',
  String? uptime,
}) => OsInfo(
  platform: platform,
  distro: distro,
  release: release,
  uptime:
      uptime ??
      DateTime.now()
          .subtract(const Duration(days: 5, hours: 3, minutes: 12))
          .toIso8601String(),
);

// -- CpuInfo --

CpuInfo makeCpuInfo({
  String? manufacturer = 'Intel',
  String? brand = 'Xeon E-2288G',
  int? cores = 8,
  int? threads = 16,
}) => CpuInfo(
  manufacturer: manufacturer,
  brand: brand,
  cores: cores,
  threads: threads,
);

// -- MemoryUtilization --

MemoryUtilization makeMemoryUtilization({
  num? total = 34359738368,
  num? free = 17179869184,
  num? used = 17179869184,
  num? active = 12884901888,
  num? available = 21474836480,
  double? percentTotal = 50.0,
}) => MemoryUtilization(
  total: total,
  free: free,
  used: used,
  active: active,
  available: available,
  percentTotal: percentTotal,
);

// -- SystemInfo --

SystemInfo makeSystemInfo({OsInfo? os, CpuInfo? cpu}) =>
    SystemInfo(os: os ?? makeOsInfo(), cpu: cpu ?? makeCpuInfo());

// -- Capacity --

Capacity makeCapacity({
  String free = '1000000',
  String used = '500000',
  String total = '1500000',
}) => Capacity(free: free, used: used, total: total);

// -- ArrayCapacity --

ArrayCapacity makeArrayCapacity({Capacity? kilobytes, Capacity? disks}) =>
    ArrayCapacity(
      kilobytes: kilobytes ?? makeCapacity(),
      disks: disks ?? makeCapacity(free: '2', used: '3', total: '5'),
    );

// -- ArrayDisk --

ArrayDisk makeArrayDisk({
  String id = 'disk1',
  String? name = 'Disk 1',
  String? device = 'sda',
  num? size = 4000000000000,
  String? status = 'DISK_OK',
  int? temp = 35,
  num? fsFree = 500,
  num? fsUsed = 500,
  num? fsSize = 1000,
  String? type = 'Data',
  String? color = 'green-on',
  String? comment,
  String? fsType = 'xfs',
  num? numReads = 1000,
  num? numWrites = 500,
  num? numErrors = 0,
}) => ArrayDisk(
  id: id,
  name: name,
  device: device,
  size: size,
  status: status,
  temp: temp,
  fsFree: fsFree,
  fsUsed: fsUsed,
  fsSize: fsSize,
  type: type,
  color: color,
  comment: comment,
  fsType: fsType,
  numReads: numReads,
  numWrites: numWrites,
  numErrors: numErrors,
);

ArrayDisk makeHealthyDisk({String id = 'disk1'}) =>
    makeArrayDisk(id: id, status: 'DISK_OK');

ArrayDisk makeUnhealthyDisk({String id = 'disk2'}) =>
    makeArrayDisk(id: id, status: 'DISK_INVALID');

// -- ArrayData --

ArrayData makeArrayData({
  String state = 'STARTED',
  ArrayCapacity? capacity,
  List<ArrayDisk>? disks,
  List<ArrayDisk>? parities,
  List<ArrayDisk>? caches,
}) => ArrayData(
  state: state,
  capacity: capacity ?? makeArrayCapacity(),
  disks: disks ?? [makeArrayDisk(id: 'disk1'), makeArrayDisk(id: 'disk2')],
  parities: parities ?? [makeArrayDisk(id: 'parity1', name: 'Parity')],
  caches: caches ?? [],
);

ArrayData makeStartedArray() => makeArrayData(state: 'STARTED');

ArrayData makeStoppedArray() => makeArrayData(state: 'STOPPED');

// -- VmDomain --

VmDomain makeVmDomain({
  String id = 'vm-1',
  String? name = 'TestVM',
  String state = 'RUNNING',
  int? cpus = 4,
  int? memory = 4294967296,
  bool? autostart = true,
  String? template = 'Ubuntu',
  String? description = 'Test VM',
}) =>
    VmDomain(
      id: id,
      name: name,
      state: state,
      cpus: cpus,
      memory: memory,
      autostart: autostart,
      template: template,
      description: description,
    );

VmDomain makeRunningVm({String id = 'vm-1'}) =>
    makeVmDomain(id: id, state: 'RUNNING');

VmDomain makeStoppedVm({String id = 'vm-2'}) =>
    makeVmDomain(id: id, state: 'SHUTOFF');

VmDomain makePausedVm({String id = 'vm-3'}) =>
    makeVmDomain(id: id, state: 'PAUSED');

// -- Share --

Share makeShare({
  String id = 'share-1',
  String? name = 'appdata',
  num? free = 500,
  num? used = 500,
  num? size = 1000,
  String? comment = 'Application data',
  bool? cache = false,
  List<String>? include,
  List<String>? exclude,
  String? allocator = 'highwater',
  String? splitLevel,
  String? floor,
  String? cow,
  String? color = 'green-on',
  String? luksStatus,
}) => Share(
  id: id,
  name: name,
  free: free,
  used: used,
  size: size,
  comment: comment,
  cache: cache,
  include: include,
  exclude: exclude,
  allocator: allocator,
  splitLevel: splitLevel,
  floor: floor,
  cow: cow,
  color: color,
  luksStatus: luksStatus,
);

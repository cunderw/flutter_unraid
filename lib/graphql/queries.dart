/// All GraphQL query strings used by the app.
///
/// Using the raw `graphql` package with manual queries.
/// These can be replaced with Ferry-generated operations once the
/// Unraid schema is obtained from Apollo Studio.
class Queries {
  Queries._();

  static const String systemInfo = r'''
    query SystemInfo {
      info {
        os {
          platform
          distro
          release
          uptime
        }
        cpu {
          manufacturer
          brand
          cores
          threads
        }
      }
      metrics {
        memory {
          total
          free
          used
          active
          available
          percentTotal
        }
      }
    }
  ''';

  static const String arrayStatus = r'''
    query ArrayStatus {
      array {
        state
        capacity {
          kilobytes {
            free
            used
            total
          }
          disks {
            free
            used
            total
          }
        }
        disks {
          id
          name
          device
          size
          status
          temp
          fsFree
          fsUsed
          fsSize
          type
          color
          fsType
          numReads
          numWrites
          numErrors
        }
        parities {
          id
          name
          size
          status
          temp
          type
        }
        caches {
          id
          name
          size
          status
          temp
          fsFree
          fsUsed
          fsSize
          type
        }
      }
    }
  ''';

  static const String dockerContainers = r'''
    query DockerContainers {
      docker {
        containers {
          id
          names
          image
          imageId
          state
          status
          autoStart
          ports {
            ip
            privatePort
            publicPort
            type
          }
        }
      }
    }
  ''';

  static const String dockerContainerLogs = r'''
    query DockerContainerLogs($id: PrefixedID!, $tail: Int) {
      docker {
        logs(id: $id, tail: $tail) {
          containerId
          lines {
            timestamp
            message
          }
          cursor
        }
      }
    }
  ''';

  static const String systemLogs = r'''
    query SystemLogs($lines: Int) {
      logFile(path: "/var/log/syslog", lines: $lines) {
        content
        totalLines
      }
    }
  ''';

  static const String virtualMachines = r'''
    query VirtualMachines {
      vms {
        domains {
          id
          name
          state
        }
      }
    }
  ''';

  static const String vmDetails = r'''
    query VmDetails($id: PrefixedID!) {
      vms {
        domain(id: $id) {
          id
          name
          state
          cpus
          memory
          autostart
          template
          description
        }
      }
    }
  ''';

  static const String shares = r'''
    query Shares {
      shares {
        id
        name
        free
        used
        size
        comment
        cache
        include
        exclude
        allocator
        splitLevel
        floor
        cow
        color
        luksStatus
      }
    }
  ''';

  static const String notifications = r'''
    query Notifications($type: NotificationType!, $offset: Int!, $limit: Int!) {
      notifications {
        list(filter: { type: $type, offset: $offset, limit: $limit }) {
          id
          title
          subject
          description
          importance
          link
          type
          timestamp
          formattedTimestamp
        }
        overview {
          unread {
            info
            warning
            alert
            total
          }
          archive {
            info
            warning
            alert
            total
          }
        }
      }
    }
  ''';

  /// Lightweight query used to test API connectivity.
  static const String testConnection = r'''
    query TestConnection {
      info {
        os {
          platform
        }
      }
    }
  ''';
}

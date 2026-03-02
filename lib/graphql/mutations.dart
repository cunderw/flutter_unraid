/// All GraphQL mutation strings used by the app.
class Mutations {
  Mutations._();

  // ── Array ──────────────────────────────────────────────────────────────

  static const String setArrayState = r'''
    mutation SetArrayState($desiredState: ArrayStateInputState!) {
      array {
        setState(input: { desiredState: $desiredState }) {
          state
          capacity {
            kilobytes { free used total }
            disks { free used total }
          }
        }
      }
    }
  ''';

  static const String mountArrayDisk = r'''
    mutation MountArrayDisk($id: PrefixedID!) {
      array {
        mountArrayDisk(id: $id) {
          id
          name
          status
        }
      }
    }
  ''';

  static const String unmountArrayDisk = r'''
    mutation UnmountArrayDisk($id: PrefixedID!) {
      array {
        unmountArrayDisk(id: $id) {
          id
          name
          status
        }
      }
    }
  ''';

  // ── Docker ─────────────────────────────────────────────────────────────

  static const String startContainer = r'''
    mutation StartContainer($id: PrefixedID!) {
      docker {
        start(id: $id) {
          id
          names
          state
          status
        }
      }
    }
  ''';

  static const String stopContainer = r'''
    mutation StopContainer($id: PrefixedID!) {
      docker {
        stop(id: $id) {
          id
          names
          state
          status
        }
      }
    }
  ''';

  static const String restartContainer = r'''
    mutation RestartContainer($id: PrefixedID!) {
      docker {
        restart(id: $id) {
          id
          names
          state
          status
        }
      }
    }
  ''';

  static const String removeContainer = r'''
    mutation RemoveContainer($id: PrefixedID!, $withImage: Boolean) {
      docker {
        removeContainer(id: $id, withImage: $withImage)
      }
    }
  ''';

  static const String updateContainer = r'''
    mutation UpdateContainer($id: PrefixedID!) {
      docker {
        updateContainer(id: $id) {
          id
          names
          image
          state
          status
        }
      }
    }
  ''';

  // ── VMs ────────────────────────────────────────────────────────────────

  static const String startVm = r'''
    mutation StartVm($id: PrefixedID!) {
      vm {
        start(id: $id)
      }
    }
  ''';

  static const String stopVm = r'''
    mutation StopVm($id: PrefixedID!) {
      vm {
        stop(id: $id)
      }
    }
  ''';

  static const String forceStopVm = r'''
    mutation ForceStopVm($id: PrefixedID!) {
      vm {
        forceStop(id: $id)
      }
    }
  ''';

  static const String pauseVm = r'''
    mutation PauseVm($id: PrefixedID!) {
      vm {
        pause(id: $id)
      }
    }
  ''';

  static const String resumeVm = r'''
    mutation ResumeVm($id: PrefixedID!) {
      vm {
        resume(id: $id)
      }
    }
  ''';

  static const String rebootVm = r'''
    mutation RebootVm($id: PrefixedID!) {
      vm {
        reboot(id: $id)
      }
    }
  ''';

  static const String resetVm = r'''
    mutation ResetVm($id: PrefixedID!) {
      vm {
        reset(id: $id)
      }
    }
  ''';

  // ── Notifications ──────────────────────────────────────────────────────

  static const String archiveNotification = r'''
    mutation ArchiveNotification($id: PrefixedID!) {
      archiveNotification(id: $id) {
        id
        type
      }
    }
  ''';

  static const String archiveNotifications = r'''
    mutation ArchiveNotifications($ids: [PrefixedID!]!) {
      archiveNotifications(ids: $ids) {
        unread {
          total
        }
        archive {
          total
        }
      }
    }
  ''';

  static const String unreadNotification = r'''
    mutation UnreadNotification($id: PrefixedID!) {
      unreadNotification(id: $id) {
        id
        type
      }
    }
  ''';

  static const String deleteNotification = r'''
    mutation DeleteNotification($id: PrefixedID!, $type: NotificationType!) {
      deleteNotification(id: $id, type: $type) {
        unread {
          total
        }
        archive {
          total
        }
      }
    }
  ''';

  static const String deleteArchivedNotifications = r'''
    mutation DeleteArchivedNotifications {
      deleteArchivedNotifications {
        unread {
          total
        }
        archive {
          total
        }
      }
    }
  ''';
}

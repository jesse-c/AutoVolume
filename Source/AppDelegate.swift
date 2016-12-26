import Cocoa
import AudioToolbox

typealias ValInfo = [String: Float]
typealias EnabledInfo = [String: Int]

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  
  let defaults: UserDefaults = UserDefaults.standard
  let desiredVolumeKey: String = "desiredVolume"
  let enabledKey: String = "enabled"
  
  var defaultOutputDeviceID: AudioDeviceID? = kAudioObjectUnknown // TODO Remove default assigned value? Stop it being nil and default to unknown
  
  let nc: NotificationCenter = NSWorkspace.shared().notificationCenter
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // ---
    do {
      try defaultOutputDeviceID = getDefaultOutputDevice()
      NSLog("Default output device ID: \(defaultOutputDeviceID)")
      
      do {
        let currentVolume: Float32 = try getDeviceVolume(outputDeviceID: defaultOutputDeviceID!)
        NSLog("Current volume: \(currentVolume)")
      } catch VolumeError.failedToGetVolume(let status) {
        NSLog("Failed to get current volume: \(status)")
      } catch VolumeError.outputDeviceHasNoVolumeProperty {
        NSLog("Output device missing volume property")
      }
      
      do {
        try setDeviceVolume(outputDeviceID: defaultOutputDeviceID!, value: 0.25)
      } catch VolumeError.failedToSetVolume(let status) {
        NSLog("Failed to set current volume: \(status)")
      } catch VolumeError.outputDeviceHasNoVolumeProperty {
        NSLog("Output device missing volume property")
      }
    } catch {
      NSLog("No default output device found")
      return
    }
    
    // ---
    NSLog("Setting up notification handlers")
    nc.addObserver(self, selector: #selector(self.handleWillSleep), name: NSNotification.Name.NSWorkspaceWillSleep, object: nil)
    nc.addObserver(self, selector: #selector(self.handleDidWake), name: NSNotification.Name.NSWorkspaceDidWake, object: nil)
    nc.addObserver(self, selector: #selector(self.handleVolumeChanged), name: NSNotification.Name.OnVolumeChanged, object: nil)
    nc.addObserver(self, selector: #selector(self.handleEnabledStateChanged), name: NSNotification.Name.OnEnabledButtonPressed, object: nil)
    
    // TODO Bring window to front
  }
  
  func handleWillSleep(notification: Notification) {
    NSLog("Received \(notification.name)")
  }
  
  func handleDidWake(notification: Notification) {
    NSLog("Received \(notification.name)")
    
    // Check if enabled state is on
    let enabledState = defaults.integer(forKey: enabledKey)
    guard enabledState == NSOnState else {
      NSLog("Not enabled")
      return
    }
    
    let err = checkOutputDevice(outputDeviceID: defaultOutputDeviceID!)
    guard err == nil else {
      NSLog(err!.localizedDescription)
      return
    }
    
    // Defaults to 0.0 if no value had been set
    let desiredVolume = defaults.float(forKey: desiredVolumeKey)
    
    do {
      try setDeviceVolume(outputDeviceID: defaultOutputDeviceID!, value: desiredVolume)
      NSLog("Set volume to \(desiredVolume)")
    } catch VolumeError.failedToSetVolume {
      NSLog("Failed to set volume")
    } catch VolumeError.outputDeviceHasNoVolumeProperty {
      NSLog("Output device has no volume property")
    } catch {
      NSLog("Other")
    }
  }
  
  func handleVolumeChanged(notification: Notification) {
    NSLog("Received \(notification.name)")
    let userInfo = notification.userInfo as! ValInfo
    defaults.set(userInfo["val"], forKey: desiredVolumeKey)
  }
  
  func handleEnabledStateChanged(notification: Notification) {
    NSLog("Received \(notification.name)")
    let userInfo = notification.userInfo as! EnabledInfo
    defaults.set(userInfo["buttonState"], forKey: enabledKey)
  }
  
  func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    /* TODO For now, we know there is only 1 window, so we can access the 0th element
     * But ideally we're a bit smarter about this—i.e. check for which window to
     * make key and visible.
     */
    let windows = sender.windows
    if windows.count > 0 {
      sender.windows[0].makeKeyAndOrderFront(self)
      return true
    }
    
    return false
  }
  
  func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
    return false
  }

  func applicationWillTerminate(_ aNotification: Notification) {
    nc.removeObserver(self)
  }
  
}


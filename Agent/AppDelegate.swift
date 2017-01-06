import Cocoa
import AudioToolbox
import ServiceManagement

typealias ValInfo = [String: Float]
typealias EnabledInfo = [String: Int]
typealias LoginStartInfo = [String: Int]

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  
  let defaults: UserDefaults = UserDefaults.standard
  let desiredVolumeKey: String = "desiredVolume"
  let enabledKey: String = "enabled"
  let loginStartKey: String = "loginStart"
  
  var defaultOutputDeviceID: AudioDeviceID? = kAudioObjectUnknown // TODO Remove default assigned value? Stop it being nil and default to unknown
  
  let nc: NotificationCenter = NSWorkspace.shared().notificationCenter
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // Notifications
    NSLog("Setting up notification handlers")
    nc.addObserver(self, selector: #selector(self.handleWillSleep), name: NSNotification.Name.NSWorkspaceWillSleep, object: nil)
    nc.addObserver(self, selector: #selector(self.handleDidWake), name: NSNotification.Name.NSWorkspaceDidWake, object: nil)
    nc.addObserver(self, selector: #selector(self.handleVolumeChanged), name: NSNotification.Name.OnVolumeChanged, object: nil)
    nc.addObserver(self, selector: #selector(self.handleEnabledStateChanged), name: NSNotification.Name.OnEnabledButtonPressed, object: nil)
    nc.addObserver(self, selector: #selector(self.handleLoginStartStateChanged), name: NSNotification.Name.OnLoginStartButtonPressed, object: nil)
    nc.addObserver(self, selector: #selector(self.handleQuit), name: NSNotification.Name.OnQuitButtonPressed, object: nil)
    
    do {
      try defaultOutputDeviceID = getDefaultOutputDevice()
      NSLog("Default output device ID: \(defaultOutputDeviceID)")
    } catch VolumeError.noDefaultOutputDevice {
      NSLog("No default output device found, qutting")
      showAlert(style: NSAlertStyle.critical, message: "Failed to find system audio device.", info: "Application will now quit.")
      self.nc.post(name: NSNotification.Name.OnQuitButtonPressed, object: nil, userInfo: nil)
    } catch {
      showAlert(style: NSAlertStyle.critical, message: error as! String, info: "Application will now quit.")
    }
    
    // Bring to front
    NSApplication.shared().activate(ignoringOtherApps: true)
  }
  
  func showAlert(style: NSAlertStyle, message: String, info: String) {
    let alert = NSAlert.init()
    alert.alertStyle = NSAlertStyle.critical
    alert.messageText = message
    alert.informativeText = info
    alert.addButton(withTitle: "Okay")
    alert.runModal()
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
  
  func handleLoginStartStateChanged(notification: Notification) {
    NSLog("Received \(notification.name)")
    let userInfo = notification.userInfo as! LoginStartInfo
    let state = (userInfo["buttonState"] == NSOnState)
  
    _ = setLoginStartState(state: state)
    defaults.set(userInfo["buttonState"], forKey: loginStartKey)
  }
  
  func setLoginStartState(state: Bool) -> Bool {
    let appBundleIdentifier = "jesse-c.AgentHelper"
    
    if SMLoginItemSetEnabled(appBundleIdentifier as CFString, state) {
      if state {
        NSLog("Successfully add login item.")
      } else {
        NSLog("Successfully remove login item.")
      }
      
      return true
    } else {
      NSLog("Failed to add login item.")
      
      return false
    }
  }
  
  func handleEnabledStateChanged(notification: Notification) {
    NSLog("Received \(notification.name)")
    let userInfo = notification.userInfo as! EnabledInfo
    defaults.set(userInfo["buttonState"], forKey: enabledKey)
  }
  
  func handleQuit(notification: Notification) {
    NSApplication.shared().terminate(self)
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
    defaults.synchronize()
  }
  
}


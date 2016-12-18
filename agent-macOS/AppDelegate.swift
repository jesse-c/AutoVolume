import Cocoa
import AudioToolbox

// TODO Add function to check device (simplifies repeated if checks

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  let desiredVolumeKey: String = "desiredVolume"
  
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // ---
    var defaultOutputDeviceID: AudioDeviceID? = kAudioObjectUnknown // TODO Remove default assigned value?
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
    }
    
    // ---
    let defaults = UserDefaults.standard
    defaults.set(0.0, forKey: desiredVolumeKey)
    var desiredVolume = defaults.float(forKey: desiredVolumeKey)
    
    // ---
    NSLog("Setting up will sleep & did wake notifications")
    let nc = NSWorkspace.shared().notificationCenter
    nc.addObserver(forName: NSNotification.Name.NSWorkspaceWillSleep, object: nil, queue: nil) { (notification: Notification) in
      NSLog("Workspace will sleep")
      NSLog(notification.description)
    }
    
    nc.addObserver(forName: NSNotification.Name.NSWorkspaceDidWake, object: nil, queue: nil) { (notification: Notification) in
      NSLog("Workspace did wake")
      NSLog(notification.description)
      guard defaultOutputDeviceID != nil && defaultOutputDeviceID != kAudioObjectUnknown else {
        NSLog("defaultOutputDeviceID invalid")
        return
      }
      

      do {
        try setDeviceVolume(outputDeviceID: defaultOutputDeviceID!, value: desiredVolume)
      } catch VolumeError.failedToSetVolume {
          
      } catch VolumeError.outputDeviceHasNoVolumeProperty {
          
      } catch {
      
      }

    }
  }

  func applicationWillTerminate(_ aNotification: Notification) {
  }
}


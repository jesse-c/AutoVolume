import Cocoa
import AudioToolbox

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    let defaultOutputDeviceID: AudioDeviceID?
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
    
    NSLog("Setting up will sleep & did wake notifications")
    let nc = NSWorkspace.shared().notificationCenter
    nc.addObserver(forName: NSNotification.Name.NSWorkspaceWillSleep, object: nil, queue: nil) { (notification: Notification) in
      NSLog("Workspace will sleep")
      NSLog(notification.description)
    }
    
    nc.addObserver(forName: NSNotification.Name.NSWorkspaceDidWake, object: nil, queue: nil) { (notification: Notification) in
      NSLog("Workspace did wake")
      NSLog(notification.description)
    }
  }

  func applicationWillTerminate(_ aNotification: Notification) {
  }
}


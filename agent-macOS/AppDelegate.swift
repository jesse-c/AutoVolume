import Cocoa
import AudioToolbox

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // Insert code here to initialize your application
        
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
        try setDeviceVolume(outputDeviceID: defaultOutputDeviceID!, value: 0.5)
      } catch VolumeError.failedToSetVolume(let status) {
        NSLog("Failed to set current volume: \(status)")
      } catch VolumeError.outputDeviceHasNoVolumeProperty {
        NSLog("Output device missing volume property")
      }
    } catch {
      NSLog("No default output device found")
    }
    

  }

  func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
  }

  
}


import Foundation
import AudioToolbox

enum VolumeError: Error {
  case noDefaultOutputDevice(status: Int32)
  case invalidOutputDeviceID
  case outputDeviceHasNoVolumeProperty
  case invalidVolumeValue
  case failedToSetVolume(status: Int32)
  case failedToGetVolume(status: Int32)
}

func getDefaultOutputDevice() throws -> AudioDeviceID {
  var defaultOutputDeviceID: AudioDeviceID  = AudioDeviceID(0)
  var defaultOutputDeviceIDSize: UInt32 = UInt32(MemoryLayout.size(ofValue: defaultOutputDeviceID))
  
  var getDefaultOutputDevicePropertyAddress = AudioObjectPropertyAddress(
      mSelector: AudioObjectPropertySelector(kAudioHardwarePropertyDefaultOutputDevice),
      mScope: AudioObjectPropertyScope(kAudioObjectPropertyScopeGlobal),
      mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
    
  let status = AudioObjectGetPropertyData(
      AudioObjectID(kAudioObjectSystemObject),
      &getDefaultOutputDevicePropertyAddress,
      0,
      nil,
      &defaultOutputDeviceIDSize,
      &defaultOutputDeviceID
  )
    
  guard defaultOutputDeviceID != kAudioObjectUnknown && status == noErr else {
    throw VolumeError.noDefaultOutputDevice(status: status)
  }
    
  return defaultOutputDeviceID
}


func setDeviceVolume(outputDeviceID: AudioDeviceID, value: Float32) throws {
  guard value >= 0.0 || value <= 1.0 else {
      throw VolumeError.invalidVolumeValue
  }
  
  var volume = value
  let volumeSize = UInt32(MemoryLayout.size(ofValue: volume))
    
  var volumePropertyAddress = AudioObjectPropertyAddress(
      mSelector: AudioObjectPropertySelector(kAudioHardwareServiceDeviceProperty_VirtualMasterVolume),
      mScope: AudioObjectPropertyScope(kAudioDevicePropertyScopeOutput),
      mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
  
  guard AudioObjectHasProperty(outputDeviceID, &volumePropertyAddress) else {
    throw VolumeError.outputDeviceHasNoVolumeProperty
  }
    
  let status = AudioObjectSetPropertyData(
      outputDeviceID,
      &volumePropertyAddress,
      0,
      nil,
      volumeSize,
      &volume
  )
    
  guard status == noErr else {
    throw VolumeError.failedToSetVolume(status: status)
  }
}

func getDeviceVolume(outputDeviceID: AudioDeviceID) throws -> Float32 {
  guard outputDeviceID != kAudioObjectUnknown else {
    throw VolumeError.invalidOutputDeviceID
  }
  
  var volume: Float32 = -1.0
  var volumeSize = UInt32(MemoryLayout.size(ofValue: volume))
  
  var volumePropertyAddress = AudioObjectPropertyAddress(
    mSelector: AudioObjectPropertySelector(kAudioHardwareServiceDeviceProperty_VirtualMasterVolume),
    mScope: AudioObjectPropertyScope(kAudioDevicePropertyScopeOutput),
    mElement: AudioObjectPropertyElement(kAudioObjectPropertyElementMaster))
  
  guard AudioObjectHasProperty(outputDeviceID, &volumePropertyAddress) else {
    throw VolumeError.outputDeviceHasNoVolumeProperty
  }
  
  let status = AudioObjectGetPropertyData(
      outputDeviceID,
      &volumePropertyAddress,
      0,
      nil,
      &volumeSize,
      &volume
  )
  
  guard status == noErr && volume != -1.0 else {
    throw VolumeError.failedToGetVolume(status: status)
  }
  
  return volume
}

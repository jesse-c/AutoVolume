# AutoVolume (Mac)

AutoVolume automatically sets the volume of macOS to a specified volume. At the moment it only fires on sleep. For example, the primary use case is to set the system volume to 0 when waking from sleep to save being surprised if you were listening to music quite loud before you closed it and fell asleep.

Why? To learn about macOS development, begin the 'Agent' idea, and practice design.

Alternative:

Use HammerSpoon and hook into [systemDidWake](http://www.hammerspoon.org/docs/hs.caffeinate.watcher.html#systemDidWake) and [mute default audio device](https://github.com/STRML/init/blob/master/hammerspoon/init.lua#L218).

## TODO

- Fix start at login
- Add user notifications
- Remove NSLog or hide behind debug flag

## Wishlist

- Choose audio device
- Choose event for when to act
- Only change volume if a specified amount of time has elapsed
- Add option to display the current volume in a notable way on event
- Act only if volume is above a specified threshold

## Contributing

Contributions are welcome! Clone the repository and create a pull request.

## License

__N.B.__ Why the 'Agent' references? It's part of another idea I'm working on with the idea being that auto volume is a an action.

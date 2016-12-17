# Initial thought
Date: 16-06-26
Location: Home
Inspiration: Email notification was loud - volume was up because I watched a show last night
Solution: If sleep longer than time period x, show a notification on log in with action to mute
Why is it worth the effort?
What already exists?

Option: Mute volume if > 0, or > $threshold
Option: Warn if > 0, or > $threshold

Start at login

Script or program or daemon

Tell the user with a small notification if something was done like lowering the volume or muting
Would it need to be set at sleep?

Not another menu bar app - System Preferences alone instead? Or just commandline at first? Where to store preferences?

1. Wake/sleep notification receiver -> Daemon (is a daemon the best? Is it different to some other generic process?)
2. Get/set volume -> Daemon
3. Execute action(s) -> Daemon
3. UI for daemon
  - Start at login
  - Action(s) to take

  Spectacle, NoSleep

  UserDefaults for preferences?
  Notifications

! Rename to agent-macOS

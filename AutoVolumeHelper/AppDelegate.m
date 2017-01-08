//
//  AppDelegate.m
//  AgentHelper
//
//  Created by Jesse Claven on 29/12/16.
//  Copyright © 2016 Jesse Claven. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  NSArray *pathComponents = [[[NSBundle mainBundle] bundlePath] pathComponents];
  pathComponents = [pathComponents subarrayWithRange:NSMakeRange(0, [pathComponents count] - 4)];
  NSString *path = [NSString pathWithComponents:pathComponents];
  [[NSWorkspace sharedWorkspace] launchApplication:path];
  [NSApp terminate:nil];
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end

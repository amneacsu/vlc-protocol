// https://www.cocoawithlove.com/2010/09/minimalist-cocoa-programming.html
#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>
@end

@implementation AppDelegate

- (void)handleAppleEvent:(NSAppleEventDescriptor *)event withReplyEvent: (NSAppleEventDescriptor *)replyEvent {
  // Get input data
  NSString *input = [[event paramDescriptorForKeyword:keyDirectObject] stringValue];
  NSString *url;
  NSString *urlTemp;

  NSLog(@"Received input: %@", input);

  if ([input hasPrefix:@"vlc://"]) {
    urlTemp = [input substringFromIndex:6];
    NSLog(@"URL after vlc:// prefix: %@", urlTemp);
  }
  else if ([input hasPrefix:@"vlc:"]) {
    urlTemp = [input substringFromIndex:4];
    NSLog(@"URL after vlc: prefix: %@", urlTemp);
  }
  else {
    // invalid input
    NSLog(@"Invalid input, terminating application.");
    [NSApp terminate:nil];
    return;
  }

  if ([urlTemp hasPrefix:@"http//"]) {
    // Replace "http//" with "http://"
    url = [urlTemp stringByReplacingCharactersInRange:NSMakeRange(0, 6) withString:@"http://"];
  }
  else if ([urlTemp hasPrefix:@"https//"]) {
    // Replace "https//" with "https://"
    url = [urlTemp stringByReplacingCharactersInRange:NSMakeRange(0, 7) withString:@"https://"];
  }
  else {
    // No changes if it doesn't start with "https//"
    url = urlTemp;
  }

  // Only allow urls starting with http:// or https://
  if (![url hasPrefix:@"http://"] && ![url hasPrefix:@"https://"]) {
    // protocol not allowed
    NSLog(@"URL protocol not allowed, terminating application: %@", url);
    [NSApp terminate:nil];
    return;
  }

  NSLog(@"Valid URL: %@", url);

  // Launch VLC
  NSWorkspace *ws = [NSWorkspace sharedWorkspace];
  NSURL *app = [NSURL fileURLWithPath:@"/Applications/VLC.app"];
  NSArray *arguments = [NSArray arrayWithObjects: @"--open", url, nil];
  NSMutableDictionary *config = [[NSMutableDictionary alloc] init];
  [config setObject:arguments forKey:NSWorkspaceLaunchConfigurationArguments];
  [ws launchApplicationAtURL:app options:NSWorkspaceLaunchNewInstance configuration:config error:nil];

  // Close this program
  [NSApp terminate:nil];
}

- (void)applicationDidFinishLaunching:(NSNotification *)notification {
  // Close this program if it wasn't launched using a link (i.e. launched normally)
  [NSApp terminate:nil];
}

@end

int main() {
  // Make sure the shared application is created
  [NSApplication sharedApplication];

  AppDelegate *appDelegate = [AppDelegate new];
  NSAppleEventManager *sharedAppleEventManager = [NSAppleEventManager new];
  [sharedAppleEventManager setEventHandler:appDelegate
                               andSelector:@selector(handleAppleEvent:withReplyEvent:)
                             forEventClass:kInternetEventClass
                                andEventID:kAEGetURL];

  [NSApp setDelegate:appDelegate];
  [NSApp run];
  return 0;
}

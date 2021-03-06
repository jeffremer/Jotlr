//
//  JotlrAppDelegate.h
//  Jotlr
//
//  Created by Jeff Remer on 7/22/10.
//  Copyright 2010 Widgetbox, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class MAAttachedWindow;
@class YRKSpinningProgressIndicator;

@interface JotlrAppDelegate : NSObject <NSApplicationDelegate> {
}

@property (assign) IBOutlet NSWindow *window;
@property (assign) MAAttachedWindow *attachedWindow;
@property (assign) IBOutlet NSView *view;
@property (assign) IBOutlet NSStatusItem *statusItem;
@property (assign) NSPasteboard *pasteboard;
@property (copy) NSString *currentClip;
@property BOOL shouldCreateJot;
@property NSInteger initialChangeCount;
@property NSInteger previousChangeCount;
@property (assign) IBOutlet NSButton *linkButton;
@property (assign) IBOutlet NSButton *rawButton;
@property (assign) NSMutableData *responseData;
@property (assign) IBOutlet YRKSpinningProgressIndicator *progressBar;

- (void) createJot;
- (void)toggleAttachedWindowAtPoint:(NSPoint)pt withSender:(id)sender;
- (IBAction) openMainUrl:(id) sender;
- (IBAction) openRawUrl: (id) sender;
- (IBAction) mailUrl: (id) sender;

@end

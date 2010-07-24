//
//  JotlrAppDelegate.h
//  Jotlr
//
//  Created by Jeff Remer on 7/22/10.
//  Copyright 2010 Widgetbox, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Jot.h"

@class MAAttachedWindow;
@interface JotlrAppDelegate : NSObject <NSApplicationDelegate,NSXMLParserDelegate> {
    NSWindow *window;
	IBOutlet NSMenu *statusMenu;
	IBOutlet NSMenuItem *noJotsYetItem;
	IBOutlet NSPanel *jotPanel;
	IBOutlet NSTextField *jotLabel;
	MAAttachedWindow *attachedWindow;
	IBOutlet NSView *view;
	IBOutlet NSButton *linkButton;
	
	NSStatusItem *statusItem;
	NSPasteboard *pasteboard;
	NSString *currentItem;
	NSInteger previousChangeCount;
	NSMutableData *responseData;
	
	NSMutableString *currentProperty;
	Jot *currentJot;
	
	NSString *currentClip;
	
	NSInteger initialChangeCount;
	BOOL shouldCreateJot;
	
}

@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, retain) NSMutableString *currentProperty;
@property (nonatomic, retain) Jot *currentJot;
@property (copy) NSString *currentClip;
@property BOOL shouldCreateJot;

- (void) createJot:(NSString *) permalink;
- (void)toggleAttachedWindowAtPoint:(NSPoint)pt withSender:(id)sender;
- (IBAction) openUrl:(id) sender;

@end

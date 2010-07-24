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

	MAAttachedWindow *attachedWindow;
	IBOutlet NSView *view;
	IBOutlet NSButton *linkButton;
	
	NSStatusItem *statusItem;
	
	NSInteger initialChangeCount;
	NSInteger previousChangeCount;
	NSPasteboard *pasteboard;

	NSString *currentItem;
	

	NSMutableData *responseData;
	
	NSMutableString *currentProperty;
	Jot *currentJot;
	
	NSString *currentClip;
	

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

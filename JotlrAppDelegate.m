//
//  JotlrAppDelegate.m
//  Jotlr
//
//  Created by Jeff Remer on 7/22/10.
//  Copyright 2010 Widgetbox, Inc. All rights reserved.
//

#import "JotlrAppDelegate.h"
#import "CustomView.h"
#import "MAAttachedWindow.h"
#import "JotParser.h"

@implementation JotlrAppDelegate

@synthesize window,
			attachedWindow,
			view,
			statusItem,
			pasteboard,
			currentClip,
			shouldCreateJot,
			initialChangeCount,
			previousChangeCount,
			linkButton,
			responseData;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	pasteboard = [[NSPasteboard generalPasteboard] retain];
	initialChangeCount = [pasteboard changeCount];
	[NSTimer scheduledTimerWithTimeInterval:0.25 target:self selector:@selector(pollPasteboard:) userInfo:nil repeats:YES];
}

- (void)pollPasteboard:(NSTimer *)timer {
    NSInteger currentChangeCount = [pasteboard changeCount];
    if (currentChangeCount == previousChangeCount || currentChangeCount == initialChangeCount)
        return;    
	NSArray *classes = [[NSArray alloc] initWithObjects:[NSString class], nil];
	NSDictionary *options = [NSDictionary dictionary];
	NSArray *copiedItems = [pasteboard readObjectsForClasses:classes options:options];
	if (copiedItems != nil) {
		self.currentClip = [copiedItems objectAtIndex:0];
		self.shouldCreateJot = YES;
	}
    self.previousChangeCount = currentChangeCount;
}


- (void) awakeFromNib {
	float width = 30.0;
	float height = [[NSStatusBar systemStatusBar] thickness];
	NSRect viewFrame = NSMakeRect(0, 0, width, height);
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:width] retain];
	[statusItem setView:[[[CustomView alloc] initWithFrame:viewFrame controller:self] autorelease]];
}

- (void) createJot {	
	NSString *text = [NSString stringWithFormat:@"jot=%@", [self.currentClip stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];	
	NSMutableURLRequest *urlRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://j.otdown.com/app/doSave.php"]];
	[urlRequest setHTTPMethod:@"POST"];
	[urlRequest setHTTPBody: [text dataUsingEncoding:NSASCIIStringEncoding]];
	
	NSURLConnection *connectionResponse = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];

	if (!connectionResponse) {
		NSLog(@"Failed to submit request");
	} else {
		NSLog(@"Request submitted");
		responseData = [[NSMutableData alloc] init];
	}
}

- (void) parseJot:(NSData *) jotData {
	JotParser *parser = [[JotParser alloc] initWithData:jotData];
	Jot *jot = [parser parseJot];
	self.shouldCreateJot = NO;
	if([jot.permalink length] > 0) {
		[linkButton setTitle:jot.permalink];
	}	
}

- (void) copyJot:(NSString *) permalink {
	pasteboard = [NSPasteboard generalPasteboard];
	[pasteboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
	[pasteboard setData:[permalink dataUsingEncoding: NSASCIIStringEncoding] forType:NSStringPboardType];
}


- (IBAction) openUrl:(id) sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[sender title]]];
	[attachedWindow orderOut:self];
	[attachedWindow release];
	attachedWindow = nil;
	[(CustomView *) [statusItem view] reset];
}
	 
- (void)toggleAttachedWindowAtPoint:(NSPoint)pt withSender:(id) sender {
	if (!attachedWindow) {
		attachedWindow = [[MAAttachedWindow alloc] initWithView:view 
												attachedToPoint:pt 
													   inWindow:nil 
														 onSide:MAPositionBottom 
													 atDistance:5.0];
		[attachedWindow setLevel:NSFloatingWindowLevel];
		NSLog(@"Making new window");
	}
	if(![attachedWindow isVisible]) {
		[attachedWindow makeKeyAndOrderFront:self];
		if(self.shouldCreateJot) {
			[self createJot];
		}	
	} else {
		[attachedWindow orderOut:self];
	}    
}

#pragma mark -

#pragma mark Jot Downloader

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	[responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[responseData appendData:data];	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [connection release];
    [responseData release];
	NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	[self parseJot: responseData];
    [connection release];
}

@end
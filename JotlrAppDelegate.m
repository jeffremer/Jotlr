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

@implementation JotlrAppDelegate

@synthesize window, currentProperty, currentJot, currentClip, shouldCreateJot;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	pasteboard = [[NSPasteboard generalPasteboard] retain];
	initialChangeCount = [pasteboard changeCount];
	shouldCreateJot = TRUE;
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
		currentClip = [copiedItems objectAtIndex:0];
	}
    previousChangeCount = currentChangeCount;
}


- (void) awakeFromNib {
	float width = 30.0;
	float height = [[NSStatusBar systemStatusBar] thickness];
	NSRect viewFrame = NSMakeRect(0, 0, width, height);
	statusItem = [[[NSStatusBar systemStatusBar] statusItemWithLength:width] retain];
	[statusItem setView:[[[CustomView alloc] initWithFrame:viewFrame controller:self] autorelease]];
}

- (void) createJot:(NSString *) string {	
	currentClip = nil;
	NSString *text = [NSString stringWithFormat:@"jot=%@", [string stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];	
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

- (void) createJotFromClipBoard {
	[self createJot:currentClip];
}

- (void) parseJot:(NSData *) jotData {
	NSXMLParser *parser = [[NSXMLParser alloc] initWithData:jotData];
	[parser setDelegate:self];
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	
	[parser parse];
	[parser release];
	
	if(self.currentJot && [self.currentJot.permalink length] > 0) {
		[linkButton setTitle:self.currentJot.permalink];
	} else {
		[linkButton setTitle:@"http://j.otdown.com"];
	}
	
	[(CustomView*)[statusItem view] toggleAttachedWindow];
}

- (void) copyJot:(NSString *) permalink {
	NSLog(@"Copying %@", self.currentJot.permalink);
	
	pasteboard = [NSPasteboard generalPasteboard];
	[pasteboard declareTypes:[NSArray arrayWithObject:NSStringPboardType] owner:nil];
	[pasteboard setData:[permalink dataUsingEncoding: NSASCIIStringEncoding] forType:NSStringPboardType];
}
	 
- (void)toggleAttachedWindowAtPoint:(NSPoint)pt withSender:(id) sender {
	if(currentClip != nil) {
		[self createJot:currentClip];
		return;
	}
	// Attach/detach window.
	if (!attachedWindow) {
		attachedWindow = [[MAAttachedWindow alloc] initWithView:view 
												attachedToPoint:pt 
													   inWindow:nil 
														 onSide:MAPositionBottom 
													 atDistance:5.0];

		[attachedWindow makeKeyAndOrderFront:self];
	} else {
		[attachedWindow orderOut:self];
		[attachedWindow release];
		attachedWindow = nil;
	}    
}

- (IBAction) openUrl:(id) sender {
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:[sender title]]];
	[attachedWindow orderOut:self];
	[attachedWindow release];
	attachedWindow = nil;
	[(CustomView *) [statusItem view] reset];
}
	 

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if (self.currentProperty) {
        [currentProperty appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    if (qName) {
        elementName = qName;
    }
	if(self.currentJot) {
		if ([elementName isEqualToString:@"permalink"]) {
			self.currentProperty = [NSMutableString string];
		}
	} else {
		if([elementName isEqualToString:@"jot"]) {
			self.currentJot = [[Jot alloc] init];
		}
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if (qName) {
        elementName = qName;
    }
	
    if (self.currentJot) {
        if ([elementName isEqualToString:@"permalink"]) {
            self.currentJot.permalink = self.currentProperty;
		}
	}
	self.currentProperty = nil;
}
	
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
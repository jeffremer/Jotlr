//
//  CustomView.m
//  NSStatusItemTest
//
//  Created by Matt Gemmell on 04/03/2008.
//  Copyright 2008 Magic Aubergine. All rights reserved.
//

#import "CustomView.h"
#import "JotlrAppDelegate.h"

@implementation CustomView

- (id)initWithFrame:(NSRect)frame controller:(JotlrAppDelegate *)ctrlr
{
    if (self = [super initWithFrame:frame]) {
        controller = ctrlr; // deliberately weak reference.
    }
	
	[self registerForDraggedTypes: [NSArray arrayWithObjects:NSFilenamesPboardType, NSStringPboardType, nil]]; 
    
    return self;
}


- (void)dealloc
{
    controller = nil;
    [super dealloc];
}

- (id)reset {
	draggedOver = NO;
	clicked = NO;	
	[self display];
	return self;
}

- (void)drawRect:(NSRect)rect {
    // Draw background if appropriate.
    if (clicked || draggedOver) {
        [[NSColor selectedMenuItemColor] set];
        NSRectFill(rect);
    }    
      
    NSString *imgName = @"jotlr.png";
	if(clicked || draggedOver) imgName = @"jotlr-alt.png";
	NSImage *image = [NSImage imageNamed:imgName];
	NSSize size = [image size];
	NSRect imgRect = NSMakeRect(0, 0, size.width, size.height);
	imgRect.origin.x = ([self frame].size.width - size.width) / 2.0;
    imgRect.origin.y = ([self frame].size.height - size.height) / 2.0;
	[image drawInRect:imgRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1];	
}


- (void)mouseDown:(NSEvent *)event {
	[self toggleAttachedWindow];
}

-(id)toggleAttachedWindow {
	NSRect frame = [[self window] frame];
    NSPoint pt = NSMakePoint(NSMidX(frame), NSMinY(frame));
    [controller toggleAttachedWindowAtPoint:pt withSender:self];
    clicked = !clicked;
    [self setNeedsDisplay:YES];
	return self;
}

-(NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender {
	draggedOver = YES;
	[self display];
	return NSDragOperationEvery;
}
- (void)draggingExited:(id < NSDraggingInfo >)sender {
	draggedOver = NO;
	[self display];
}

-(NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender {
	return NSDragOperationEvery;	
}
- (BOOL) prepareForDragOperation:(id <NSDraggingInfo>)sender {
	draggedOver = NO;
	[self display];
	return YES;
}
- (BOOL) performDragOperation:(id <NSDraggingInfo>)sender {
	NSPasteboard *pasteboard;
	NSDragOperation sourceDragMask;
	sourceDragMask = [sender draggingSourceOperationMask];
	pasteboard = [sender draggingPasteboard];
	if([[pasteboard types] containsObject:NSStringPboardType]) {
		NSArray *classArray = [NSArray arrayWithObject:[NSString class]];
		NSDictionary *options = [NSDictionary dictionary];
		
		if([pasteboard canReadObjectForClasses:classArray options:options]) {
			NSArray *objects = [pasteboard readObjectsForClasses:classArray options:options];
			NSString *string = [objects objectAtIndex:0];
			NSLog(@"Dragged String: %@", string);
			[controller setCurrentClip:nil];
			[controller createJot:string];
		}
	}	
	
	return YES;
}


@end

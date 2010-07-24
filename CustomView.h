//
//  CustomView.h
//  NSStatusItemTest
//
//  Created by Matt Gemmell on 04/03/2008.
//  Copyright 2008 Magic Aubergine. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class JotlrAppDelegate;
@interface CustomView : NSView {
    __weak JotlrAppDelegate *controller;
    BOOL clicked;
	BOOL draggedOver;
}

- (id)initWithFrame:(NSRect)frame controller:(JotlrAppDelegate *)ctrlr;
- (id)toggleAttachedWindow;
- (id)reset;
@end

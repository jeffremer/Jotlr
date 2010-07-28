//
//  JotParser.h
//  Jotlr
//
//  Created by Jeff Remer on 7/27/10.
//  Copyright 2010 Widgetbox, Inc. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "Jot.h"

@interface JotParser : NSXMLParser <NSXMLParserDelegate> {
}

@property (retain) NSMutableString *currentProperty;
@property (assign) Jot *currentJot;

- (Jot *) parseJot;

@end

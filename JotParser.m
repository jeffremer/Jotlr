//
//  JotParser.m
//  Jotlr
//
//  Created by Jeff Remer on 7/27/10.
//  Copyright 2010 Widgetbox, Inc. All rights reserved.
//

#import "JotParser.h"

@implementation JotParser

@synthesize currentProperty, 
			currentJot;

#pragma mark Public Methods

- (id) initWithData:(NSData *)data {
	[super initWithData:data];
	[self setDelegate:self];
	[self setShouldProcessNamespaces:NO];
	[self setShouldReportNamespacePrefixes:NO];
	return self;
}

- (Jot *) parseJot {
	[self parse];
	return self.currentJot;
}

#pragma mark -
#pragma mark Parsing Data

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
	if (self.currentProperty) {
        [self.currentProperty appendString:string];
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

@end

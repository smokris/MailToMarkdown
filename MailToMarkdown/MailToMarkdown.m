//
//  MailToMarkdown.m
//  MailToMarkdown
//
//  Created by Steve Mokris on 2/19/16.
//  Copyright © 2016 Steve Mokris. All rights reserved.
//

#import "MailToMarkdown.h"
#import <Cocoa/Cocoa.h>

@implementation MailToMarkdown

- (void)convertSelectionToMarkdown:(NSPasteboard *)pboard userData:(NSString *)userData error:(NSString **)error
{
	int osVersion = NSProcessInfo.processInfo.operatingSystemVersion.minorVersion;

	NSData *d = [pboard dataForType:NSPasteboardTypeRTF];
	NSAttributedString *as = [[NSAttributedString alloc] initWithRTF:d documentAttributes:nil];

	NSArray<NSString *> *hiddenHeaders = @[
		@"Reply-To:",
		@"X-Spam-Status:",
		@"X-Spam-Score:",
	];

	NSUInteger currentIndex = 0;
	NSMutableString *markdownString = [NSMutableString new];
	NSMutableString *debug = [NSMutableString new];
	NSString *currentHeader = nil;
	do
	{
		NSRange p;
		NSColor *c = [as attribute:@"NSColor" atIndex:currentIndex effectiveRange:&p];
		NSColor *csc = [c colorUsingColorSpaceName:NSCalibratedRGBColorSpace];

		char indent = 0;
		if (fabs([csc brightnessComponent] - 0) < 0.1)	// Black
			indent = 0;

		else
		{
			if (osVersion < 13)
			{
				if (fabs([csc hueComponent] - .61) < 0.1)       // Blue
					indent = 0;
				else if (fabs([csc hueComponent] - .34) < 0.1)  // Green
					indent = 1;
				else if (fabs([csc hueComponent] - .99) < 0.1)  // Red
					indent = 2;
			}
			else
			{
				if (fabs([csc hueComponent] - .67) < 0.1)       // Purple
					indent = 0;
				else if (fabs([csc hueComponent] - .53) < 0.1)  // Teal
					indent = 1;
				else if (fabs([csc hueComponent] - .33) < 0.1)  // Green
					indent = 2;
			}
		}

		NSMutableString *indentString = [[NSMutableString alloc] initWithString:@"\n"];
		for (int i = 0; i < indent; ++i)
			[indentString appendString:@"> "];

		NSString *ss = [[[as string] substringWithRange:p] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if ([ss length])
		{
			NSString *indentedString = [ss stringByReplacingOccurrencesOfString:@"\n" withString:indentString];

			bool isHeader = indent == 0 && [ss hasSuffix:@":"];
			[debug appendFormat:@"indent=%d isHeader=%d line=[%@]\n",indent,isHeader,ss];

			if (isHeader)
			{
				if ( ![ss isEqualToString:@"Begin forwarded message:"]
				  && ![hiddenHeaders containsObject:ss] )
				{
					[markdownString appendString:ss];
					[markdownString appendString:@" "];
				}
				currentHeader = ss;
			}
			else if (currentHeader)
			{
				if (![hiddenHeaders containsObject:currentHeader])
				{
					[markdownString appendString:ss];
					[markdownString appendString:@"\n"];
				}
				currentHeader = nil;
			}
			else
			{
				[markdownString appendString:indentString];
				[markdownString appendString:indentedString];
				[markdownString appendString:@"\n"];
			}
		}

		currentIndex += p.length;
	} while (currentIndex < [as length]);

	NSString *outputMarkdownString = [markdownString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	outputMarkdownString = [[@"[email]\n" stringByAppendingString:outputMarkdownString] stringByAppendingString:@"\n[/email]\n"];

//	outputMarkdownString = [outputMarkdownString stringByAppendingString:debug];

	NSPasteboard *outputPBoard = [NSPasteboard generalPasteboard];
	[outputPBoard clearContents];
	[outputPBoard setString:outputMarkdownString forType:NSPasteboardTypeString];

	{
		NSUserNotification *n = [NSUserNotification new];
		n.title = @"Copied selection as Markdown";

		NSUserNotificationCenter *nc = [NSUserNotificationCenter defaultUserNotificationCenter];
		[nc deliverNotification:n];
	}
}

@end

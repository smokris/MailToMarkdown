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
	NSData *d = [pboard dataForType:NSPasteboardTypeRTF];
	NSAttributedString *as = [[NSAttributedString alloc] initWithRTF:d documentAttributes:nil];

	NSUInteger currentIndex = 0;
	NSMutableString *markdownString = [NSMutableString new];
	do
	{
		NSRange p;
		NSColor *c = [as attribute:@"NSColor" atIndex:currentIndex effectiveRange:&p];
		NSColor *csc = [c colorUsingColorSpaceName:NSCalibratedRGBColorSpace];

		char indent = 0;
		if (fabs([csc brightnessComponent] - 0) < 0.1)	// Black
			indent = 0;
		else if (fabs([csc hueComponent] - .61) < 0.1)	// Blue
			indent = 0;
		else if (fabs([csc hueComponent] - .34) < 0.1)	// Green
			indent = 1;
		else if (fabs([csc hueComponent] - .99) < 0.1)	// Red
			indent = 2;

		NSMutableString *indentString = [[NSMutableString alloc] initWithString:@"\n"];
		for (int i = 0; i < indent; ++i)
			[indentString appendString:@"> "];

		NSString *ss = [[[as string] substringWithRange:p] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
		if ([ss length])
		{
			NSString *indentedString = [ss stringByReplacingOccurrencesOfString:@"\n" withString:indentString];

			[markdownString appendString:indentString];
			[markdownString appendString:indentedString];
			[markdownString appendString:@"\n"];
		}

		currentIndex += p.length;
	} while (currentIndex < [as length]);

	[markdownString replaceOccurrencesOfString:@"\nBegin forwarded message:\n" withString:@"" options:0 range:NSMakeRange(0, [markdownString length])];

	NSString *outputMarkdownString = [markdownString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
	outputMarkdownString = [[@"[email]\n" stringByAppendingString:outputMarkdownString] stringByAppendingString:@"\n[/email]\n"];

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

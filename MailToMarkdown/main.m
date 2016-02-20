//
//  main.m
//  MailToMarkdown
//
//  Created by Steve Mokris on 2/19/16.
//  Copyright © 2016 Steve Mokris. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "MailToMarkdown.h"

int main(int argc, const char * argv[]) {
	NSRegisterServicesProvider([MailToMarkdown new], @"MailToMarkdown");
	CFRunLoopRun();
}

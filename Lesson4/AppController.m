//
//  AppController.m
//  Lesson4
//
//  Created by Ilya Lavrenov on 2/23/13.
//  Copyright (c) 2013 Ilya Lavrenov. All rights reserved.
//

#import "AppController.h"

@implementation AppController

- (id)init
{
    self = [super init];
    if (self != nil)
        _parser = [StringEvaluator new];
    return self;
}

- (IBAction)textChanged:(id)sender
{
    [_parser setStringValue:[_stringTextField stringValue]];
    NSNumber* result = [_parser calculateValue];
    
    if (result != nil)
    {
        [_polskaString setStringValue:[_parser polskaString]];
        [_resultTextField setStringValue:[NSString stringWithFormat:@"%lf", [result doubleValue]]];
    }
    [_errorString setStringValue:[_parser errorMessage]];
}

- (void)dealloc
{
    [_parser release];
    [super dealloc];
}

@end

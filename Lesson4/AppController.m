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
    _parser.stringValue = _stringTextField.stringValue;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
        ^(void)
        {
            NSNumber *result = [_parser calculateValue];
            dispatch_async(dispatch_get_main_queue(),
                ^(void)
               {
                    _polskaTextField.stringValue = result == nil ? @"" : _parser.polskaString;
                    _resultTextField.stringValue = result == nil ? @"" : [NSString stringWithFormat:@"%g", [result doubleValue]];
                    _errorTextField.stringValue = _parser.errorMessage;
                });
        });
}

- (void)dealloc
{
    [_parser release];
    [super dealloc];
}

@end

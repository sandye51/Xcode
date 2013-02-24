//
//  AppController.h
//  Lesson4
//
//  Created by Ilya Lavrenov on 2/23/13.
//  Copyright (c) 2013 Ilya Lavrenov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StringEvaluator.h"

@interface AppController : NSObject
{
@private
    IBOutlet NSTextField *_stringTextField;
    IBOutlet NSTextField *_polskaString;
    IBOutlet NSTextField *_errorString;
    IBOutlet NSTextField *_resultTextField;
    StringEvaluator* _parser;
}

- (id)init;

- (void)dealloc;

- (IBAction)textChanged:(id)sender;

@end

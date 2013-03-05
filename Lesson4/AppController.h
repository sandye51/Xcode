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

@property (retain, nonatomic, readonly) StringEvaluator *parser;
@property (assign, nonatomic) IBOutlet NSTextField *resultTextField;
@property (assign, nonatomic) IBOutlet NSTextField *stringTextField;
@property (assign, nonatomic) IBOutlet NSTextField *errorTextField;
@property (assign, nonatomic) IBOutlet NSTextField *polskaTextField;

- (id)init;

- (void)dealloc;

- (IBAction)textChanged:(id)sender;

@end

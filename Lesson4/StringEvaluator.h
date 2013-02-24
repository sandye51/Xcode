//
//  StringEvaluator.h
//  Lesson4
//
//  Created by Ilya Lavrenov on 2/24/13.
//  Copyright (c) 2013 Ilya Lavrenov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StringEvaluator : NSObject
{
@private
    NSString *_errorMessage;
    NSString *_stringValue;
    NSString *_polskaString;
}

@property (retain, readwrite) NSString *stringValue;
@property (assign, readonly) NSString *errorMessage;
@property (assign, readonly) NSString *polskaString;

- (id)init;
- (id)initWithStringValue:(NSString *)stringValue;

- (void)dealloc;

- (NSNumber *)calculateValue;
+ (NSNumber *)calculateValueFromPolska:(NSString *)polskaString;

@end

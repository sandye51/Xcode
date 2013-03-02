//
//  StringEvaluator.h
//  Lesson4
//
//  Created by Ilya Lavrenov on 2/24/13.
//  Copyright (c) 2013 Ilya Lavrenov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StringEvaluator : NSObject

@property (nonatomic, retain) NSString *stringValue;
@property (nonatomic, readonly, retain) NSString *errorMessage;
@property (nonatomic, readonly, retain) NSString *polskaString;

- (id)init;
- (id)initWithStringValue:(NSString *)stringValue;

- (void)dealloc;

- (NSNumber *)calculateValue;
+ (NSNumber *)calculateValueFromPolska:(NSString *)polskaString;

@end

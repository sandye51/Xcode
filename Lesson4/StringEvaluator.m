//
//  StringEvaluator.m
//  Lesson4
//
//  Created by Ilya Lavrenov on 2/24/13.
//  Copyright (c) 2013 Ilya Lavrenov. All rights reserved.
//

#import "StringEvaluator.h"

@interface StringEvaluator ()
{
@private
    NSMutableString *_workingCopy;
}

@property (nonatomic, readwrite, retain) NSString *errorMessage;
@property (nonatomic, readwrite, retain) NSString *polskaString;

- (void)preprocessing;
- (NSNumber *)extractOperand;
- (NSString *)createResultString;

+ (unsigned char)operationPriority:(unichar)symbol;
+ (BOOL)isOperand:(NSString *)stringOperand;

@end

@implementation StringEvaluator

- (id)init
{
    return [self initWithStringValue:nil];
}

- (id)initWithStringValue:(NSString *)newStringValue
{
    self = [super init];
    if (self != nil)
    {
        _workingCopy = [NSMutableString new];
        self.stringValue = newStringValue;
    }
    return self;
}

+ (unsigned char)operationPriority:(unichar)symbol
{
    if (symbol == '*' || symbol == '/')
        return 3;
    if (symbol == '+' || symbol == '-')
        return 2;
    if (symbol == ')' || symbol == '(')
        return 1;
    return 0;
}

- (NSNumber *)extractOperand
{
    NSUInteger index = 0, length = [_workingCopy length], dotCount = 0;
    NSCharacterSet *digits = [NSCharacterSet decimalDigitCharacterSet];
    
    while (index < length && ([digits characterIsMember:[_workingCopy characterAtIndex:index]]
        || [_workingCopy characterAtIndex:index] == '.'))
    {
        if ([_workingCopy characterAtIndex:index] == '.')
            ++dotCount;
        ++index;
    }
        
    // if there is no operands
    if (index == 0)
        return [NSNumber numberWithInt:-1];

    NSString *stringOperand = [_workingCopy substringToIndex:index];
    NSNumber *returnValue = nil;
    @try
    {
        if (dotCount > 1)
            [NSException raise:@"Неправильный аргумент" format:@"Некорректный аргумент %@", stringOperand];
        
        returnValue = [NSNumber numberWithDouble:[stringOperand doubleValue]];
        [_workingCopy deleteCharactersInRange:NSMakeRange(0, index)];
    }
    @catch (NSException* ex)
    {
        returnValue = [NSNumber numberWithInt:-2];
        self.errorMessage = [ex reason];
    }
    
    return returnValue;
}

- (void)preprocessing
{
    [_workingCopy stringByReplacingOccurrencesOfString:@" " withString:@"" options:NSAnchoredSearch range:NSMakeRange(0, [_workingCopy length])];
    [_workingCopy stringByReplacingOccurrencesOfString:@"(-" withString:@"(0-" options:NSAnchoredSearch range:NSMakeRange(0, [_workingCopy length])];
    [_workingCopy stringByReplacingOccurrencesOfString:@"++" withString:@"+" options:NSAnchoredSearch range:NSMakeRange(0, [_workingCopy length])];
    [_workingCopy stringByReplacingOccurrencesOfString:@"--" withString:@"+" options:NSAnchoredSearch range:NSMakeRange(0, [_workingCopy length])];
    [_workingCopy stringByReplacingOccurrencesOfString:@"+-" withString:@"-" options:NSAnchoredSearch range:NSMakeRange(0, [_workingCopy length])];
    [_workingCopy stringByReplacingOccurrencesOfString:@"-+" withString:@"-" options:NSAnchoredSearch range:NSMakeRange(0, [_workingCopy length])];
    if ([_workingCopy characterAtIndex:0] == '-')
        [_workingCopy setString:[NSString stringWithFormat:@"0%@", _workingCopy]];
}

- (NSString *)createResultString
{
    NSMutableString *resultString = [NSMutableString stringWithString:@""];
    
    @autoreleasepool
    {
        NSMutableArray *stack = [[NSMutableArray new] autorelease];
        NSUInteger operandCounter = 0, operationCounter = 0;
        unichar peek;
        
        while ([_workingCopy length] > 0)
        {
            // try to extract operand
            NSNumber* operand = [self extractOperand];
            double value = [operand doubleValue];
            if (value < 0)
            {
                if (value == -2.0)
                    return nil;
            }
            else
            {
                [resultString appendFormat:@" %g", value];
                ++operandCounter;
                continue;
            }
            
            // try to extract operation
            unichar symbol = [_workingCopy characterAtIndex:0];
            [_workingCopy deleteCharactersInRange:NSMakeRange(0, 1)];
            unsigned char priority = [StringEvaluator operationPriority:symbol];
            
            // if operation
            if (priority >= 2)
            {
                ++operationCounter;
                [[stack lastObject] getValue:&peek];
                
                if ([stack count] == 0 || [StringEvaluator operationPriority:peek] < priority)
                {
                    [stack addObject:[NSValue value:&symbol withObjCType:@encode(unichar)]];
                    continue;
                }
                
                while ([stack count] > 0 && [StringEvaluator operationPriority:peek] >= priority)
                {
                    [resultString appendFormat:@" %c", peek];
                    [stack removeLastObject];
                    [[stack lastObject] getValue:&peek];
                }
                [stack addObject:[NSValue value:&symbol withObjCType:@encode(unichar)]];
            }
            // if brackets
            else if (priority == 1)
            {
                if (symbol == '(')
                    [stack addObject:[NSValue value:&symbol withObjCType:@encode(unichar)]];
                else
                {
                    [[stack lastObject] getValue:&peek];
                    while ([stack count] > 0 && peek != '(')
                    {
                        [resultString appendFormat:@" %c", peek];
                        [stack removeLastObject];
                        [[stack lastObject] getValue:&peek];
                    }
                    
                    if ([stack count] == 0)
                    {
                        self.errorMessage = @"Не хватает открывающейся скобки";
                        return nil;
                    }
                    
                    if (peek != '(')
                    {
                        self.errorMessage = @"Ошибка при расстановке скобок";
                        return nil;
                    }
                    
                    [stack removeLastObject];
                }
            }
            else
            {
                self.errorMessage = [NSString stringWithFormat:@"Неопознанный символ %c", symbol];
                return nil;
            }
        }
        
        if (operationCounter + 1 != operandCounter)
        {
            self.errorMessage = @"Несоответствие операторов";
            return nil;
        }
        
        // pop from stack to result string
        while ([stack count] > 0)
        {
            [[stack lastObject] getValue:&peek];
            if (peek == '(')
            {
                self.errorMessage = @"Не хватает закрывающейся скобки";
                return nil;
            }
            [resultString appendFormat:@" %c", peek];
            [stack removeLastObject];
        }
    }

    [resultString deleteCharactersInRange:NSMakeRange(0, 1)];
    return resultString;
}

- (NSNumber *)calculateValue
{
    if ([_stringValue length] == 0)
    {
        self.errorMessage = @"Строка пустая";
        self.polskaString = nil;
        return nil;
    }
    
    [_workingCopy setString:_stringValue];
    
    [self preprocessing];
    self.polskaString = [self createResultString];
    
    if (_polskaString == nil)
        return nil;
    
    self.errorMessage = @"Строка удачно разобрана";
    return [StringEvaluator calculateValueFromPolska:_polskaString];
}

+ (BOOL)isOperand:(NSString *)stringOperand
{
    NSCharacterSet *numbers = [NSCharacterSet decimalDigitCharacterSet];
    BOOL resultValue = YES;
    
    for (NSUInteger i = 0, end = [stringOperand length]; i < end; ++i)
    {
        unichar symbol = [stringOperand characterAtIndex:i];
        if (([numbers characterIsMember:symbol] || symbol == '.') == NO)
        {
            resultValue = NO;
            break;
        }
    }
    
    return resultValue;
}

+ (NSNumber *)calculateValueFromPolska:(NSString *)polskaString
{
    NSNumber *result = nil;
    NSMutableArray *numberStack = [NSMutableArray new];
    NSArray *terms = [polskaString componentsSeparatedByString:@" "];
    
    for (NSUInteger i = 0, end = [terms count]; i < end; ++i)
    {
        NSString *currentTerm = [terms objectAtIndex:i];
        if ([currentTerm length] == 0)
            continue;

        BOOL isOperand = [StringEvaluator isOperand:currentTerm];
        if (isOperand == YES)
            [numberStack addObject:[NSNumber numberWithDouble:[currentTerm doubleValue]]];
        else
        {
            unichar operation = [currentTerm characterAtIndex:0];
            NSNumber *firstOperand = [numberStack lastObject];
            [numberStack removeLastObject];
            NSNumber *secondOperand = [numberStack lastObject];
            [numberStack removeLastObject];
            
            if (operation == '*')
                result = [NSNumber numberWithDouble:[firstOperand doubleValue] * [secondOperand doubleValue]];
            else if (operation == '/')
                result = [NSNumber numberWithDouble:[secondOperand doubleValue] / [firstOperand doubleValue]];
            else if (operation == '+')
                result = [NSNumber numberWithDouble:[firstOperand doubleValue] + [secondOperand doubleValue]];
            else if (operation == '-')
                result = [NSNumber numberWithDouble:[secondOperand doubleValue] - [firstOperand doubleValue]];
            
            [numberStack addObject:result];
        }
    }
    
    NSUInteger count = [numberStack count];
    result = [numberStack lastObject];
    [numberStack release];
    
    if (count != 1)
        return nil;

    return result;
}

- (void)dealloc
{
    [_errorMessage release];
    [_stringValue release];
    [_polskaString release];
    [_workingCopy release];
    
    [super dealloc];
}

@end

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
    NSString *_workingCopy;
}

- (void)preprocessing;
+ (short unsigned int)operationPriority:(unichar)symbol;
- (NSNumber *)extractOperand;
- (NSString *)createResultString;
+ (BOOL)isOperand:(NSString *)stringOperand;

@end

@implementation StringEvaluator

@synthesize stringValue = _stringValue;
@synthesize errorMessage = _errorMessage;
@synthesize polskaString = _polskaString;

- (id)init
{
    return [self initWithStringValue:@""];
}

- (id)initWithStringValue:(NSString *)newStringValue
{
    self = [super init];
    if (self != nil)
    {
        _stringValue = [newStringValue retain];
        _workingCopy = nil;
        _errorMessage = @"";
        _polskaString = nil;
    }
    return self;
}

+ (short unsigned int)operationPriority:(unichar)symbol
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
    NSUInteger index = 0, length = [_workingCopy length];
    NSCharacterSet *digits = [NSCharacterSet decimalDigitCharacterSet];
    
    while (index < length && ([digits characterIsMember:[_workingCopy characterAtIndex:index]]
        || [_workingCopy characterAtIndex:index] == '.'))
        ++index;
    
    // if there is no operands
    if (index == 0)
        return [NSNumber numberWithInt:-1];

    NSString *stringOperand = [_workingCopy substringToIndex:index];
    NSNumber *returnValue = nil;
    @try
    {
        returnValue = [NSNumber numberWithDouble:[stringOperand doubleValue]];
        _workingCopy = [_workingCopy substringFromIndex:index];
    }
    @catch (...)
    {
        returnValue = [NSNumber numberWithInt:-2];
        _errorMessage = @"Неправильно задан операнд";
    }
    
    return returnValue;
}

- (void)preprocessing
{
    _workingCopy = [_workingCopy stringByReplacingOccurrencesOfString:@" " withString:@""];
    _workingCopy = [_workingCopy stringByReplacingOccurrencesOfString:@"(-" withString:@"(0-"];
    _workingCopy = [_workingCopy stringByReplacingOccurrencesOfString:@"++" withString:@"+"];
    _workingCopy = [_workingCopy stringByReplacingOccurrencesOfString:@"--" withString:@"+"];
    _workingCopy = [_workingCopy stringByReplacingOccurrencesOfString:@"+-" withString:@"-"];
    _workingCopy = [_workingCopy stringByReplacingOccurrencesOfString:@"-+" withString:@"-"];
    if ([_workingCopy characterAtIndex:0] == '-')
        _workingCopy = [NSString stringWithFormat:@"0%@", _workingCopy];
}

- (NSString *)createResultString
{
    NSString *resultString = @"";
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
            resultString = [resultString stringByAppendingFormat:@" %lf", value];
            ++operandCounter;
            continue;
        }
        
        // try to extract operation
        unichar symbol = [_workingCopy characterAtIndex:0];
        _workingCopy = [_workingCopy substringFromIndex:1];
        unsigned short int priority = [StringEvaluator operationPriority:symbol];
        
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
                resultString = [resultString stringByAppendingFormat:@" %c", peek];
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
                    resultString = [resultString stringByAppendingFormat:@" %c", peek];
                    [stack removeLastObject];
                    [[stack lastObject] getValue:&peek];
                }
                
                if ([stack count] == 0)
                {
                    _errorMessage = @"Не хватает открывающейся скобки";
                    return nil;
                }
                
                if (peek != '(')
                {
                    _errorMessage = @"Ошибка при расстановке скобок";
                    return nil;
                }
                
                [stack removeLastObject];
            }
        }
        else
        {
            _errorMessage = [NSString stringWithFormat:@"Неопознанный символ %c", symbol];
            return nil;
        }
    }
    
    if (operationCounter + 1 != operandCounter)
    {
        _errorMessage = @"Несоответствие операторов";
        return  nil;
    }
    
    // pop from stack to result string
    while ([stack count] > 0)
    {
        [[stack lastObject] getValue:&peek];
        if (peek == '(')
        {
            _errorMessage = @"Не хватает закрывающейся скобки";
            return nil;
        }
        resultString = [resultString stringByAppendingFormat:@" %c", peek];
        [stack removeLastObject];
    }
    
    return resultString;
}

- (NSNumber *)calculateValue
{
    _workingCopy = [_stringValue copy];
    
    [self preprocessing];
    _polskaString = [self createResultString];
    if (_polskaString == nil)
        return nil;
    
    _errorMessage = @"Строка удачно разобрана";
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
    NSMutableArray *numberStack = [[NSMutableArray new] autorelease];
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
                result = [NSNumber numberWithDouble:[firstOperand doubleValue] / [secondOperand doubleValue]];
            else if (operation == '+')
                result = [NSNumber numberWithDouble:[firstOperand doubleValue] + [secondOperand doubleValue]];
            else if (operation == '-')
                result = [NSNumber numberWithDouble:[firstOperand doubleValue] - [secondOperand doubleValue]];
            
            [numberStack addObject:result];
        }
    }
    
    if ([numberStack count] != 1)
        return nil;
    
    return result;
}

- (void)dealloc
{
    [_stringValue release];
    [super dealloc];
}

@end

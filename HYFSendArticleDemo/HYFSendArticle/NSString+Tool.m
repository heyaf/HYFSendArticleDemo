//
//  NSString+Tool.m
//  HYFSendArticleDemo
//
//  Created by iOS on 2020/8/17.
//  Copyright © 2020 heyafei. All rights reserved.
//

#import "NSString+Tool.h"

@implementation NSString (Tool)
//判断字符串是否为纯空格
+ (BOOL)isEmpty:(NSString *) str {
     
    if (!str) {
        return true;
    } else {
        //A character set containing only the whitespace characters space (U+0020) and tab (U+0009) and the newline and nextline characters (U+000A–U+000D, U+0085).
        NSCharacterSet *set = [NSCharacterSet whitespaceAndNewlineCharacterSet];
         
        //Returns a new string made by removing from both ends of the receiver characters contained in a given character set.
        NSString *trimedString = [str stringByTrimmingCharactersInSet:set];
         
        if ([trimedString length] == 0) {
            return true;
        } else {
            return false;
        }
    }
}
@end

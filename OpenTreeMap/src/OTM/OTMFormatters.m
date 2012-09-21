//                                                                                                                
// Copyright (c) 2012 Azavea                                                                                
//                                                                                                                
// Permission is hereby granted, free of charge, to any person obtaining a copy                                   
// of this software and associated documentation files (the "Software"), to                                       
// deal in the Software without restriction, including without limitation the                                     
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or                                    
//  sell copies of the Software, and to permit persons to whom the Software is                                    
// furnished to do so, subject to the following conditions:                                                       
//                                                                                                                
// The above copyright notice and this permission notice shall be included in                                     
// all copies or substantial portions of the Software.                                                            
//                                                                                                                
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR                                     
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,                                       
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE                                    
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER                                         
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,                                  
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN                                      
// THE SOFTWARE.                                                                                                  
//  

#import "OTMFormatters.h"

@implementation OTMFormatters

+(NSString*)fmtIn:(NSNumber*)number 
{
    return [NSString stringWithFormat:@"%0.2f in",[number floatValue]];
}

+(NSString*)fmtFt:(NSNumber*)number 
{
    return [NSString stringWithFormat:@"%0.2f ft",[number floatValue]];
}

+(NSString*)fmtM:(NSNumber*)number 
{
    return [NSString stringWithFormat:@"%0.2f m",[number floatValue]];
}

+(NSString*)fmtUnitDict:(NSDictionary*)d 
{
    id unit = [d objectForKey:@"unit"];
    if (nil == unit) {
        unit = @"";
    }

    return [NSString stringWithFormat:@"%0.1f %@", [[d valueForKey:@"value"] floatValue], unit];
}

+(NSString*)fmtDollarsDict:(NSDictionary*)d
{
    return [NSString stringWithFormat:@"$%0.2f", [[d valueForKey:@"dollars"] floatValue]];
}

+(NSString*)fmtOtmApiDateString:(NSString*)dateString
{
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];

    NSDateFormatter *isoFormatter = [[NSDateFormatter alloc] init];
    [isoFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [isoFormatter setCalendar:cal];
    [isoFormatter setLocale:[NSLocale currentLocale]];

    NSDate *date = [isoFormatter dateFromString:dateString];

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMMM d, yyyy 'at' h:MM aaa"];
    [formatter setCalendar:cal];
    [formatter setLocale:[NSLocale currentLocale]];
    return [formatter stringFromDate:date];
}

+(NSString*)fmtObject:(id)obj withKey:(NSString*)key {
    if (obj == nil || [[obj description] isEqualToString:@"<null>"]) {
        return @"";
    } else if (key == nil || [key length] == 0) {
        return [obj description];
    } else {
        return [OTMFormatters performSelector:NSSelectorFromString(key) withObject:obj];
    }
}

@end
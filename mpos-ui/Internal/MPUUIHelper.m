/*
 * mpos-ui : http://www.payworksmobile.com
 *
 * The MIT License (MIT)
 *
 * Copyright (c) 2015 payworks GmbH
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import "MPUUIHelper.h"
#import "MPUMposUi_Internal.h"
#import "MPUTransactionParameters.h"
#import <CoreText/CoreText.h>

@implementation MPUUIHelper

+ (NSBundle*)frameworkBundle {
    return  [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"mpos-ui-resources" withExtension:@"bundle"]];
}

+ (void) loadMyCustomFont{
    // register the font:
    NSURL *url = [[MPUUIHelper frameworkBundle] URLForResource:@"FontAwesome" withExtension:@"otf"];
    NSData *fontData = [NSData dataWithContentsOfURL:url];
    if (fontData) {
        CFErrorRef error;
        CGDataProviderRef provider = CGDataProviderCreateWithCFData((CFDataRef)fontData);
        CGFontRef font = CGFontCreateWithDataProvider(provider);
        if (! CTFontManagerRegisterGraphicsFont(font, &error)) {
            CFStringRef errorDescription = CFErrorCopyDescription(error);
            DDLogError(@"Failed to load font: %@", errorDescription);
            CFRelease(errorDescription);
        }
        CFRelease(font);
        CFRelease(provider);
    }
}

+ (BOOL)isStringEmpty:(NSString *)string {
    if ([string length] == 0) {
        return YES;
    }

    return ![[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length];
}

+ (NSString *)defaultControllerTitleBasedOnParameters:(MPUTransactionParameters *)parameters toolbox:(MPLocalizationToolbox *)toolbox {
    
    NSString *titlePrefix;
    if (parameters.transactionIdentifier != nil){
        titlePrefix = [MPUUIHelper localizedString:@"MPURefund"];
    }
    else {
         titlePrefix = [MPUUIHelper localizedString:@"MPUSale"];
    }
    
    NSString *title;
    if (parameters.amount){
        NSString *titleAmount = [toolbox textFormattedForAmount:parameters.amount currency:parameters.currency];
        title = [NSString stringWithFormat:@"%@: %@", titlePrefix, titleAmount];
    }
    else {
        title = [NSString stringWithFormat:@"%@", titlePrefix];
    }
    
    return title;
}

// Assumes input like "#00FF00" (#RRGGBB).
+ (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+ (NSString *)localizedString:(NSString *)token {
    if (!token) return @"";
    
    //here we check for three different occurances where it can be found
    
    //first up is the app localization
    NSString *appSpecificLocalizationString = NSLocalizedString(token, @"");
    if (![token isEqualToString:appSpecificLocalizationString])
    {
        return appSpecificLocalizationString;
    }
    
    //second is the app localization with specific table
    NSString *appSpecificLocalizationStringFromTable = NSLocalizedStringFromTable(token, @"mpos-ui", @"");
    if (![token isEqualToString:appSpecificLocalizationStringFromTable])
    {
        return appSpecificLocalizationStringFromTable;
    }
    
    //third time is the charm, looking in our resource bundle
    if ([self frameworkBundle])
    {
        NSString *bundleSpecificLocalizationString = NSLocalizedStringFromTableInBundle(token, @"mpos-ui", [self frameworkBundle], @"");
        if (![token isEqualToString:bundleSpecificLocalizationString])
        {
            return bundleSpecificLocalizationString;
        }
    }
    
    //and as a fallback, we just return the token itself
    DDLogError(@"could not find any localization files. please check that you added the resource bundle and/or your own localizations");
    return token;
}



@end
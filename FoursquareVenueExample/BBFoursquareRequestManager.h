//
//  BBFoursquareRequestManager.h
//  FoursquareVenueExample
//
//  Created by Cameron Hendrix on 8/8/13.
//  Copyright (c) 2013 BurningBarnLabs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface BBFoursquareRequestManager : NSObject

- (void) updateSuggestionsWithQuery:(NSString*)queryString nearLocation:(CLLocation*)location withTarget:(id)target successHandler:(SEL)handleSuccess errorHandler:(SEL)handleError;

- (NSInteger) venueSuggestionCountForQuery:(NSString*)queryString;
- (NSString*) venueSuggestionField:(NSString*)field atIndex:(int)index;

@end

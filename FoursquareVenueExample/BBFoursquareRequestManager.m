//
//  BBFoursquareRequestManager.m
//  FoursquareVenueExample
//
//  Created by Cameron Hendrix on 8/8/13.
//  Copyright (c) 2013 BurningBarnLabs. All rights reserved.
//

#import "BBFoursquareRequestManager.h"

NSString *const kFoursquareClientId     = @"YOUR CLIENT ID";
NSString *const kFoursquareClientSecret = @"YOUR CLIENT SECRET";

@interface BBFoursquareRequestManager()

@property (strong, nonatomic) NSArray *suggestions;
@property (strong, nonatomic) NSArray *locallyFilteredSuggestions;

@property (nonatomic) BOOL isRequestInProcess;
@property (strong, nonatomic) NSString *queuedRequestURL;

+ (NSString*) baseURL;
+ (NSString*) userlessAuth;
+ (NSString*) suggestCompletionURLWithQuery:(NSString*)queryString nearLocation:(CLLocation*)location;
+ (NSString*) venueURLWithId:(NSString*)venueId;

- (NSIndexSet*) indexSetForVenuesMatchingQuery:(NSString*)queryString;

@end

@implementation BBFoursquareRequestManager

@synthesize suggestions, locallyFilteredSuggestions, isRequestInProcess, queuedRequestURL;

+ (NSString*) baseURL
{
    return @"https://api.foursquare.com/v2/";
}

+ (NSString*) userlessAuth
{
    return [NSString stringWithFormat:@"client_id=%@&client_secret=%@&v=20130808", kFoursquareClientId, kFoursquareClientSecret];
}

+ (NSString*) suggestCompletionURLWithQuery:(NSString*)queryString nearLocation:(CLLocation*)location
{
    return [NSString stringWithFormat:@"%@venues/suggestcompletion?query=%@&ll=%f,%f&%@", [self baseURL], queryString, location.coordinate.latitude, location.coordinate.longitude, [self userlessAuth]];
}

+ (NSString*) venueURLWithId:(NSString*)venueId
{
    return [NSString stringWithFormat:@"%@venues/%@&%@", [self baseURL], venueId, [self userlessAuth]];
}

- (void) updateSuggestionsWithQuery:(NSString*)queryString nearLocation:(CLLocation*)location withTarget:(id)target successHandler:(SEL)handleSuccess errorHandler:(SEL)handleError
{
    // Minimum length for Foursquare suggestcompletion query is 3 chars
    if (queryString.length < 3) {
        self.suggestions = nil;
        if (target && handleSuccess) [target performSelector:handleSuccess];
        return;
    }
    
    if (self.isRequestInProcess) {
        // Queue the most recent query URL
        self.queuedRequestURL = [[self class] suggestCompletionURLWithQuery:queryString nearLocation:location];
        return;
    }
    
    void (^__block process)(NSURLResponse*, NSData*, NSError*) = ^(NSURLResponse *response, NSData *data, NSError *error){
        NSLog(@"Processing response");
        self.isRequestInProcess = NO;
        if ([data length] >0 && error == nil) {
            
            if (self.queuedRequestURL) {
                NSMutableURLRequest *newRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.queuedRequestURL] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
                self.queuedRequestURL = nil;
                [NSURLConnection sendAsynchronousRequest:newRequest queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                    process(response, data, error);
                }];
            }
                        
            NSError *error = nil;
            id results = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            if (!error) {
                id response = [results objectForKey:@"response"];
                if (response && [response objectForKey:@"minivenues"]) {
                    self.suggestions = [NSArray arrayWithArray:[response objectForKey:@"minivenues"]];
                }
                if (target && handleSuccess) [target performSelector:handleSuccess];
            }
        } else {
            if (target && handleError) [target performSelector:handleError withObject:error];
        }
    };

    
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[[self class] suggestCompletionURLWithQuery:queryString nearLocation:location]] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:4.0f];
    
    self.isRequestInProcess = YES;
    NSLog(@"Sending new request");
    [NSURLConnection sendAsynchronousRequest:urlRequest queue:[[NSOperationQueue alloc] init] completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
        process(response, data, error);
    }];
}

#pragma mark - Venues

- (NSInteger) venueSuggestionCountForQuery:(NSString*)queryString
{
    if (!self.suggestions) return 0;
    else {
        self.locallyFilteredSuggestions = [self.suggestions objectsAtIndexes:[self indexSetForVenuesMatchingQuery:queryString]];        
        return self.locallyFilteredSuggestions.count;
    }
}

- (NSString*) venueSuggestionField:(NSString*)field atIndex:(int)index
{
    NSDictionary *venue = [self.locallyFilteredSuggestions objectAtIndex:index];
    if ([venue objectForKey:field]) return [venue objectForKey:field];
    else if ([venue objectForKey:@"location"] && [[venue objectForKey:@"location"] objectForKey:field]) return [[venue objectForKey:@"location"] objectForKey:field];
    else return nil;
}

- (NSIndexSet*) indexSetForVenuesMatchingQuery:(NSString*)queryString
{
    if (!self.suggestions) return [NSIndexSet indexSet];
    return [self.suggestions indexesOfObjectsPassingTest:^BOOL(NSDictionary *venue, NSUInteger idx, BOOL *stop) {
        NSString *name = [venue objectForKey:@"name"];
        NSString *address = [[venue objectForKey:@"location"] objectForKey:@"address"];
        return ([name rangeOfString:queryString options:NSCaseInsensitiveSearch].location != NSNotFound || [address rangeOfString:queryString options:NSCaseInsensitiveSearch].location != NSNotFound);
    }];
}

@end
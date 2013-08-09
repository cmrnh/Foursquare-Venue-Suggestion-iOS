//
//  ViewController.m
//  FoursquareVenueExample
//
//  Created by Cameron Hendrix on 8/8/13.
//  Copyright (c) 2013 BurningBarnLabs. All rights reserved.
//

// Auto-Suggestion
//
// 1) Load with first set of 3-letters
// 2) Then update results for more complete string, if any
// 3) Then filter

#import "ViewController.h"

#import "BBFoursquareRequestManager.h"

@interface ViewController ()

@end

@implementation ViewController

@synthesize tableView, textField;
@synthesize foursquareManager;

- (void) viewDidLoad
{
    [self.tableView setDelegate:self];
    [self.tableView setDataSource:self];
    
    [self.textField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

#pragma mark - Search Handler

- (void) textFieldDidChange:(UITextField*)sender
{
    if (!self.foursquareManager) self.foursquareManager = [[BBFoursquareRequestManager alloc] init];
    
    NSLog(@"New Text = %@",sender.text);
    
    [self handleVenueSuggestions];
    
    [self.foursquareManager updateSuggestionsWithQuery:sender.text nearLocation:[[CLLocation alloc] initWithLatitude:40.711082f longitude: -74.008553f] withTarget:self successHandler:@selector(handleVenueSuggestions) errorHandler:nil];
}

- (void) handleVenueSuggestions
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

#pragma mark - <UITableViewDelegate>

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.f;
}

- (CGFloat) tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 0.f;
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.foursquareManager venueSuggestionCountForQuery:self.textField.text];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellId"];    
    [cell.textLabel setText:[self.foursquareManager venueSuggestionField:@"name" atIndex:indexPath.row]];
    [cell.detailTextLabel setText:[self.foursquareManager venueSuggestionField:@"address" atIndex:indexPath.row]];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}

@end

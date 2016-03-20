//
//  OvOFontDisplayTableVC.m
//  SystemFontDisplay
//
//  Created by Wang Hans on 1/13/15.
//  Copyright (c) 2015 Wang Hans. All rights reserved.
//

#import "OvOFontDisplayTableVC.h"

@interface OvOFontFamily : NSObject
@property (nonatomic, strong) NSArray * fontNames;
@property (nonatomic, strong) NSString * name;
@end

@implementation OvOFontFamily
@end

@interface OvOFontDisplayTableVC ()<UISearchBarDelegate,UISearchResultsUpdating>
// system-supported fonts info
@property NSArray * systemFontFamiliesArray;
// array for display
@property NSArray * displayArray;
// search
@property UISearchController * searchController;
@end

@implementation OvOFontDisplayTableVC

#pragma mark - view lifecycle

- (void)awakeFromNib
{
    NSInteger totalCount = 0;
    NSMutableArray* systemFontFamiliesArray = [NSMutableArray new];
    for (NSString * name in [UIFont familyNames])
    {
        OvOFontFamily * family = [OvOFontFamily new];
        family.name = name;
        family.fontNames = [UIFont fontNamesForFamilyName:name];
    
        [systemFontFamiliesArray addObject: family];
        
        totalCount += family.fontNames.count;
    }
    
    [self sortFamilysMyName:systemFontFamiliesArray];
    self.systemFontFamiliesArray = systemFontFamiliesArray;
    
    self.displayArray = [self.systemFontFamiliesArray copy];
    
    self.title = [NSString stringWithFormat:@"System Supported Fonts (%@)",@(totalCount)];
    
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    self.tableView.tableHeaderView = self.searchController.searchBar;
    
    self.definesPresentationContext = YES;
    
    // Hide the search bar until user scrolls up
    CGRect newBounds = [[self tableView] bounds];
    newBounds.origin.y = newBounds.origin.y + self.searchController.searchBar.bounds.size.height;
    [[self tableView] setBounds:newBounds];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    OvOFontFamily * family = self.displayArray[section];
    return family.fontNames.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.displayArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    OvOFontFamily * family = self.displayArray[section];
    return [NSString stringWithFormat:@"%@ (%ld)",family.name,(long)family.fontNames.count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"fontCell" forIndexPath:indexPath];
    
    OvOFontFamily * family = self.displayArray[indexPath.section];

    NSString * fontName = family.fontNames[indexPath.row];
    
    cell.textLabel.font = [UIFont fontWithName:fontName size:20];
    
    NSString * searchStr = self.searchController.searchBar.text;
    if (searchStr.length>0)
    {
        NSMutableAttributedString * AttrText = [[NSMutableAttributedString alloc] initWithString:fontName];
        NSRange range = [fontName rangeOfString:searchStr];
        [AttrText addAttribute:NSBackgroundColorAttributeName value:[UIColor yellowColor] range:range];
        cell.textLabel.attributedText = AttrText;
    }
    else
        cell.textLabel.text = fontName;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UISearchResultsUpdating

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    [self searchForText:searchString];
    [self.tableView reloadData];
}

#pragma mark - helper
- (void)searchForText:(NSString*)searchText
{
    if (searchText.length>0 || self.searchController.active)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.name contains[c] %@",searchText];
        NSMutableArray * matchedFamilys = [[self.systemFontFamiliesArray filteredArrayUsingPredicate:predicate] mutableCopy];
        
        NSMutableArray * restFamilys = [NSMutableArray arrayWithArray:self.systemFontFamiliesArray];
        [restFamilys removeObjectsInArray:matchedFamilys];
        
        NSMutableArray * matchedFontNames = [NSMutableArray new];
        for (OvOFontFamily* family in restFamilys)
        {
            for (NSString* fontName in family.fontNames)
            {
                if ([fontName containsString:searchText])
                    [matchedFontNames addObject:fontName];
            }
            if (matchedFontNames.count>0)
            {
                OvOFontFamily * matchedFamily = [OvOFontFamily new];
                matchedFamily.name = family.name;
                matchedFamily.fontNames = [NSArray arrayWithArray:matchedFontNames];
                [matchedFamilys addObject:matchedFamily];
            }
            [matchedFontNames removeAllObjects];
        }
        
        [self sortFamilysMyName:matchedFamilys];

        self.displayArray = matchedFamilys;
    }
    else
        self.displayArray = self.systemFontFamiliesArray;
}

- (void)sortFamilysMyName:(NSMutableArray*)mutableArray
{
    [mutableArray sortUsingComparator:^NSComparisonResult(OvOFontFamily * family1, OvOFontFamily * family2) {
        return [family1.name compare:family2.name options:NSCaseInsensitiveSearch];
    }];
}

@end

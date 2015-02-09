//
//  OvOFontDisplayTableVC.m
//  SystemFontDisplay
//
//  Created by Wang Hans on 1/13/15.
//  Copyright (c) 2015 Wang Hans. All rights reserved.
//

#import "OvOFontDisplayTableVC.h"

@interface OvOFontFamily : NSObject
@property (nonatomic, strong) NSArray * fonts;
@property (nonatomic, strong) NSString * name;
@end

@implementation OvOFontFamily
@end

@interface OvOFontDisplayTableVC ()
// system-supported fonts info
@property NSMutableArray * systemFontFamiliesArray;
// array for display
@property NSMutableArray * displayArray;
@end

@implementation OvOFontDisplayTableVC

#pragma mark - view lifecycle

- (void)awakeFromNib
{
    NSUInteger * totalCount = 0;
    self.systemFontFamiliesArray = [NSMutableArray new];
    
    for (NSString * name in [UIFont familyNames])
    {
        OvOFontFamily * family = [OvOFontFamily new];
        family.name = name;
        family.fonts = [UIFont fontNamesForFamilyName:name];
    
        [self.systemFontFamiliesArray addObject: family];
        
        totalCount += family.fonts.count;
    }
    
    self.displayArray = [self.systemFontFamiliesArray copy];
    
    self.title = [NSString stringWithFormat:@"System Supported Fonts (%ld)",(long)totalCount];
    
    // Hide the search bar until user scrolls up
    CGRect newBounds = [[self tableView] bounds];
    newBounds.origin.y = newBounds.origin.y + self.searchBar.bounds.size.height;
    [[self tableView] setBounds:newBounds];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    OvOFontFamily * family = self.displayArray[section];
    return family.fonts.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.displayArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    OvOFontFamily * family = self.displayArray[section];
    return [NSString stringWithFormat:@"%@ (%ld)",family.name,(long)family.fonts.count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"fontCell" forIndexPath:indexPath];
    
    OvOFontFamily * family = self.displayArray[indexPath.section];

    NSString * fontName = family.fonts[indexPath.row];
    
    cell.textLabel.font = [UIFont fontWithName:fontName size:20];
    cell.textLabel.text = fontName;
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - helper method
- (void)filteredArray:(NSString*)searchStr
{
//    self.filteredFonts = nil;
//    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF contains[cd] %@",searchStr];
//    self.filteredFonts = [self.allFonts filteredArrayUsingPredicate:predicate];
}

@end

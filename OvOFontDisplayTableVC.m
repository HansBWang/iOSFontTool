//
//  OvOFontDisplayTableVC.m
//  SystemFontDisplay
//
//  Created by Wang Hans on 1/13/15.
//  Copyright (c) 2015 Wang Hans. All rights reserved.
//

#import "OvOFontDisplayTableVC.h"

@interface OvOFontDisplayTableVC ()

// system-supported fonts info
@property NSMutableArray * systemFontFamiliesArray;
@property NSMutableArray * systemFontNamesArray;
@property NSMutableArray * allFonts;

// search result
@property NSArray * filteredFonts;

@end

@implementation OvOFontDisplayTableVC

#pragma mark - view lifecycle

- (void)awakeFromNib
{
    self.systemFontFamiliesArray = [[UIFont familyNames] mutableCopy];
    self.systemFontNamesArray = [NSMutableArray new];
    NSUInteger * totalCount = 0;
    
    for (NSString * familyName in self.systemFontFamiliesArray)
    {
        NSArray * fontNames = [UIFont fontNamesForFamilyName:familyName];
        if (!fontNames)
        {
            fontNames = [NSArray new];
        }
        [self.systemFontNamesArray addObject:fontNames];
        
        [self.allFonts addObjectsFromArray:fontNames];
        
        totalCount += fontNames.count;
    }
    
    [self.allFonts sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    self.filteredFonts = [[NSMutableArray alloc] initWithCapacity:self.systemFontNamesArray.count];
    
    self.title = [NSString stringWithFormat:@"System Supported Fonts (%ld)",(long)totalCount];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray * fontNames = self.systemFontNamesArray[section];
    return fontNames.count;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.systemFontFamiliesArray.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray * fontNames = self.systemFontNamesArray[section];
    return [NSString stringWithFormat:@"%@ (%ld)",self.systemFontFamiliesArray[section],(long)fontNames.count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"fontCell" forIndexPath:indexPath];
    
    NSArray * fontNames = self.systemFontNamesArray[indexPath.section];
    NSString * fontName = fontNames[indexPath.row];
    
    cell.textLabel.font = [UIFont fontWithName:fontName size:20];
    cell.textLabel.text = fontName;
    
    return cell;
}

#pragma mark - helper method
- (void)filteredArray:(NSString*)searchStr
{
    self.filteredFonts = nil;
    NSPredicate * predicate = [NSPredicate predicateWithFormat:@"SELF contains[c] %@",searchStr];
    self.filteredFonts = [self.allFonts filteredArrayUsingPredicate:predicate];
}

@end

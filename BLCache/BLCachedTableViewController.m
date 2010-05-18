//
//  BLCachedTableViewController.m
//  Portfolio
//
//  Created by Graham Abbott on 7/24/09.
//  Copyright 2009 Bellum Labs LLC. All rights reserved.
//

#import "BLCachedTableViewController.h"


@implementation BLCachedTableViewController

-(void)prepareCache {
    sections = [[NSMutableArray alloc] init];
    for(int i = 0; i < [self numberOfSectionsInTableView:theTable]; i++) {
        NSMutableArray *section = [[NSMutableArray alloc] init];
        for( int j = 0; j < [self tableView:theTable numberOfRowsInSection:i]; j++ ) {
            [section addObject:[NSNull null]];
        }
        [sections addObject:section];
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    NSMutableArray *section = [sections objectAtIndex:[indexPath section]];
    
    if ([section objectAtIndex:[indexPath row]] == [NSNull null]) {
        cell = [self getTableForRow:indexPath];
        [section replaceObjectAtIndex:[indexPath row] withObject:cell];
    } else {
        cell = [section objectAtIndex:[indexPath row]];
    }
    
    return cell;
} 

-(UITableViewCell *)getTableForRow:(NSIndexPath *)indexPath {
    
    static NSString *MyIdentifier = @"content_cell";
    UITableViewCell *cell = (UITableViewCell*)[theTable dequeueReusableCellWithIdentifier:MyIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:MyIdentifier] autorelease];
    }
    cell.text = @"This is some content.";
    return cell;
}

-(void)clearCacheAndReload {
    for( NSMutableArray *a in sections ) {
        [a removeAllObjects];
    }
    [sections removeAllObjects];
    [sections release];
    sections = [[NSMutableArray alloc] init];
    for(int i = 0; i < [self numberOfSectionsInTableView:theTable]; i++) {
        NSMutableArray *section = [[NSMutableArray alloc] init];
        for( int j = 0; j < [self tableView:theTable numberOfRowsInSection:i]; j++ ) {
            [section addObject:[NSNull null]];
        }
        [sections addObject:section];
    }
}
@end

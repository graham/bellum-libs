//
//  BLCachedTableViewController.h
//  Portfolio
//
//  Created by Graham Abbott on 7/24/09.
//  Copyright 2009 Bellum Labs LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface BLCachedTableViewController : NSObject <UITableViewDelegate, UITableViewDataSource> {
    NSMutableArray *sections;
    IBOutlet UITableView *theTable;
}

-(void)prepareCache;
-(UITableViewCell *)getTableForRow:(NSIndexPath *)indexPath;
-(void)clearCacheAndReload;

@end

//
//  CoreDataTableViewController.h
//  LeonPhotomania
//
//  Created by 李南 on 15/5/20.
//  Copyright (c) 2015年 ctd.leonard. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
@interface CoreDataTableViewController : UITableViewController
@property(nonatomic, strong)  NSFetchedResultsController* fetchResultController;
@property(nonatomic, strong) NSManagedObjectContext *context;
@end

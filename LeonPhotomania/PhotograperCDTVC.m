//
//  PhotograperCDTVC.m
//  LeonPhotomania
//
//  Created by 李南 on 15/5/22.
//  Copyright (c) 2015年 ctd.leonard. All rights reserved.
//

#import "PhotograperCDTVC.h"
#import "Photo.h"
#import "Photographer.h"
#import "PhotoDatabaseAvailability.h"

@interface PhotograperCDTVC ()
@property(nonatomic, strong) NSManagedObjectContext *photographerContext;
@end

@implementation PhotograperCDTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



#pragma mark - Initialize
-(void)awakeFromNib{
    [[NSNotificationCenter defaultCenter]addObserverForName:PhotoDatabaseAvailabilityNotification
                                                     object:nil
                                                      queue:nil
                                                 usingBlock:^(NSNotification *note) {
        
                                                    self.photographerContext = note.userInfo[PhotoDatabaseAvailabilityContext];
        
    }];
}

#pragma mark - Properties 
-(void)setPhotographerContext:(NSManagedObjectContext *)photographerContext{
    if (photographerContext) {
        _photographerContext = photographerContext;
        
        self.fetchResultController = nil;
        
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Photographer"];
        request.predicate = nil;
        NSSortDescriptor *sortdecriptor= [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                                       ascending:YES
                                                                        selector:@selector(localizedStandardCompare:)];
        request.sortDescriptors = @[sortdecriptor];
        
        self.fetchResultController = [[NSFetchedResultsController alloc]initWithFetchRequest:request
                                                                        managedObjectContext:_photographerContext
                                                                          sectionNameKeyPath:nil
                                                                                   cacheName:nil];
        
    }
}
#pragma mark - UITableViewDataSource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"photograper"];
    
    Photographer *photographer  = (Photographer*)[self.fetchResultController objectAtIndexPath:indexPath];
    cell.textLabel.text = photographer.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%lu photos",[photographer.photos count]];
    
    return cell;
}
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
}


@end

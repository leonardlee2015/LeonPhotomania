//
//  Photographer.h
//  LeonPhotomania
//
//  Created by 李南 on 15/5/15.
//  Copyright (c) 2015年 ctd.leonard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


#define PHOTOGRAPHER_ENTITY_NAME @"Photographer"
@class Photo;



@interface Photographer : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) Photo *photos;

@end

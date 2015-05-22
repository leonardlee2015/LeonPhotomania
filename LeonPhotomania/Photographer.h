//
//  Photographer.h
//  LeonPhotomania
//
//  Created by 李南 on 15/5/22.
//  Copyright (c) 2015年 ctd.leonard. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Photo;
#define PHOTOGRAPHER_ENTITY_NAME @"Photographer"
@interface Photographer : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSSet *photos;
@end

@interface Photographer (CoreDataGeneratedAccessors)

- (void)addPhotosObject:(Photo *)value;
- (void)removePhotosObject:(Photo *)value;
- (void)addPhotos:(NSSet *)values;
- (void)removePhotos:(NSSet *)values;

@end

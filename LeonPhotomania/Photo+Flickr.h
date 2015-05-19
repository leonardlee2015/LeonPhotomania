//
//  Photo+Flickr.h
//  LeonPhotomania
//
//  Created by 李南 on 15/5/15.
//  Copyright (c) 2015年 ctd.leonard. All rights reserved.
//

#import "Photo.h"

@interface Photo (Flickr)

+(void)loadPotoFromPotolist:(NSArray*)photolist intoManagedContext:(NSManagedObjectContext*)context;
+(Photo*)photoWithPhotoInfo:(NSDictionary*)PhotoInfo inManagedContext:(NSManagedObjectContext*)context;
@end

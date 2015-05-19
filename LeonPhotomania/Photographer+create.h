//
//  Photographer+create.h
//  LeonPhotomania
//
//  Created by 李南 on 15/5/15.
//  Copyright (c) 2015年 ctd.leonard. All rights reserved.
//

#import "Photographer.h"

@interface Photographer (create)
+(Photographer*)PhotographerWithName:(NSString*)name inManagedContext:(NSManagedObjectContext*) context;
@end

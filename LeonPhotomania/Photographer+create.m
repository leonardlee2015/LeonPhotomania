//
//  Photographer+create.m
//  LeonPhotomania
//
//  Created by 李南 on 15/5/15.
//  Copyright (c) 2015年 ctd.leonard. All rights reserved.
//

#import "Photographer+create.h"

@implementation Photographer (create)
+(Photographer *)PhotographerWithName:(NSString *)name inManagedContext:(NSManagedObjectContext *)context
{
    Photographer *photographer = nil;
    
    if (![name length]) {
        return photographer;
    }
    if (context) {
        // fetch wheather existed the object the have the same name property
        // if exist and  exist only one this kind of object ,return it . otherwize create a new one
        // and return.
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:PHOTOGRAPHER_ENTITY_NAME];
        request.predicate = [NSPredicate predicateWithFormat:@"name = %@", name];
        NSError *error ;
        NSArray *resultArray =[context executeFetchRequest:request error:&error];
        
        if (error || !resultArray || [resultArray count]>1) {
            NSLog(@"[%@,%@] fetch Photographer data failed! get Photographer number :%lu, error :%@",NSStringFromClass([self class]), NSStringFromSelector(_cmd), [resultArray count], [error debugDescription]);
        }else if ([resultArray count] == 1){
            
            photographer = [resultArray lastObject];
        }else{
            photographer = [NSEntityDescription insertNewObjectForEntityForName:PHOTOGRAPHER_ENTITY_NAME inManagedObjectContext:context];
            photographer.name = name;
        }
        
        
    }

    return photographer;
}
@end

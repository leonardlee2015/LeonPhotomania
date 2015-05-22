//
//  Photo+Flickr.m
//  LeonPhotomania
//
//  Created by 李南 on 15/5/15.
//  Copyright (c) 2015年 ctd.leonard. All rights reserved.
//

#import "Photo+Flickr.h"
#import "FlickrFetcher.h"
#import "Photographer+create.h"


@implementation Photo (Flickr)
+(Photo *)photoWithPhotoInfo:(NSDictionary *)PhotoInfo inManagedContext:(NSManagedObjectContext *)context{
    Photo *photo = nil;
    if (context) {
        NSString *unique = PhotoInfo[FLICKR_PHOTO_ID];
        
        NSFetchRequest  *request = [NSFetchRequest fetchRequestWithEntityName:PHOTO_ENTITY_NAME];
        request.predicate = [NSPredicate predicateWithFormat:@"unique = %@", unique];
        
        NSError *error;
        NSArray *matchs =[context executeFetchRequest:request error:&error];
        if (!matchs || error || [matchs count] > 1) {
           
            NSLog(@"[%@,%@] fetch Photo data failed! get Photographer number :%lu, error :%@",NSStringFromClass([self class]), NSStringFromSelector(_cmd), [matchs count], [error debugDescription]);
        }else if ([matchs count]){
            
            photo = [matchs firstObject];
        }else{
            
            photo = [NSEntityDescription insertNewObjectForEntityForName:PHOTO_ENTITY_NAME inManagedObjectContext:context];
            
            photo.unique = PhotoInfo[FLICKR_PHOTO_ID];
            photo.title = PhotoInfo[FLICKR_PHOTO_TITLE];
            photo.subtitle = PhotoInfo[FLICKR_PHOTO_DESCRIPTION];
            photo.imageURL = [[FlickrFetcher URLforPhoto:PhotoInfo format:FlickrPhotoFormatLarge]absoluteString];
            photo.thumbnailURL = [[FlickrFetcher URLforPhoto:PhotoInfo format:FlickrPhotoFormatSquare]absoluteString];
            photo.longitude = [NSNumber numberWithDouble:[(NSString*)PhotoInfo[FLICKR_LONGITUDE] doubleValue]];
            photo.latitube = [NSNumber numberWithDouble: [(NSString*)PhotoInfo[FLICKR_LATITUDE] doubleValue]];
            
            photo.whoTok = [Photographer PhotographerWithName:[PhotoInfo[FLICKR_PHOTO_OWNER] description] inManagedContext:context];
            
        }

        
    }
    return photo;
}
+(void)loadPotoFromPotolist:(NSArray *)photolist intoManagedContext:(NSManagedObjectContext *)context
{
    
    for (NSDictionary *photoInfo in photolist) {
        [Photo photoWithPhotoInfo:photoInfo inManagedContext:context];
    }
}
@end

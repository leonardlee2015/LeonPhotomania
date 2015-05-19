//
//  AppDelegate.m
//  LeonPhotomania
//
//  Created by 李南 on 15/5/15.
//  Copyright (c) 2015年 ctd.leonard. All rights reserved.
//

#import "AppDelegate.h"
#import "FlickrFetcher.h"
#import "Photo+Flickr.h"
#import "Photographer+create.h"
#import <CoreData/CoreData.h>

#define FLICKR_BACKGROUND_FETCH @"flick background fetch"

@interface AppDelegate ()<NSURLSessionDownloadDelegate>
@property(nonatomic, strong) NSManagedObjectContext *photoMananagedObjectContext;
@property(nonatomic, strong) UIManagedDocument *ManagedDocument;
@property(nonatomic, strong) NSURLSession *flickerFecthSession;
@end

@implementation AppDelegate
#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}




#pragma mark - Data Internet Fetching
-(void)startFlickrFetch
{
    if (self.photoMananagedObjectContext) {
        [self.flickerFecthSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            if (![downloadTasks count]) {
                NSURL *url = [FlickrFetcher URLforRecentGeoreferencedPhotos];
                NSURLSessionDownloadTask *task = [self.flickerFecthSession downloadTaskWithURL:url];
                task.taskDescription =FLICKR_BACKGROUND_FETCH;
                [task resume];
            }else{
                for (NSURLSessionDownloadTask *task in downloadTasks) {
                    [task resume];
                }
            }
        }];
    }
}

-(NSURLSession *)flickerFecthSession{
   
    if (!_flickerFecthSession) {
        
        static dispatch_once_t once;
        dispatch_once(&once, ^{
            NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:FLICKR_BACKGROUND_FETCH];
            _flickerFecthSession = [NSURLSession sessionWithConfiguration:sessionConfig
                                                                 delegate:self delegateQueue:nil];
            
        });
        
    
    }
    return _flickerFecthSession;
}

-(void)downloadFlickrPhotoFromLocalURL:(NSURL*)localfile intoManagedContext:(NSManagedObjectContext*) context{
    NSData *jsonData = [NSData dataWithContentsOfURL:localfile];
    
    NSDictionary *flickrPropertyList;
    if (jsonData) {
        flickrPropertyList = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:NULL];
        
        [Photo loadPotoFromPotolist:flickrPropertyList[FLICKR_RESULTS_PHOTOS] intoManagedContext:context];
        [context save:NULL];
        
        [self downloadTaskCompelete];
    }
    
    
}

#pragma mark - Core Data

-(void)CreateManangedDocument
{
    NSURL *url = [[self documentDirectoryUrl] URLByAppendingPathComponent:@"Photomania.md"];
    UIManagedDocument *document = [[UIManagedDocument alloc]initWithFileURL:url];
    self.ManagedDocument = document;
    
    // set document to be auto save.
    document.persistentStoreOptions = @{NSMigratePersistentStoresAutomaticallyOption: [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption:[NSNumber numberWithBool:YES]};
    
    if (![[NSFileManager defaultManager]fileExistsAtPath:[url path]]) {
        [document saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success) {
            if (success) {
                self.photoMananagedObjectContext = document.managedObjectContext;
                [self startFlickrFetch];
            }else{
                NSLog(@" Saves document data to the specified location in the application sandbox failed!");
            }
        }];
        
    }else if (document.documentState == UIDocumentStateClosed){
        
        [document openWithCompletionHandler:^(BOOL success) {
            if (success) {
                self.photoMananagedObjectContext = document.managedObjectContext;
                [self startFlickrFetch];
            }else{
                NSLog(@" Opens a document asynchronously. failed!");
            }
        }];
    }else{
        self.photoMananagedObjectContext = document.managedObjectContext;
        [self startFlickrFetch];
    }
}

-(NSURL *)documentDirectoryUrl
{
    return [[[NSFileManager defaultManager]URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask]lastObject];
}

#pragma mark - NSURLSessionDownloadDelegate
-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
    if ([downloadTask.taskDescription isEqualToString:FLICKR_BACKGROUND_FETCH]) {
        [self downloadFlickrPhotoFromLocalURL:location intoManagedContext:self.photoMananagedObjectContext];
    }
    
}

-(void)downloadTaskCompelete{
    
}
@end

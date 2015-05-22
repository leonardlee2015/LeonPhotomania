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
#import "PhotoDatabaseAvailability.h"
#import <CoreData/CoreData.h>

//  background flickr data fetech identifer.
#define FLICKR_BACKGROUND_FETCH @"flick background fetch"
//  fetch background mode download time out interval.
#define BACKGROUND_FETHCH_TIMEOUT_INTERVAL (10)
//  background fetch flickr data interval.
#define FLICKR_BACKGROUND_FETCH_INTERVAL (20*60)

@interface AppDelegate ()<NSURLSessionDownloadDelegate>
@property(nonatomic, strong) NSManagedObjectContext *photoMananagedObjectContext;
@property(nonatomic, strong) UIManagedDocument *ManagedDocument;
@property(nonatomic, strong) NSURLSession *flickerFecthSession;
@property(nonatomic, strong) void(^flickrDownloadBackgroundURLSessionCompletionHandler)();
@property(nonatomic, strong) NSTimer *fetchIntervalTimer;

@end

@implementation AppDelegate
#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:FLICKR_BACKGROUND_FETCH_INTERVAL];
    [self CreateManangedDocument];
    return YES;
}
// fetch data if  our application is in  fetch background mode.
-(void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    if (self.photoMananagedObjectContext) {
        NSURLSessionConfiguration *config = [ NSURLSessionConfiguration ephemeralSessionConfiguration];
        config.allowsCellularAccess = NO;
        config.timeoutIntervalForRequest = BACKGROUND_FETHCH_TIMEOUT_INTERVAL;
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos]];
        
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
            if (!error) {
                [self downloadFlickrPhotoFromLocalURL:location intoManagedContext:self.photoMananagedObjectContext];
                completionHandler(UIBackgroundFetchResultNewData);
                
            }else{
                completionHandler(UIBackgroundFetchResultNoData);
            }
        }];
        [task resume];
    }else{
        completionHandler(UIBackgroundFetchResultNoData);
    }
    
}

-(void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler{
    self.flickrDownloadBackgroundURLSessionCompletionHandler = completionHandler;
}
#pragma mark - Data Internet Fetching

-(void)startFlickrFetch:(NSTimer*)timer{
    [self startFlickrFetch];
}
-(void)startFlickrFetch
{
    if (self.photoMananagedObjectContext) {
        [self.flickerFecthSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            if (![downloadTasks count]) {
                NSLog(@"start fetch ?");
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
/**
 *  download flickr Photos from local data into Core data.
 *
 *  @param localfile local file that download from internet.
 *  @param context   core data Context.
 */
-(void)downloadFlickrPhotoFromLocalURL:(NSURL*)localfile intoManagedContext:(NSManagedObjectContext*) context{
    NSData *jsonData = [NSData dataWithContentsOfURL:localfile];
    
    NSDictionary *flickrPropertyList;
    if (jsonData) {
        flickrPropertyList = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:NULL];
        NSArray *photolist = [flickrPropertyList valueForKeyPath:FLICKR_RESULTS_PHOTOS];
        [Photo loadPotoFromPotolist:photolist intoManagedContext:context];
        [context save:NULL];
        
        [self downloadTaskMaightBeCompelete];
    }
    
    
}

#pragma mark - Properties
-(void)setPhotoMananagedObjectContext:(NSManagedObjectContext *)photoMananagedObjectContext{
    
    if (photoMananagedObjectContext) {
        _photoMananagedObjectContext = photoMananagedObjectContext;
        NSTimer *oldTimer;
        self.fetchIntervalTimer = nil;
        [oldTimer invalidate];
        
        self.fetchIntervalTimer = [NSTimer timerWithTimeInterval:BACKGROUND_FETHCH_TIMEOUT_INTERVAL
                                                          target:self
                                                        selector:@selector(startFlickrFetch:)
                                                        userInfo:nil
                                                         repeats:YES];
        
        NSDictionary *userInfo = @{PhotoDatabaseAvailabilityContext: photoMananagedObjectContext};
        [[NSNotificationCenter defaultCenter] postNotificationName:PhotoDatabaseAvailabilityNotification
                                                            object:nil
                                                          userInfo:userInfo];
        
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

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes{
    
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite{
    
}

// We should  definitely  catch errors here,
// So that we can avoid crashes.
// And also so that we can detect download task (may be) is complete.
-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error{
    if (error && (session==self.flickerFecthSession)){
        [self  downloadTaskMaightBeCompelete];
    }
}

-(void)downloadTaskMaightBeCompelete{
    
    if (self.flickrDownloadBackgroundURLSessionCompletionHandler) {
        [self.flickerFecthSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            if (![downloadTasks count]) {
                void(^completeHandler)() = self.flickrDownloadBackgroundURLSessionCompletionHandler;
                self.flickrDownloadBackgroundURLSessionCompletionHandler = nil;
                if (completeHandler) {
                    completeHandler();
                }
            }
        }];
    }
}

@end

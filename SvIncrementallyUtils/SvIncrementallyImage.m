//
//  SvIncrementallyImage.m
//  SvIncrementallyImage
//
//  Created by  maple on 6/27/13.
//  Copyright (c) 2013 maple. All rights reserved.
//

#import "SvIncrementallyImage.h"
#import <ImageIO/ImageIO.h>
#import <CoreFoundation/CoreFoundation.h>

@interface SvIncrementallyImage () {
    NSURLRequest    *_request;
    NSURLConnection *_conn;
    
    CGImageSourceRef _incrementallyImgSource;
    
    NSMutableData   *_recieveData;
    long long       _expectedLeght;
}

@property (nonatomic, retain) UIImage *image;

@end

@implementation SvIncrementallyImage

@synthesize imageURL = _imageURL;
@synthesize image    = _image;

- (id)initWithURL:(NSURL *)imageURL
{
    self = [super init];
    if (self) {
        _imageURL = [imageURL retain];
        
        _request = [[NSURLRequest alloc] initWithURL:_imageURL];
        _conn    = [[NSURLConnection alloc] initWithRequest:_request delegate:self];
        
        _incrementallyImgSource = CGImageSourceCreateIncremental(NULL);
        
        _recieveData = [[NSMutableData alloc] init];
    }
    
    return self;
}

- (void)dealloc
{
    [_request release]; _request = nil;
    [_conn release];    _conn = nil;
    [_recieveData release]; _recieveData = nil;
    
    CFRelease(_incrementallyImgSource); _incrementallyImgSource = NULL;
    
    [super dealloc];
}

#pragma mark -
#pragma mark NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _expectedLeght = response.expectedContentLength;
    NSLog(@"expected Length: %lld", _expectedLeght);
    
    NSString *mimeType = response.MIMEType;
    NSLog(@"MIME TYPE %@", mimeType);
    
    NSArray *arr = [mimeType componentsSeparatedByString:@"/"];
    if (arr.count < 1 || ![[arr objectAtIndex:0] isEqual:@"image"]) {
        NSLog(@"not a image url");
        [connection cancel];
        [_conn release]; _conn = nil;
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    NSLog(@"Connection %@ error, error info: %@", connection, error);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSLog(@"Connection Loading Finished!!!");
    
    CGImageSourceUpdateData(_incrementallyImgSource, (CFDataRef)_recieveData, true);
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(_incrementallyImgSource, 0, NULL);
    self.image = [UIImage imageWithCGImage:imageRef];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSLog(@"recieve data: %@", data);
    
    [_recieveData appendData:data];
    
    bool isFinished = false;
    if (_expectedLeght == _recieveData.length) {
        isFinished = true;
    }
    
    CGImageSourceUpdateData(_incrementallyImgSource, (CFDataRef)_recieveData, true);
    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(_incrementallyImgSource, 0, NULL);
    self.image = [UIImage imageWithCGImage:imageRef];
    
    CFRelease(_incrementallyImgSource);
    _incrementallyImgSource = CGImageSourceCreateIncremental(NULL);
}

@end

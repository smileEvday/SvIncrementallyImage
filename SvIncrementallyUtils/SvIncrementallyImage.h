//
//  SvIncrementallyImage.h
//  SvIncrementallyImage
//
//  Created by  maple on 6/27/13.
//  Copyright (c) 2013 maple. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SvIncrementallyImage : NSObject <NSURLConnectionDataDelegate>

@property (nonatomic, readonly) NSURL *imageURL;

@property (nonatomic, readonly) UIImage *image;

- (id)initWithURL:(NSURL*)imageURL;

@end

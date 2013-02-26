//
//  JAMViewController.h
//  AzureSample
//
//  Created by Juan Antonio Martin Noguera on 2/22/13.
//  Copyright (c) 2013 teacher. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JAMViewController : UIViewController 

-(IBAction)uploadAnImageonBlobContainer:(id)sender;
@property (weak, nonatomic) IBOutlet UIImageView *blobViewer;

- (IBAction)downLoadImageBlob:(id)sender;


- (IBAction)createContainer:(id)sender;

- (IBAction)showContainers:(id)sender;

@end

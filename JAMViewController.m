//
//  JAMViewController.m
//  AzureSample
//
//  Created by Juan Antonio Martin Noguera on 2/22/13.
//  Copyright (c) 2013 teacher. All rights reserved.
//

#import <WindowsAzureMobileServices/WindowsAzureMobileServices.h>
#import "JAMViewController.h"



#import <watoolkitios/WAToolkit.h>

#define kAzureApplicationKey @"qiyqQWCjJONpBhTaxrOSlqwoWFNmZG74"
#define kAzureStorageAccessKey @"S0TFGGvrUf/FZ4CIIlmuxcX5zpih+Vuw26gaWsKzAj+pI9cDaY2M3GekpTvUQ2lWvWKUnhW60J+wt2Qy9qoVTQ=="
#define kStorageAccount @"juancursoutad"
#define BLOB_SERVICE_URI @"http://juancursoutad.blob.core.windows.net/myimages"

@interface JAMViewController ()

@end

@implementation JAMViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    NSDictionary * theObject = [self findAnFilmObjectInAzureTable:@"Bladerunner"];    NSLog(@"%@", theObject);
    
    

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)addNewObjectOnAzureTable:(NSString*)aTableName anObject:(NSDictionary *)anObject{
  
    MSClient * theClient = [MSClient clientWithApplicationURLString:@"https://juantodo.azure-mobile.net/"
                                                 withApplicationKey:@"qiyqQWCjJONpBhTaxrOSlqwoWFNmZG74"];
    
    
    MSTable *tableMS = [theClient getTable:@"PelisData"];
    
    [tableMS insert:anObject completion:^(NSDictionary *insertedItem, NSError *error) {
        if (error) {
            NSLog(@"Error: %@", error);
        } else {
            NSLog(@"Item inserted, id: %@", [insertedItem objectForKey:@"id"]);
        }
    }];

    
}

-(NSDictionary*)findAnFilmObjectInAzureTable:(NSString *)aFilmName {
    
    NSPredicate* predicate = [NSPredicate predicateWithFormat:@"Titulo == %@", aFilmName];
    MSClient * theClient = [MSClient clientWithApplicationURLString:@"https://juantodo.azure-mobile.net/"
                                                 withApplicationKey:@"qiyqQWCjJONpBhTaxrOSlqwoWFNmZG74"];
    
    
    MSTable *tableMS = [theClient getTable:@"PelisData"];
    __block NSMutableArray* results =[NSMutableArray array];
    [tableMS readWhere:predicate completion:^(NSArray *items, NSInteger totalCount, NSError *error) {
        
        results = [items mutableCopy];
        NSLog(@"%@", results);
    }];
    
     
    return [results lastObject];

    
}

-(IBAction)uploadAnImageonBlobContainer:(id)sender {
    
    
    //Creamos los credenciales y el cliente de Storage
    WAAuthenticationCredential *credential = [WAAuthenticationCredential credentialWithAzureServiceAccount:@"juancursoutad" accessKey:@"S0TFGGvrUf/FZ4CIIlmuxcX5zpih+Vuw26gaWsKzAj+pI9cDaY2M3GekpTvUQ2lWvWKUnhW60J+wt2Qy9qoVTQ=="];
    WACloudStorageClient *storageClient = [WACloudStorageClient storageClientWithCredential:credential];
    
    
    // creamos el blob a partir de una imagen
    

    WABlob* theBlob = [[WABlob alloc] initBlobWithName:@"thefoto.jpeg" URL:@"http://juancursoutad.blob.core.windows.net/" containerName:@"myimages"];
    theBlob.contentData = UIImageJPEGRepresentation([UIImage imageNamed:@"microsoft-dublin2.jpeg"], 0.5);
    theBlob.contentType = @"application/octet-stream";
    
    WABlobContainer * container = [[WABlobContainer alloc] initContainerWithName:@"myimages"];
    [storageClient addBlob: theBlob toContainer:container withCompletionHandler:^(NSError *error) {
        
        if (error) {
            NSLog(@"error : %@", error.description);
        }
    }];

}





- (IBAction)downLoadImageBlob:(id)sender {
    
    //Creamos los credenciales y el cliente de Storage
    WAAuthenticationCredential *credential = [WAAuthenticationCredential credentialWithAzureServiceAccount:@"juancursoutad" accessKey:@"S0TFGGvrUf/FZ4CIIlmuxcX5zpih+Vuw26gaWsKzAj+pI9cDaY2M3GekpTvUQ2lWvWKUnhW60J+wt2Qy9qoVTQ=="];
    WACloudStorageClient *storageClient = [WACloudStorageClient storageClientWithCredential:credential];
    
    WABlob* theBlob = [[WABlob alloc] initBlobWithName:@"thefoto.jpeg" URL:@"http://juancursoutad.blob.core.windows.net/" containerName:@"myimages"]; 

    [storageClient fetchBlobData:theBlob withCompletionHandler:^(NSData *data, NSError *error) {
        
        if(!error){
            self.blobViewer.image = [UIImage imageWithData:data];
        } else {
            NSLog(@"error %@", error.description);
        }
    }];
    
}


- (IBAction)createContainer:(id)sender{
    WAAuthenticationCredential *credential = [WAAuthenticationCredential credentialWithAzureServiceAccount:kStorageAccount accessKey:kAzureStorageAccessKey];
    WACloudStorageClient *storageClient = [WACloudStorageClient storageClientWithCredential:credential];
    
    //creamos un nuevo container
    
    WABlobContainer *theContainer = [[WABlobContainer alloc] initContainerWithName:@"contenedor"];
    
    
    [storageClient addBlobContainer:theContainer withCompletionHandler:^(NSError *error) {
        
        if (error) {
            NSLog(@"Error -> : %@ ", error.description);
        }
        
    }];
    
}

- (IBAction)showContainers:(id)sender {
    
    [self giveMeAllObjectFromContainer];
}

-(void)giveMeAllObjectFromContainer{
    
    WAAuthenticationCredential *credential = [WAAuthenticationCredential credentialWithAzureServiceAccount:kStorageAccount accessKey:kAzureStorageAccessKey];
    WACloudStorageClient *storageClient = [WACloudStorageClient storageClientWithCredential:credential];
    
    //Primero todos los containers de la cuenta;
    WABlobContainerFetchRequest * thRequest;
    
    [storageClient fetchBlobContainersWithRequest:thRequest usingCompletionHandler:^(NSArray *containers, WAResultContinuation *resultContinuation, NSError *error) {
        
        if (!error) {
       
            for (id item in containers) {
                if ([item isKindOfClass:[WABlobContainer class]]) {
                    WABlobContainer *container = item;
                    NSLog(@"%@", container.name);
                }
            }
        }
    }];
    
    NSLog(@"%@",thRequest);
}


@end

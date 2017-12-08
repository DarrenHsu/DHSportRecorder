//
//  DHLocation.h
//  DHRunning
//
//  Created by skcu1805 on 2014/5/8.
//  Copyright (c) 2014年 DH. All rights reserved.
//

@import UIKit;
@import CoreLocation;

typedef enum{
	KATStopRecoding,		//停止並儲存記錄
	KATSuspendedRecoding,	//暫停記錄
	KATPlayRecoding			//開始記錄
} kActionTag;

@protocol DHLocationDelegate;

@interface DHLocation : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) NSString *        countryName;
@property (nonatomic, strong) NSString *        locality;

@property (nonatomic, strong) NSMutableArray *  delegates;
@property (nonatomic, assign) kActionTag        appCurrentActionTag;
@property (nonatomic, assign) BOOL              locationOn;
@property (nonatomic, strong) NSString *        LocationID;
@property (nonatomic, strong) NSString *        LocationName;
@property (nonatomic, assign) unsigned int      cumulativeTimeInternal;
@property (nonatomic, assign) float             cumulativeKM;
@property (nonatomic, assign) float             cumulativeMaxKM;
@property (nonatomic, assign) double            cumulativeMS;
@property (nonatomic, assign) float             currentSpeed;
@property (nonatomic, assign) float             hightSpeed;
@property (nonatomic, assign) float             averageSpeed;
@property (nonatomic, assign) double            altitude;

@property (nonatomic, strong) CLLocation *      currentLocation;
@property (nonatomic, strong) NSString *        errorMessage;
@property (nonatomic, strong) NSMutableArray *  coordinates;

+ (DHLocation *) shardDHLocation;
+ (NSString*) stringWithNewUUID;

- (void) registerDelegate:(id<DHLocationDelegate>) delegate;
- (void) removeDelegate:(id<DHLocationDelegate>) delegate;
- (void) startWithLocationName:(NSString *) name locationId:(NSString *) lid;
- (void) stopLocation;
- (void) suspendedLocation;

@end

@interface DHLocationCoordinate : NSObject

@property (nonatomic, assign) CLLocationDegrees latitude;
@property (nonatomic, assign) CLLocationDegrees longitude;

@end

@protocol DHLocationDelegate <NSObject>
@optional
- (void) receiverStart:(DHLocation *) location;
- (void) receiverSuspended:(DHLocation *) location;
- (void) receiverStop:(DHLocation *) location;
- (void) receiverChangeTime:(DHLocation *) location;
- (void) receiverChange:(DHLocation *) location;
- (void) receiverError:(DHLocation *) location;

@end

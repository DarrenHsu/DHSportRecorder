//
//  DHLocation.m
//  DHRunning
//
//  Created by skcu1805 on 2014/5/8.
//  Copyright (c) 2014年 DH. All rights reserved.
//

#import "DHLocation.h"

static DHLocation *locationObject = nil;

#define kDistanceFilter         2.5
#define kFullAccuracy           20
#define kZeroTimeInterval       5
#define KTempLocationCount      2
#define kMaxHightSpeed          150
#define kMaxAverageSpeedTimes   1

@interface DHLocation () {
    int _gpsUploadCount;
    NSTimer *_cumulativeTimer;
    double _tempMS;
    float _tempKM;
}

@property (nonatomic, strong) CLLocationManager *   locationManager;
@property (nonatomic, strong) CLLocation *          tempLocation;

@end


@implementation DHLocation

+ (DHLocation *) shardDHLocation {
    @synchronized(locationObject) {
        if (!locationObject) {
            locationObject = [self new];
        }
    }
    return locationObject;
}

- (id) init {
    self = [super init];
    if (self) {
        [self setupDefaultValue];
    }
    return self;
}

- (NSString *) description {
    NSMutableString *des = [NSMutableString new];
    [des appendFormat:@"\n =========== location ============"];
    [des appendFormat:@"\n appCurrentActionTag = %d",_appCurrentActionTag];
    [des appendFormat:@"\n locationOn = %d",_locationOn];
    [des appendFormat:@"\n LocationID = %@",_LocationID];
    [des appendFormat:@"\n LocationName = %@",_LocationName];
    [des appendFormat:@"\n cumulativeTimeInternal = %d",_cumulativeTimeInternal];
    [des appendFormat:@"\n cumulativeKM = %f",_cumulativeKM];
    [des appendFormat:@"\n cumulativeMaxKM = %f",_cumulativeMaxKM];
    [des appendFormat:@"\n cumulativeMS = %f",_cumulativeMS];
    [des appendFormat:@"\n currentSpeed = %f",_currentSpeed];
    [des appendFormat:@"\n hightSpeed = %f",_hightSpeed];
    [des appendFormat:@"\n averageSpeed = %f",_averageSpeed];
    [des appendFormat:@"\n altitude = %f",_altitude];
    [des appendFormat:@"\n longitude = %f",_currentLocation.coordinate.longitude];
    [des appendFormat:@"\n latitude = %f",_currentLocation.coordinate.latitude];
    [des appendFormat:@"\n err = %@",_errorMessage];
    [des appendFormat:@"\n _coordinates = %@",_coordinates];
    return des;
}

+ (NSString*) stringWithNewUUID {
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    NSString *newUUID = (NSString *)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
    CFRelease(uuidObj);
    return newUUID;
}

- (void) registerDelegate:(id<DHLocationDelegate>) delegate {
    if (!_delegates)
        [self setDelegates:[NSMutableArray new]];
    
    if (![_delegates containsObject:delegate])
        [_delegates addObject:delegate];
}

- (void) removeDelegate:(id<DHLocationDelegate>) delegate {
    [_delegates removeObject:delegate];
}

- (void) cumulativeTime {
	self.cumulativeTimeInternal++;
	
	if (self.currentSpeed > 0 && self.tempLocation) {
		NSDate *date = [self.tempLocation timestamp];
		NSDate *nowDate = [[NSDate alloc] init];
		NSTimeInterval second = [nowDate timeIntervalSinceDate:date];
		if (second > kZeroTimeInterval) {
			self.currentSpeed = 0;
		}
	}
    
    for (id<DHLocationDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(receiveChangeTime:)]) {
            [delegate receiveChangeTime:self];
        }
    }
}

- (void) setupDefaultValue {
    if (_coordinates) [_coordinates removeAllObjects];

    [self setCurrentLocation:nil];
    [self.coordinates removeAllObjects];
    [self setCoordinates:[NSMutableArray new]];
    [self setCumulativeTimeInternal:0];
	[self setCumulativeMS:0];
	[self setCumulativeKM:0];
	[self setCumulativeMaxKM:0];
	[self setAltitude:0];
	[self setHightSpeed:0];
	[self setCurrentSpeed:0];
	[self setAverageSpeed:0];
	[self setTempLocation:nil];
    
    _tempMS = 0;
    _tempKM = 0;
	_gpsUploadCount = 0;
    _countryName = nil;
    _locality = nil;
}

- (void) startWithLocationName:(NSString *) name locationId:(NSString *) lid {
    if (_appCurrentActionTag == KATPlayRecoding)
        return;
    
    [self setLocationID:lid];
    [self setLocationName:name];
    [self setupDefaultValue];
	[self playLocation];
    
    for (id<DHLocationDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(receiveStart:)]) {
            [delegate receiveStart:self];
        }
    }
}

- (void) playLocation {
	if (!self.locationManager) {
		[self setLocationManager:[CLLocationManager new]];
        [self.locationManager setDelegate:self];
        [self.locationManager setDistanceFilter:kDistanceFilter];
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager requestAlwaysAuthorization];

        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8) {
            [self.locationManager requestAlwaysAuthorization];
        }

        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9) {
            self.locationManager.allowsBackgroundLocationUpdates = YES;
        }
	}
	
	[self.locationManager startUpdatingLocation];
	
	_cumulativeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                        target:self
                                                      selector:@selector(cumulativeTime)
                                                      userInfo:nil
                                                       repeats:YES];
    [self setAppCurrentActionTag:KATPlayRecoding];
}

- (void) stopLocation{
    if (self.appCurrentActionTag == KATStopRecoding)
        return;
    
    for (id<DHLocationDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(receiveWillStop:)]) {
            [delegate receiveWillStop:self];
        }
    }
    
    if (self.locationManager) {
        [self.locationManager stopUpdatingLocation];
        [self setLocationManager:nil];
    }
    
    if (_cumulativeTimer) {
        [_cumulativeTimer invalidate];
        _cumulativeTimer = nil;
    }
    
    [self setAppCurrentActionTag:KATStopRecoding];
    [self setLocationID:nil];
    [self setLocationName:nil];
    [self setLocationOn:NO];
    
	for (id<DHLocationDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(receiveStop:)]) {
            [delegate receiveStop:self];
        }
    }
}

- (void) suspendedLocation{
    if (_appCurrentActionTag == KATSuspendedRecoding)
        return;
    
	if (self.locationManager) {
		[self.locationManager stopUpdatingLocation];
	}
	
	if (_cumulativeTimer) {
		[_cumulativeTimer invalidate];
		_cumulativeTimer = nil;
	}
    
    [self setAppCurrentActionTag:KATSuspendedRecoding];
    
    for (id<DHLocationDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(receiveSuspended:)]) {
            [delegate receiveSuspended:self];
        }
    }
}

- (void) clearData {
    [self setupDefaultValue];
}

#pragma mark -
#pragma mark CLLocationManagerDelegate Methods
- (BOOL) locationManagerShouldDisplayHeadingCalibration: (CLLocationManager *)manager {
	return YES;
}

- (void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
    
    if (locationAge > 5.0) return;
    
    /* test that the horizontal accuracy does not indicate an invalid measurement */
    if (newLocation.horizontalAccuracy < 0) return;
    
    if (newLocation.horizontalAccuracy <= kFullAccuracy) {
        [self setLocationOn:YES];
	}else {
        [self setLocationOn:NO];
	}

    /* Get current location area name */
    if (!_countryName && !_locality) {
        CLGeocoder * geoCoder = [[CLGeocoder alloc] init];
        [geoCoder reverseGeocodeLocation:newLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            for (CLPlacemark *placemark in placemarks) {
                _countryName = placemark.country;
                _locality = placemark.locality;
            }
        }];
    }

    for (id<DHLocationDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(receiveChange:)]) {
            [delegate receiveChange:self];
        }
    }
    
	/* heck GPS count is correct */
	if(_gpsUploadCount > KTempLocationCount && self.tempLocation && newLocation && oldLocation &&
	   (newLocation.coordinate.latitude != oldLocation.coordinate.latitude) &&
	   (newLocation.coordinate.longitude != oldLocation.coordinate.longitude)) {
		
		CLLocationDistance distance = [newLocation distanceFromLocation:oldLocation];
		distance = distance / 1000;
		self.cumulativeMaxKM += distance;
	}
	
	BOOL locationChanged = YES;
	if(newLocation && self.tempLocation &&
	   (newLocation.coordinate.latitude != self.tempLocation.coordinate.latitude) &&
	   (newLocation.coordinate.longitude != self.tempLocation.coordinate.longitude) &&
	   newLocation.horizontalAccuracy <= kFullAccuracy) {
		locationChanged = YES;
	}else {
		locationChanged = NO;
	}
	
	if (locationChanged) {
		CLLocationDistance distance = [newLocation distanceFromLocation:self.tempLocation];
		float speed;
		
		NSDate *newDate = [newLocation timestamp];
		NSDate *oldDate = [self.tempLocation timestamp];
		NSTimeInterval second = [newDate timeIntervalSinceDate:oldDate];
		
		distance = distance / 1000;
		speed = distance / (second / 3600);
		
		[self setAltitude:[newLocation altitude]];
		
		if (self.averageSpeed == 0 && distance > (kDistanceFilter / 1000)) {
			self.cumulativeMS += second;
			self.cumulativeKM += (kDistanceFilter / 1000);
			_tempMS += second;
			_tempKM += (kDistanceFilter / 1000);
		}else {
			self.cumulativeMS += second;
			self.cumulativeKM += distance;
			_tempMS += second;
			_tempKM += distance;
		}
		
		/* AVG Speed */
		self.averageSpeed = self.cumulativeKM / (self.cumulativeMS / 3600);
		
		/* Current Speed */
		self.currentSpeed = _tempKM / (_tempMS / 3600);
		if (self.averageSpeed > 0 && self.currentSpeed > self.averageSpeed * kMaxAverageSpeedTimes) {
			self.currentSpeed = self.averageSpeed;
		}
		_tempKM = 0;
		_tempMS = 0;
		
		/* Max speed */
		if (self.currentSpeed > self.hightSpeed && self.currentSpeed < kMaxHightSpeed) {
			self.hightSpeed = self.currentSpeed;
		}
		
        [self setCurrentLocation:newLocation];
        
        DHLocationCoordinate *coordinate = [DHLocationCoordinate new];
        [coordinate setLongitude:newLocation.coordinate.longitude];
        [coordinate setLatitude:newLocation.coordinate.latitude];
        [_coordinates addObject:coordinate];
        
        for (id<DHLocationDelegate> delegate in _delegates) {
            if ([delegate respondsToSelector:@selector(receiveChange:)]) {
                [delegate receiveChange:self];
            }
        }
	}
	
	if (newLocation.horizontalAccuracy <= kFullAccuracy) {
		if (_gpsUploadCount > KTempLocationCount) {
			[self setTempLocation:newLocation];
		}
		
		_gpsUploadCount++;
	}
}

- (void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error  {
	NSString *str;
    
	if ([manager maximumRegionMonitoringDistance] == kCLErrorLocationUnknown) {
		str = @"kCLErrorLocationUnknown";
	} else if ([manager maximumRegionMonitoringDistance] == kCLErrorDenied) {
		str = @"kCLErrorDenied";
	} else if ([manager maximumRegionMonitoringDistance] == kCLErrorNetwork) {
		str = @"kCLErrorNetwork";
	} else if ([manager maximumRegionMonitoringDistance] == kCLErrorHeadingFailure) {
		str = @"kCLErrorHeadingFailure";
	} else if ([manager maximumRegionMonitoringDistance] == kCLErrorRegionMonitoringDenied) {
		str = @"kCLErrorRegionMonitoringDenied";
	} else if ([manager maximumRegionMonitoringDistance] == kCLErrorRegionMonitoringFailure) {
		str = @"kCLErrorRegionMonitoringFailure";
	} else if ([manager maximumRegionMonitoringDistance] == kCLErrorRegionMonitoringSetupDelayed) {
		str = @"kCLErrorRegionMonitoringSetupDelayed";
	} else {
		str = @"kOtherGPSError";
	}
    
    [self setErrorMessage:str];
    for (id<DHLocationDelegate> delegate in _delegates) {
        if ([delegate respondsToSelector:@selector(receiveError:)]) {
            [delegate receiveError:self];
        }
    }
}

@end

@implementation DHLocationCoordinate

- (id) initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        _longitude = [decoder decodeDoubleForKey:@"longitude"];
        _latitude = [decoder decodeDoubleForKey:@"latitude"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *) coder {
    [coder encodeDouble:_longitude forKey:@"longitude"];
    [coder encodeDouble:_latitude forKey:@"latitude"];
}

- (NSString *) description {
    NSMutableString *str = [NSMutableString new];
    [str appendFormat:@"\n_longitude = %f",_longitude];
    [str appendFormat:@"\n_latitude = %f",_latitude];
    return str;
}

@end

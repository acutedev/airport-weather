//
//  IPLWeather.h
//  AirportWeather
//
//  Created by Lana Svieta on 7/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IPLWeather : NSObject 
{
    
}
// Weather Singleton - no need for more than one weather object in this app
+ (IPLWeather *) defaultWeather;

- (void) save;

@property (nonatomic, strong) NSString *airportCode;
@property (nonatomic, strong) NSString *weatherData;
@end

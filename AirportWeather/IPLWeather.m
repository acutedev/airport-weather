//
//  IPLWeather.m
//  AirportWeather
//
//  Created by Lana Svieta on 7/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "IPLWeather.h"

@implementation IPLWeather

@synthesize airportCode;
@synthesize weatherData;

//Singleton Weather Object
+ (IPLWeather *)defaultWeather
{
    static IPLWeather *defaultWeather = nil;
    
    if(!defaultWeather) {
        defaultWeather = [[super alloc] init];        
    }
    return defaultWeather;
}

- (id) init
{
    self = [super init];
    if (self) {
        // Restore Saved Last Searched on Airport code      
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        
        airportCode= [defaults objectForKey:@"airportCode"];
    }
    return self;
}


#pragma mark - Saving
- (void) save
{
    // Saving airportCode
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:airportCode forKey:@"airportCode"];
}

@end

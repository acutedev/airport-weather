//
//  IPLViewController.h
//  AirportWeather
//
//  Created by Lana Svieta on 7/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IPLWeather.h"

@interface IPLWeatherAppViewController : UIViewController <UIAlertViewDelegate>  {
    
    //View Objects
    __weak IBOutlet UITextField *airportCodeField;    
    
    __weak IBOutlet UILabel *weatherDataLabel;    

    __weak IBOutlet UIActivityIndicatorView *activityIndicator;

}

// Model Objects
@property (nonatomic, strong) IPLWeather *weather;

// Actions
- (IBAction) getCurrentAirportWeather:(id)sender;

- (void) getCurrentAirportWeatherForValidAirportCode:(NSString*)airportCode;
- (BOOL) hasInternetConnection;
@end

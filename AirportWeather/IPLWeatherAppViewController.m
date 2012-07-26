//
//  IPLViewController.m
//  AirportWeather
//
//  Created by Lana Svieta on 7/14/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//
#define kBgQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) 
#define kGeonamesWeatherIcaoURLString @"http://api.geonames.org/weatherIcaoJSON?formatted=true&username=acutedev&style=full&ICAO="
#define kReachabilityChangedNotification @"kNetworkReachabilityChangedNotification"

#import "IPLWeatherAppViewController.h"
#import "IPLWeather.h"

#import "Reachability.h"


@implementation IPLWeatherAppViewController 

@synthesize weather;

- (BOOL)hasInternetConnection {
    Reachability* internetReach = [Reachability reachabilityForInternetConnection];
    NetworkStatus netStatus = [internetReach currentReachabilityStatus];
    if (netStatus == NotReachable)
    {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"No Connection available!", @"AlertView")
            message:NSLocalizedString(@"You have no connection available. Please connect to a network.", @"AlertView")
            delegate:self
            cancelButtonTitle:NSLocalizedString(@"Cancel", @"AlertView")
            otherButtonTitles:NSLocalizedString(@"Open settings", @"AlertView"), nil];

        [alertView show];
        return NO;
    }
    return YES;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"prefs:root=WIFI"]];
    }
}


#pragma mark - Actions
- (IBAction)getCurrentAirportWeather:(id)sender
{
    // End editing - remove keyboard
    [[self view] endEditing:YES];
  
    // Prepare WeatherDataLabel for new search results
    [weatherDataLabel setText: [NSString stringWithFormat:@" "]];
    
    // Make sure Airport Text Field has a valid Airport Code value
    // TO DO: Improve Usability by verifying against list of valid Airport codes
    // Get the entered airport code value
    NSString *airportcode = [airportCodeField text];
    
    if ([ airportcode isEqualToString:@""]) {
        // Airport code field should not be blank.        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter airport code." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil,nil];
        [alert show];
        
        // Stop Activity Indicator
        [activityIndicator stopAnimating];
        return;
        
    } else if ([airportcode length] != 3 ){
        // Airport code has to be four characters long.
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please enter valid airport code." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil,nil];
        [alert show];
        
        // Stop Activity Indicator
        [activityIndicator stopAnimating];
        return;
    }
    
    // We don't need keyboard anymore.
    [airportCodeField resignFirstResponder];
    
    [airportCodeField setText:[airportcode uppercaseString]];
    
    // Save last Searched on AirportCode 
    [weather setAirportCode:airportcode];
    [weather save];

 
    [self getCurrentAirportWeatherForValidAirportCode:airportcode];
}


- (void) getCurrentAirportWeatherForValidAirportCode:(NSString*)airportCode
{     
    // Turn Activity Indicator ON
    [activityIndicator startAnimating];
    
    // Get Weather Data from GEONames Webservice
    NSString *requestString = [NSString stringWithFormat:@"%@K%@",kGeonamesWeatherIcaoURLString,airportCode];
    NSURL *weatherWebServiceURL = [NSURL URLWithString:requestString];    
    
    // Start background thread to fetch data
    dispatch_async(kBgQueue, ^{
        NSData* data = [NSData dataWithContentsOfURL: 
                        weatherWebServiceURL];
        [self performSelectorInBackground:@selector(fetchedData:) withObject:data];     
    });
    
}


- (void)fetchedData:(NSData *)responseData {
    //Check if WIFI connected
    BOOL isConnected= [self hasInternetConnection];
    
    if (!isConnected) {
        // Stop Activity Indicator
        [activityIndicator stopAnimating];
        return;
    }
    
    //Parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization 
                          JSONObjectWithData:responseData 
                          options:kNilOptions 
                          error:&error];
    // Handle errors
    if (error != nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil,nil];
        [alert show];
        
        // Stop Activity Indicator
        [activityIndicator stopAnimating];
        return;
    }
    
    
   // Handle Messages from WebService 
    NSDictionary* status= [json objectForKey:@"status"];
    if ( [status count] > 0 ) {
       //NSLog(@"status: %@", status);
       NSString* message = [status objectForKey:@"message"]; 
       //NSLog(@"message: %@", message);
       UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message" message:
                             [message stringByAppendingString:@". Please check if Airport Code is Valid."] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil,nil];
       [alert show];
        
       // Stop Activity Indicator
       [activityIndicator stopAnimating];
       return;
    }

    //TO DO: Localize and Internationalize
    //TO DO: Display temperature in Celsius and Fahrenheit units
    //TO DO: Display Date in Localized Format
    //TO DO: Display Data in a Nice Table View
    NSDictionary* weatherObservation = [json objectForKey:@"weatherObservation"]; 
    //NSLog(@"weatherObservation: %@", weatherObservation);

    NSString* stationName = [NSString stringWithFormat:@"%@\n",[weatherObservation objectForKey:@"stationName"]]; 
    NSString* temperature = [NSString stringWithFormat:@"Temperature: %@\n", [weatherObservation objectForKey:@"temperature"]]; 
    NSString* clouds = [NSString stringWithFormat:@"Clouds: %@\n", [weatherObservation objectForKey:@"clouds"]]; 
    NSString* datetime = [NSString stringWithFormat:@"Date Time: %@\n", [weatherObservation objectForKey:@"datetime"]]; 
    NSString* dewPoint = [NSString stringWithFormat:@"Dew Point: %@\n", [weatherObservation objectForKey:@"dewPoint"]]; 
    NSString* elevation = [NSString stringWithFormat:@"Elevation: %@\n", [weatherObservation objectForKey:@"elevation"]]; 
    NSString* humidity = [NSString stringWithFormat:@"Humidity: %@\n", [weatherObservation objectForKey:@"humidity"]]; 
    NSString* lat = [NSString stringWithFormat:@"Latitude: %@\n", [weatherObservation objectForKey:@"lat"]]; 
    NSString* lng = [NSString stringWithFormat:@"Longitude: %@\n", [weatherObservation objectForKey:@"lng"]]; 
    NSString* seaLevelPressure = [NSString stringWithFormat:@"Sea Level Pressure: %@\n",[weatherObservation objectForKey:@"seaLevelPressure"]]; 
    NSString* windDirection = [NSString stringWithFormat:@"Wind Direction: %@\n",[weatherObservation objectForKey:@"windDirection"]]; 
    NSString* windSpeed = [NSString stringWithFormat:@"Wind Speed: %@\n",[weatherObservation objectForKey:@"windSpeed"]]; 
    NSString* observation = [NSString stringWithFormat:@"Observation: %@\n",[weatherObservation objectForKey:@"observation"]]; 
    
    
    NSString* weatherData = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@%@%@%@%@",stationName,temperature,clouds,datetime,dewPoint,elevation,humidity,lat,lng,seaLevelPressure,windDirection,windSpeed,observation]; 
    [weatherDataLabel setText:[[NSString alloc] initWithString:weatherData]];

    // Update Weather Object with the latest data
    [weather setWeatherData:weatherData];
    
    // Stop Activity Indicator
    [activityIndicator stopAnimating];

}


#pragma mark - View Control 
- (void)viewDidLoad
{
    [super viewDidLoad];

    // Create Model Object
    weather= [IPLWeather defaultWeather];
    
    // Set Airport Code from Model Object (from previous runs if applicable)
    NSString* airportCode= [weather airportCode];
    
    // Instruct User to Input Airport code to search on if field is empty
    if ([airportCode length] == 0 ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info" message:@"Please enter valid Airport Code to search on."   delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil,nil];
        [alert show];  
    } else {   
        // Get data for the saved airportcode
        [airportCodeField setText:[weather airportCode]];
        [self getCurrentAirportWeather:airportCode];
    }
    
    // Turn activity Indicator off
    [activityIndicator stopAnimating];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)x
{
    // Make App Auto Rotate
    return YES;
}

@end

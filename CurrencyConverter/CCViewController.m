//
//  CCViewController.m
//  CurrencyConverter
//
//  Created by Tyler Hedrick on 3/21/13.
//  Copyright (c) 2013 hedrick.tyler. All rights reserved.
//

#import "CCViewController.h"

@implementation CCViewController
@synthesize amount, currencyLabel, convertedLabel, currencyPickerView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self updateCurrenciesAndExchangeRates];
    }
    return self;
}

- (void)updateCurrenciesAndExchangeRates
{
    // Grab current currency conversion data from yahoo finance
    NSString *yahooCurrencies = @"http://finance.yahoo.com/webservice/v1/symbols/allcurrencies/quote?format=json";
    NSData *currencyData = [NSData dataWithContentsOfURL:[NSURL URLWithString:yahooCurrencies]];
    NSError *JSONError;
    NSDictionary *currencyDict = [NSJSONSerialization JSONObjectWithData:currencyData
                                                                 options:0
                                                                   error:&JSONError];
    // something went wrong getting the data from the web
    if (JSONError) {
        NSLog(@"Error parsing data %@", JSONError);
    } else {
        conversionDict = [NSMutableDictionary dictionary];
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setAllowsFloats:YES];
        for (NSDictionary *rate in [[currencyDict objectForKey:@"list"] objectForKey:@"resources"]) {
            NSDictionary *current = [[rate objectForKey:@"resource"] objectForKey:@"fields"];
            NSString *foreignCurrency = [[current objectForKey:@"symbol"] stringByReplacingOccurrencesOfString:@"=X"
                                                                                                    withString:@""];
            NSNumber *foreignRate = [formatter numberFromString:[current objectForKey:@"price"]];
            [conversionDict setObject:foreignRate forKey:foreignCurrency];
        }
        formatter = nil;
        currencies = [[conversionDict allKeys] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
    }
}

- (void)currencyConversionShouldChangeForRowInPickerView:(NSInteger)row
{
    // If we don't have any currencies (probably an error in the JSON parsing)
    // display an error to the user
    if (currencies == nil) {
        convertedLabel.text = @"Error. :(";
        return;
    }
    // grab the amount from the text field, convert it to a float, multiply
    // by the conversion rate at the specified row int he pickerView, and display
    // that result.
    float amt;
    if ([[amount text] isEqualToString:@""]) {
        // default to 0.00 if the user has not entered a number
        amt = 0;
    } else {
        amt = [[amount text] floatValue];
    }
    NSNumber *conversionRate = [conversionDict objectForKey:[currencies objectAtIndex:row]];
    float conversion = amt * [conversionRate floatValue];
    NSString *amountString = [NSString stringWithFormat:@"%.2f", conversion];
    NSString *displayString = [amountString stringByAppendingFormat:@" %@", [currencies objectAtIndex:row]];
    convertedLabel.text = displayString;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    // pick the currency to convert from USD to.
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [currencies count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [currencies objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self currencyConversionShouldChangeForRowInPickerView:row];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [amount resignFirstResponder];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self resignFirstResponder];
    return YES;
}

- (void)textFieldDidChange:(UITextField *)textField
{
    NSInteger currentRowInPickerView = [currencyPickerView selectedRowInComponent:0];
    [self currencyConversionShouldChangeForRowInPickerView:currentRowInPickerView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [amount addTarget:self
               action:@selector(textFieldDidChange:)
     forControlEvents:UIControlEventEditingChanged];
    [self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"grey_wash_wall.png"]]];
    [self currencyConversionShouldChangeForRowInPickerView:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

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
    NSString *yahooCurrencies = @"http://finance.yahoo.com/webservice/v1/symbols/allcurrencies/quote?format=json";
    NSData *currencyData = [NSData dataWithContentsOfURL:[NSURL URLWithString:yahooCurrencies]];
    NSError *JSONError;
    NSDictionary *currencyDict = [NSJSONSerialization JSONObjectWithData:currencyData
                                                                 options:0
                                                                   error:&JSONError];
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
    if (currencies == nil || [[amount text] isEqualToString:@""]) {
        convertedLabel.text = @"Please input an amount.";
        return;
    }
    float amt = [[amount text] floatValue];
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end

//
//  CCViewController.h
//  CurrencyConverter
//
//  Created by Tyler Hedrick on 3/21/13.
//  Copyright (c) 2013 hedrick.tyler. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCViewController : UIViewController
<UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate>
{
    NSArray *currencies;
    NSMutableDictionary *conversionDict;
}
@property (weak, nonatomic) IBOutlet UITextField *amount;
@property (weak, nonatomic) IBOutlet UILabel *currencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *convertedLabel;
@property (weak, nonatomic) IBOutlet UIPickerView *currencyPickerView;

@end

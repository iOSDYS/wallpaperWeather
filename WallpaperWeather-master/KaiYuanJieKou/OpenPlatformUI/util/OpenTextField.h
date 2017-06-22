//
//  myTextField.h
//  AdmoreSDKCore
//
//  Created by careyang on 2017/5/27.
//  Copyright © 2017年 wanglin.sun. All rights reserved.
//

#import <UIKit/UIKit.h>
@class OpenTextField;

@protocol OpenTextFieldDelegate <NSObject>
- (void)my_textFieldDeleteBackward:(OpenTextField *)textField;
@end

@interface OpenTextField : UITextField
@property (nonatomic, assign) id <OpenTextFieldDelegate> my_delegate;

@end

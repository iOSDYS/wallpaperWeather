//
//  myTextField.m
//  AdmoreSDKCore
//
//  Created by careyang on 2017/5/27.
//  Copyright © 2017年 wanglin.sun. All rights reserved.
//

#import "OpenTextField.h"

@implementation OpenTextField

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
- (void)deleteBackward {
    [super deleteBackward];
    if (self.my_delegate && [self.my_delegate respondsToSelector:@selector(my_textFieldDeleteBackward:)]) {
        [self.my_delegate my_textFieldDeleteBackward:self];
    }
}

@end

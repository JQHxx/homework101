//
//  DragImageView.h
//  Homework
//
//  Created by vision on 2019/10/31.
//  Copyright © 2019 vision. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DragImageView : UIImageView

-(void)setActionBlock:(void(^)(void))block;

@end


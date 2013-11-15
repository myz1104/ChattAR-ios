//
//  FacebookDialogsDataSource.h
//  ChattAR
//
//  Created by Igor Alefirenko on 12/11/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FacebookDialogsDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, strong) NSMutableDictionary *conversation;

@end

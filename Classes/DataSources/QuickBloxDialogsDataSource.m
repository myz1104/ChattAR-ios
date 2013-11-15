//
//  QuickBloxDialogsDataSource.m
//  ChattAR
//
//  Created by Igor Alefirenko on 11/11/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "QuickBloxDialogsDataSource.h"
#import "ChatRoomCell.h"

@implementation QuickBloxDialogsDataSource


#pragma mark -
#pragma mark Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *messages = [self.conversation objectForKey:kMessage];
    return [messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"QuickBloxCellIdentifier";
    
    QBChatMessage *message = [[self.conversation objectForKey:kMessage] objectAtIndex:indexPath.row];
    ChatRoomCell *cell = (ChatRoomCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[ChatRoomCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    [cell handleParametersForCellWithQBMessage:message andIndexPath:indexPath];
    return cell;
}

@end

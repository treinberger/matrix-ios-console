/*
 Copyright 2014 OpenMarket Ltd
 
 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at
 
 http://www.apache.org/licenses/LICENSE-2.0
 
 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.
 */

#import "RoomMemberTableCell.h"
#import "MatrixHandler.h"

@implementation RoomMemberTableCell

- (void)setRoomMember:(MXRoomMember *)roomMember withRoom:(MXRoom *)room {
    if (room && roomMember) {
        self.userLabel.text = [room memberName:roomMember.userId];
        self.placeholder = @"default-profile";
        self.pictureURL = roomMember.avatarUrl;
        
        // Shade invited users
        if (roomMember.membership == MXMembershipInvite) {
            for (UIView *view in self.subviews) {
                view.alpha = 0.3;
            }
        } else {
            for (UIView *view in self.subviews) {
                view.alpha = 1;
            }
        }
        
        // Customize banned and left (kicked) members
        if (roomMember.membership == MXMembershipLeave || roomMember.membership == MXMembershipBan) {
            self.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0];
            
            self.userPowerLevel.hidden = YES;
            
            self.lastActiveAgoLabel.backgroundColor = [UIColor lightGrayColor];
            self.lastActiveAgoLabel.text = (roomMember.membership == MXMembershipLeave) ? @"left" : @"banned";
        } else {
            self.backgroundColor = [UIColor whiteColor];
            
            // Handle power level display
             self.userPowerLevel.hidden = NO;
            NSDictionary *powerLevels = room.powerLevels;
            if (powerLevels) {
                int maxLevel = 0;
                for (NSString *powerLevel in powerLevels.allValues) {
                    int level = [powerLevel intValue];
                    if (level > maxLevel) {
                        maxLevel = level;
                    }
                }
                NSString *userPowerLevel = [powerLevels objectForKey:roomMember.userId]; // CAUTION: we invoke objectForKey here because user_id starts with an '@' character
                if (userPowerLevel == nil) {
                    userPowerLevel = [powerLevels valueForKey:@"default"];
                }
                float userPowerLevelFloat = 0.0;
                if (userPowerLevel) {
                    userPowerLevelFloat = [userPowerLevel floatValue];
                }
                self.userPowerLevel.progress = maxLevel ? userPowerLevelFloat / maxLevel : 1;
            } else {
                self.userPowerLevel.progress = 0;
            }
            
            if (roomMember.membership == MXMembershipInvite) {
                self.lastActiveAgoLabel.backgroundColor = [UIColor lightGrayColor];
                self.lastActiveAgoLabel.text = @"invited";
            } else {
                // TODO: handle last_active_ago duration when it will be available from SDK
                self.lastActiveAgoLabel.backgroundColor = [UIColor colorWithRed:0.2 green:0.9 blue:0.2 alpha:1.0];
                self.lastActiveAgoLabel.text = [NSString stringWithFormat:@"%lus ago", (unsigned long)roomMember.lastActiveAgo];
                self.lastActiveAgoLabel.numberOfLines = 0;
            }
        }
    }
}
@end
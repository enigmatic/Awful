//
//  AwfulUser.m
//  Awful
//
//  Created by Sean Berry on 11/21/10.
//  Copyright 2010 Regular Berry Software LLC. All rights reserved.
//

#import "AwfulUser.h"
#import "AwfulUserInfoRequest.h"
#import "AwfulNavController.h"
#import "AwfulUtil.h"

@implementation AwfulUser

@synthesize userName = _userName;
@synthesize postsPerPage = _postsPerPage;

-(id)init
{
    _postsPerPage = 40;
    return self;
}

-(void)dealloc
{
    [_userName release];
    [super dealloc];
}

-(void)loadUser
{
    // saved in UserInfo.plist
    NSString *path = [self getPath];
    if([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        [self setUserName:[dict objectForKey:@"userName"]];
        self.postsPerPage = [[dict objectForKey:@"postsPerPage"] intValue];
        //NSLog(@"Already Loaded: %@ %d", userName, postsPerPage);
    } else {
        AwfulUserNameRequest *name_req = [[AwfulUserNameRequest alloc] initWithAwfulUser:self];
        AwfulUserSettingsRequest *settings_req = [[AwfulUserSettingsRequest alloc] initWithAwfulUser:self];
        
        AwfulNavController *nav = getnav();
        [nav.queue addOperation:name_req];
        [nav.queue addOperation:settings_req];
        [nav.queue go];
        [name_req release];
        [settings_req release];
    }
}

-(void)setUserName:(NSString *)user_name
{
    if(user_name != _userName) {
        [_userName release];
        _userName = [user_name retain];
        [self saveUser];
    }
}

-(void)setPostsPerPage:(int)in_posts
{
    _postsPerPage = in_posts;
    [self saveUser];
}

-(NSString *)getPath
{
    return [[AwfulUtil getDocsDir] stringByAppendingPathComponent:@"awfulUser.plist"];
}

-(void)killUser
{
    NSError *err;
    BOOL woot = [[NSFileManager defaultManager] removeItemAtPath:[self getPath] error:&err];
    if(!woot) {
        NSLog(@"failed to kill %@", err);
    }
}

-(void)saveUser
{
    if(self.userName == nil) {
        return;
    }
    
    NSDictionary *dict = [NSDictionary dictionaryWithObjectsAndKeys:self.userName, @"userName", 
        [NSNumber numberWithInt:self.postsPerPage], @"postsPerPage", nil];
    [dict writeToFile:[self getPath] atomically:YES];
}

@end
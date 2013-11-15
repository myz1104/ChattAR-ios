//
//  DetailDialogsViewController.m
//  ChattAR
//
//  Created by Igor Alefirenko on 29/10/2013.
//  Copyright (c) 2013 Stefano Antonelli. All rights reserved.
//

#import "DetailDialogsViewController.h"
#import "ProfileViewController.h"
#import "QuickBloxDialogsDataSource.h"
#import "FacebookDialogsDataSource.h"
#import "ChatRoomCell.h"
#import "FBService.h"
#import "FBStorage.h"
#import "FBChatService.h"
#import "QBService.h"
#import "QBStorage.h"
#import "Utilites.h"
#import "AsyncImageView.h"

@interface DetailDialogsViewController () <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, QBActionStatusDelegate, QBChatDelegate>

@property (nonatomic, assign) NSNumber *friendPosition;
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UIView *inputTextView;
@property (strong, nonatomic) IBOutlet UITextField *inputMessageField;

// Data Sources:
@property (nonatomic, strong) FacebookDialogsDataSource *facebookDataSource;
@property (nonatomic, strong) QuickBloxDialogsDataSource *quickBloxDataSource;

- (IBAction)back:(id)sender;
- (IBAction)sendMessage:(id)sender;

@end

@implementation DetailDialogsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [QBChat instance].delegate = [QBService defaultService];
    [self configureInputTextViewLayer];
    
    self.title = [self.currentUser objectForKey:kName];
    
    NSString *avatarURL = [self.currentUser objectForKey:kPhoto];
    AsyncImageView *imgView = [[AsyncImageView alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    [imgView setImageURL:[NSURL URLWithString:avatarURL]];
    
    UIBarButtonItem *profile = [[UIBarButtonItem alloc] initWithTitle:@"lol" style:UIBarButtonItemStylePlain target:self action:@selector(viewProfilePage)];
    //profile.customView = imgView;
    
    self.navigationItem.rightBarButtonItem = profile;
    [self chooseKindOfChat];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    [self reloadTableView];
}

- (void)configureInputTextViewLayer
{
    self.inputTextView.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.inputTextView.layer.shadowRadius = 7.0f;
    self.inputTextView.layer.masksToBounds = NO;
    self.inputTextView.layer.shadowOffset = CGSizeMake(0.0f, 4.0f);
    self.inputTextView.layer.shadowOpacity = 1.0f;
    self.inputTextView.layer.borderWidth = 0.1f;
}

// activating chat:

- (void)chooseKindOfChat {
    if (_isFacebookChat) {
        [self activateFacebookChat];
    } else {
    [self activateQuickBloxChat];
    }
    // observing notificatins:
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveMessage) name:CAChatDidReceiveOrSendMessageNotification object:nil];
}

- (void)activateFacebookChat {
    _facebookDataSource = [[FacebookDialogsDataSource alloc] init];
    _facebookDataSource.conversation = _conversation;
    _tableView.dataSource = _facebookDataSource;
    [_tableView reloadData];
}

- (void)activateQuickBloxChat {
    _quickBloxDataSource = [[QuickBloxDialogsDataSource alloc] init];
    _quickBloxDataSource.conversation = _conversation;
    _tableView.dataSource = _quickBloxDataSource;
    [_tableView reloadData];
}


#pragma mark -
#pragma mark Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    ((ProfileViewController *)segue.destinationViewController).currentUser = self.currentUser;
}


#pragma mark -
#pragma mark Actions

- (IBAction)back:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)sendMessage:(id)sender {
    if ([self.inputMessageField.text length] == 0) {
        return;
    }
    NSString *friendID = [_currentUser objectForKey:kId];
    if (_isFacebookChat) {
        [[FBChatService defaultService] sendMessage:_inputMessageField.text toUserWithID:friendID];
    } else {
        NSUInteger userID = [[_currentUser objectForKey:kQuickbloxID] integerValue];
        [[QBService defaultService] sendMessage:_inputMessageField.text toUser:userID option:friendID];
    }
    
    self.inputMessageField.text = @"";
    [self.inputMessageField resignFirstResponder];
    
    [self reloadTableView];
}

- (void)receiveMessage {
    if (_isFacebookChat) {
        NSMutableDictionary *dict = [[FBChatService defaultService].allFriendsHistoryConversation objectForKey:[_currentUser objectForKey:kId]];
        _conversation = dict;
        _facebookDataSource.conversation = dict;
        [self reloadTableView];
        return;
    }
    NSLog(@"%@", [[QBStorage shared].allQuickBloxHistoryConversation allKeys]);
    NSMutableDictionary *dict = [[QBStorage shared].allQuickBloxHistoryConversation objectForKey:[_currentUser objectForKey:kId]];
    _conversation = dict;
    _quickBloxDataSource.conversation = dict;
    [self reloadTableView];
}

- (void)viewProfilePage {
    [self performSegueWithIdentifier:kDialogToProfileSegueIdentifier sender:nil];
}
//FB
- (void)reloadTableView {
    [self.tableView reloadData];
    if ([[[self.conversation objectForKey:kComments] objectForKey:kData] count] != 0) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:[[[self.conversation objectForKey:kComments] objectForKey:kData] count]-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}


#pragma mark -
#pragma mark Show/Hide Keyboard

- (void)showKeyboard {
    CGRect tableViewFrame = self.tableView.frame;
    CGRect inputPanelFrame = _inputTextView.frame;
    tableViewFrame.origin.y -= 215;
    inputPanelFrame.origin.y -= 215;
    //animation
    [UIView animateWithDuration:0.25f animations:^{
        [self.tableView setFrame:tableViewFrame];
        [_inputTextView setFrame:inputPanelFrame];
    }];
}

- (void)hideKeyboard {
    CGRect tableViewFrame = self.tableView.frame;
    CGRect inputPanelFrame = _inputTextView.frame;
    tableViewFrame.origin.y += 215;
    inputPanelFrame.origin.y += 215;
    //animation
    [UIView animateWithDuration:0.25f animations:^{
        [self.tableView setFrame:tableViewFrame];
        [_inputTextView setFrame:inputPanelFrame];
    }];
}


#pragma mark -
#pragma mark UITextField

- (IBAction)textEditDone:(id)sender {
    [sender resignFirstResponder];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [self showKeyboard];
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    [self hideKeyboard];
}


#pragma mark -
#pragma mark Table View Data Source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"NewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isFacebookChat) {
        NSMutableDictionary *message = [[[self.conversation objectForKey:kComments] objectForKey:kData] objectAtIndex:indexPath.row];
        NSString *messageText = [message objectForKey:kMessage];
        return [ChatRoomCell configureHeightForCellWithMessage:messageText];
    }
    QBChatMessage *message = [[self.conversation objectForKey:kMessage] objectAtIndex:indexPath.row];
    NSMutableDictionary *messageData = [[QBService defaultService] unarchiveMessageData:message.text];
    NSString *messageText = [messageData objectForKey:kMessage];
    return [ChatRoomCell configureHeightForCellWithMessage:messageText];
}


#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end

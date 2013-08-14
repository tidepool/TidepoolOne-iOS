//
//  TPProfileViewController.m
//  TidepoolOne
//
//  Created by Mayank Sanganeria on 8/6/13.
//  Copyright (c) 2013 Mayank Sanganeria. All rights reserved.
//

#import "TPProfileViewController.h"
#import "TPSettingsViewController.h"
#import "TPProfileViewHeader.h"
#import "TPOAuthClient.h"
#import <AttributedMarkdown/markdown_lib.h>
#import <AttributedMarkdown/markdown_peg.h>
#import "TPPolarChartView.h"
#import "TPProfileTableViewCell.h"

@interface TPProfileViewController ()
{
    TPOAuthClient *_oauthClient;
    UIImageView *_imageView;
}
@end

@implementation TPProfileViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedIn) name:@"Logged In" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loggedOut) name:@"Logged Out" object:nil];
    
    
    UINib *nib = [UINib nibWithNibName:@"TPProfileTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"TPProfileTableViewCell"];
    self.tableView.allowsSelection = NO;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _oauthClient = [TPOAuthClient sharedClient];
    [self loggedIn];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.title = @"My Profile";
    self.rightButton.target = self;
    self.rightButton.action = @selector(showSettings);
    
    
    _imageView = [[UIImageView alloc] init];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.tableView.backgroundView = _imageView;

    
    NSArray *nibItems = [[NSBundle mainBundle] loadNibNamed:@"TPProfileViewHeader" owner:nil options:nil];
    NSLog([nibItems description]);
    TPProfileViewHeader *profileHeaderView;
    for (id item in nibItems) {
        if ([item isKindOfClass:[TPProfileViewHeader class]]) {
            profileHeaderView = item;
        }
    }
    self.tableView.tableHeaderView = profileHeaderView;
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return !(!self.bulletPoints) + !(!self.paragraphs);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return self.bulletPoints.count;
        case 1:
            return self.paragraphs.count;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TPProfileTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TPProfileTableViewCell" forIndexPath:indexPath];
    // Configure the cell...
    switch (indexPath.section) {
        case 0: {
            cell.rightTextLabel.attributedText = [self parsedFromMarkdown:self.bulletPoints[indexPath.row]];
            cell.centerTextLabel.hidden = YES;
            cell.ribbonImageView.hidden = NO;
            cell.rightTextLabel.hidden = NO;
            return cell;
        }
            break;
        case 1: {
            cell.centerTextLabel.attributedText = [self parsedFromMarkdown:self.paragraphs[indexPath.row]];
            cell.centerTextLabel.hidden = NO;
            cell.ribbonImageView.hidden = YES;
            cell.rightTextLabel.hidden = YES;
            return cell;
        }
            break;
        default:
            break;
    }
    
    return nil;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *str;
    switch (indexPath.section) {
        case 0:{
            str = self.bulletPoints[indexPath.row];
            CGSize size = [str sizeWithFont:[UIFont fontWithName:@"Karla-Regular" size:16] constrainedToSize:CGSizeMake(self.tableView.bounds.size.width - 47, 999) lineBreakMode:NSLineBreakByWordWrapping];
            return size.height + 40;
        }
            break;
        case 1:{
            str = self.paragraphs[indexPath.row];
            CGSize size = [str sizeWithFont:[UIFont fontWithName:@"Karla-Regular" size:16] constrainedToSize:CGSizeMake(self.tableView.bounds.size.width - 20, 999) lineBreakMode:NSLineBreakByWordWrapping];
            return size.height + 40;
        }
            break;
        default:
            break;
    }
    return 0;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

-(void)showSettings
{
    TPSettingsViewController *settingsVC = [[TPSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:settingsVC animated:YES];
}

-(void)showProfileScreen
{
}

-(void)setPersonalityType:(NSDictionary *)personalityType
{
    _personalityType = personalityType;
    if (_personalityType) {
        TPProfileViewHeader *profileHeaderView = self.tableView.tableHeaderView;
        _imageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"bg-%@.jpg",_personalityType[@"profile_description"][@"display_id"]]];
        
        self.bulletPoints = _personalityType[@"profile_description"][@"bullet_description"];
        NSMutableArray *paragraphs = [[_personalityType[@"profile_description"][@"description"]  componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]] mutableCopy];
        [paragraphs removeObject:@""];
        self.paragraphs = paragraphs;
        
        profileHeaderView.nameLabel.text = _personalityType[@"profile_description"][@"name"];
        profileHeaderView.badgeImageView.image = [UIImage imageNamed:[NSString stringWithFormat:@"badge-%@.png",_personalityType[@"profile_description"][@"display_id"]]];
        profileHeaderView.personalityTypeLabel.text =  _personalityType[@"profile_description"][@"name"];
        profileHeaderView.blurbLabel.attributedText = [self parsedFromMarkdown:_personalityType[@"profile_description"][@"one_liner"]];
        TPPolarChartView *polarChartView = profileHeaderView.chartView;
        NSMutableArray *big5Values = [NSMutableArray array];
        NSArray *keys = @[@"openness",@"conscientiousness",@"extraversion",@"agreeableness",@"neuroticism",];
        for (NSString *key in keys) {
            [big5Values addObject:_personalityType[@"big5_score"][key]];
        }
        polarChartView.data = big5Values;
    }
    [self.tableView reloadData];
}

-(void)parseResponse:(NSDictionary *)response
{
    self.personalityType = response[@"data"][@"personality"];
}

-(NSAttributedString *)parsedFromMarkdown:(NSString *)rawText
{
    // start with a raw markdown string
//    rawText = @"Hello, world. *This* is native Markdown.";
    
    // create a font attribute for emphasized text
    UIFont *strongFont = [UIFont fontWithName:@"Karla-Bold" size:15.0];
    
    // create a color attribute for paragraph text
    UIColor *emColor = [UIColor colorWithRed:24/255.0 green:143/255.0 blue:244/255.0 alpha:1.0];
    
    // create a dictionary to hold your custom attributes for any Markdown types
    NSDictionary *attributes = @{
                                 @(STRONG): @{NSFontAttributeName : strongFont,},
                                 @(EMPH): @{NSForegroundColorAttributeName : emColor,}
                                 };    
    // parse the markdown
    NSAttributedString *prettyText = markdown_to_attr_string(rawText,0,attributes);
    
    return prettyText;
//    // assign it to a view object
//    myTextView.attributedText = prettyText;

}


-(void)loggedIn
{
    NSLog(@"called login");
    [_oauthClient getPath:@"api/v1/users/-/" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [self parseResponse:responseObject];
        NSLog([responseObject description]);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog([error description]);
    }];
}

-(void)loggedOut
{
    NSLog(@"called logout");    
    self.personalityType = nil;
}

@end
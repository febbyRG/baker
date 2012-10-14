//
//  ShelfViewController.m
//  Baker
//
//  ==========================================================================================
//
//  Copyright (c) 2010-2012, Davide Casali, Marco Colombo, Alessandro Morandi
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are
//  permitted provided that the following conditions are met:
//
//  Redistributions of source code must retain the above copyright notice, this list of
//  conditions and the following disclaimer.
//  Redistributions in binary form must reproduce the above copyright notice, this list of
//  conditions and the following disclaimer in the documentation and/or other materials
//  provided with the distribution.
//  Neither the name of the Baker Framework nor the names of its contributors may be used to
//  endorse or promote products derived from this software without specific prior written
//  permission.
//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY
//  EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
//  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT
//  SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
//  INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
//  PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
//  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
//  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "ShelfViewController.h"
#import "ShelfManager.h"
#import "UICustomNavigationBar.h"

#import "BakerViewController.h"
#import "IssueViewController.h"

@implementation ShelfViewController

@synthesize issues;
@synthesize issueViewControllers;

#pragma mark - Init

- (id)init
{
    self = [super init];
    if (self) {
        self.issues = [ShelfManager localBooksList];
    }
    return self;
}
- (id)initWithBooks:(NSArray *)currentBooks
{
    self = [super init];
    if (self) {
        self.issues = currentBooks;
        NSMutableArray *controllers = [NSMutableArray array];
        for (BakerIssue *issue in self.issues) {
            IssueViewController *controller = [[[IssueViewController alloc] initWithBakerIssue:issue] autorelease];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleReadIssue:) name:@"read_issue_request" object:controller];
            [controllers addObject:controller];
        }
        self.issueViewControllers = [NSArray arrayWithArray:controllers];
    }
    return self;
}

#pragma mark - Memory management

- (void)dealloc
{
    [issueViewControllers release];
    [issues release];
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.navigationItem.title = @"Baker Shelf";
    
    [self willRotateToInterfaceOrientation:self.interfaceOrientation duration:0];
    [self.gridView reloadData];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [self.navigationController.navigationBar setTranslucent:NO];
    
    for (IssueViewController *controller in self.issueViewControllers) {
        [controller refresh];
    }
}
- (NSInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}
- (BOOL)shouldAutorotate
{
    return YES;
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{    
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        //self.gridView.backgroundColor  = [UIColor colorWithPatternImage:[UIImage imageNamed:@"shelf-bg-portrait.png"]];
    } else if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        //self.gridView.backgroundColor  = [UIColor colorWithPatternImage:[UIImage imageNamed:@"shelf-bg-landscape.png"]];
    }
}

#pragma mark - Shelf data source

- (NSUInteger)numberOfItemsInGridView:(AQGridView *)aGridView
{
    return [issues count];
}
- (AQGridViewCell *)gridView:(AQGridView *)aGridView cellForItemAtIndex:(NSUInteger)index
{
    static NSString *cellIdentifier = @"cellIdentifier";

    AQGridViewCell *cell = (AQGridViewCell *)[self.gridView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (cell == nil)
	{
		cell = [[[AQGridViewCell alloc] initWithFrame:CGRectMake(0, 0, 384, 240) reuseIdentifier:cellIdentifier] autorelease];
		cell.selectionStyle = AQGridViewCellSelectionStyleNone;
                
        IssueViewController *controller = [self.issueViewControllers objectAtIndex:index];
        [cell.contentView addSubview:controller.view];
	}
    return cell;
}
- (CGSize)portraitGridCellSizeForGridView:(AQGridView *)aGridView
{
    return CGSizeMake(384, 240);
}

#pragma mark - Navigation management

- (void)gridView:(AQGridView *)gridView didSelectItemAtIndex:(NSUInteger)index
{
    [gridView deselectItemAtIndex:index animated:NO];
}
- (void)readIssue:(BakerIssue *)issue
{
    BakerBook *book = nil;
    NSString *status = [issue getStatus];

    #ifdef BAKER_NEWSSTAND
    if (status == @"downloaded") {
        book = [[[BakerBook alloc] initWithBookPath:issue.path bundled:NO] autorelease];
        [self pushViewControllerWithBook:book];
    }
    #else
    if (status == @"bundled") {
        book = [issue bakerBook];
        [self pushViewControllerWithBook:book];
    }
    #endif
}
- (void)handleReadIssue:(NSNotification *)notification
{
    IssueViewController *controller = notification.object;
    [self readIssue:controller.issue];
}
-(void)pushViewControllerWithBook:(BakerBook *)book
{
    BakerViewController *bakerViewController = [[BakerViewController alloc] initWithBook:book];
    [self.navigationController pushViewController:bakerViewController animated:YES];
    [bakerViewController release];
}

@end

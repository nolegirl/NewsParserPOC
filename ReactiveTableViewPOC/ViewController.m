//
//  ViewController.m
//  ReactiveTableViewPOC
//
//  Created by Mechelle Sieglitz on 12/15/15.
//  Copyright © 2015 Mechelle Sieglitz. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UITableViewDataSource, UITableViewDelegate, NSXMLParserDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@property (nonatomic, strong) NSArray *articleArray;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.backgroundColor = [UIColor clearColor];
    self.tableview.estimatedRowHeight = 40.0f;
    
    [self.view addSubview:self.tableview];
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.imageView setTag:100];
    
    [self startParsing];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource Methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return self.mutableXMLDataArray.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 250;
    } else {
        return 40;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    
    if (indexPath.section == 0) {
        cell.textLabel.text = @"";
        cell.detailTextLabel.text = @"";
        cell.backgroundColor = [UIColor clearColor];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.text = [[self.mutableXMLDataArray objectAtIndex:indexPath.row] valueForKey:@"title"];
        cell.detailTextLabel.text = [[self.mutableXMLDataArray objectAtIndex:indexPath.row] valueForKey:@"pubdate"];
    }
    return cell;
}

#pragma mark - UITableViewDelegate Methods

#pragma mark - NSXMLParserDelegate Methods
- (void)startParsing {
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithContentsOfURL:[NSURL URLWithString:@"http://news.google.com/?output=rss"]];
    [xmlParser setDelegate:self];
    [xmlParser parse];
    
    if (self.mutableXMLDataArray.count != 0) {
        [self.tableview reloadData];
    }
}
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict {
    if ([elementName isEqualToString:@"rss"]) {
        self.mutableXMLDataArray = [[NSMutableArray alloc] init];
    }
    if ([elementName isEqualToString:@"item"]) {
        self.mutableXMLDictionaryPart = [[NSMutableDictionary alloc] init];
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (!self.mutableXMLString) {
        self.mutableXMLString = [[NSMutableString alloc] initWithString:string];
    } else {
        [self.mutableXMLString appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName isEqualToString:@"title"] || [elementName isEqualToString:@"pubdate"]) {
        [self.mutableXMLDictionaryPart setObject:self.mutableXMLString forKey:elementName];
    }
    if ([elementName isEqualToString:@"item"]) {
        [self.mutableXMLDataArray addObject:self.mutableXMLDictionaryPart];
    }
    self.mutableXMLString = nil;
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    UIImageView *image = (UIImageView *)[self.view viewWithTag:100];
    CGFloat y = -scrollView.contentOffset.y;
    
    if (y > 0) {
        [image setFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.frame)+y*CGRectGetWidth(self.view.frame)/self.view.frame.size.height/2, y+self.view.frame.size.height/2)];
        [image setCenter:CGPointMake(self.view.center.x, image.center.y)];
        [self.imageView setAlpha:(1-y/100)];
    } if (y < 0) {
        [scrollView setFrame:CGRectMake(0,CGRectGetMinY(scrollView.frame), CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame))];
        [self startParsing];
    }
    
}


@end

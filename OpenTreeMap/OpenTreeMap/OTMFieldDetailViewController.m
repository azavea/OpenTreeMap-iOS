//
// Copyright (c) 2012 Azavea
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to
// deal in the Software without restriction, including without limitation the
// rights to use, copy, modify, merge, publish, distribute, sublicense, and/or
//  sell copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//  

#import "OTMFieldDetailViewController.h"
#import "OTMView.h"
#import "OTMFormatters.h"

@interface OTMFieldDetailViewController (Private)

- (NSString *)pendingValueAtIndex:(NSInteger)index;
- (NSString *)pendingEditDescriptionAtIndex:(NSInteger)index;

@end

@implementation OTMFieldDetailViewController

@synthesize data, fieldKey, ownerFieldKey, fieldName, fieldFormatString, choices;

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

    self.tableView.backgroundView = [[OTMView alloc] init];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationItem.title = self.fieldName;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        // The top section has a single cell with the current value
        return 1;
    } else {
        // The second section has a cell for each pending edit
        NSDictionary *pendingEditsDict = [self.data objectForKey:@"pending_edits"];
        if (pendingEditsDict) {
            NSDictionary *editsDict = [pendingEditsDict objectForKey:self.fieldKey];
            if (!editsDict) {
                editsDict = [pendingEditsDict objectForKey:self.ownerFieldKey];
            }
            return [[editsDict objectForKey:@"pending_edits"] count];
        } else {
            return 0;
        }
    }
}

- (NSString *)pendingValueAtIndex:(NSInteger)index
{
    bool thisFieldsValueIsControlledByAnotherField = NO;
    NSDictionary *editsDict = [[self.data objectForKey:@"pending_edits"] objectForKey:self.fieldKey];
    if (!editsDict) {
        editsDict = [[self.data objectForKey:@"pending_edits"] objectForKey:self.ownerFieldKey];
        thisFieldsValueIsControlledByAnotherField = YES;
    }

    NSDictionary *editDict = [[editsDict objectForKey:@"pending_edits"] objectAtIndex:index];
    NSString *rawValueString;
    if (thisFieldsValueIsControlledByAnotherField) {
        rawValueString = [[editDict objectForKey:@"related_fields"] objectForKey:self.fieldKey];
    } else {
        rawValueString = [editDict objectForKey:@"value"];
    }

    NSString *valueString;
    if (choices) {
        for(NSDictionary *choice in choices) {
            if ([rawValueString isEqualToString:[[choice objectForKey:@"key"] description]]) {
                valueString = [choice objectForKey:@"value"];
            }
        }
    } else {
        if (thisFieldsValueIsControlledByAnotherField) {
            valueString = rawValueString;
        } else {
            valueString = [OTMFormatters fmtObject:rawValueString withKey:fieldFormatString];
        }
    }
    return valueString;
}

- (NSString *)pendingEditDescriptionAtIndex:(NSInteger)index
{
    NSDictionary *editsDict = [[self.data objectForKey:@"pending_edits"] objectForKey:self.fieldKey];
    if (!editsDict) {
        editsDict = [[self.data objectForKey:@"pending_edits"] objectForKey:self.ownerFieldKey];
    }
    NSDictionary *editDict = [[editsDict objectForKey:@"pending_edits"] objectAtIndex:index];
    NSString *dateString = [OTMFormatters fmtOtmApiDateString:[editDict objectForKey:@"submitted"]];
    if (dateString) {
        return [NSString stringWithFormat:@"%@ on %@", [editDict objectForKey:@"username"], dateString];
    } else {
        return nil;
    }
}

#define kFieldDetailCurrentValueCellIdentifier @"kFieldDetailCurrentValueCellIdentifier"
#define kFieldDetailPendingEditCellIdentifier @"kFieldDetailPendingEditCellIdentifier"

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;

    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:kFieldDetailCurrentValueCellIdentifier];
        NSString *rawValueString = [[self.data decodeKey:self.fieldKey] description];
        NSString *valueString;
        if (choices) {
            for(NSDictionary *choice in choices) {
                if ([rawValueString isEqualToString:[[choice objectForKey:@"key"] description]]) {
                    valueString = [choice objectForKey:@"value"];
                }
            }
        } else {
            valueString = [OTMFormatters fmtObject:rawValueString withKey:fieldFormatString];
        }
        if (valueString && valueString != @"") {
            cell.textLabel.text = valueString;
        } else {
            cell.textLabel.text = @"No Value";
        }
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:kFieldDetailPendingEditCellIdentifier];
        cell.textLabel.text = [self pendingValueAtIndex:indexPath.row];
        cell.detailTextLabel.text = [self pendingEditDescriptionAtIndex:indexPath.row];
    }

    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(section == 0) {
        return @"Current Value";
    }
    else {
        return @"Pending Edits";
    }
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
 [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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

@end
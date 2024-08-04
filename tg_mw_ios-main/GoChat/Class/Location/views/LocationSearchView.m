//
//  SearchView.m
//  GoChat
//
//  Created by 李标 on 2021/6/4.
//

#import "LocationSearchView.h"

@interface LocationSearchView()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *tfSearch;

@end

@implementation LocationSearchView

- (void)awakeFromNib
{
    [super awakeFromNib];
//    [self.tfSearch addTarget:self action:@selector(textContentChanged:) forControlEvents:UIControlEventEditingChanged];
    self.tfSearch.returnKeyType = UIReturnKeySearch;
    self.tfSearch.delegate = self;
}

//- (IBAction)Cancel:(id)sender
//{
//    if([self.delegate respondsToSelector:@selector(SearchViewCancel)])
//    {
//        self.tfSearch.text = @"";
//        [self.tfSearch resignFirstResponder];
//        [self.delegate SearchViewCancel];
//    }
//}

- (void)doSearch:(NSString *)keyword
{
    if([self.delegate respondsToSelector:@selector(SearchViewDoSearch:)])
    {
        [self.delegate SearchViewDoSearch:keyword];
    }
}

#pragma mark - UITextFieldDelegate
//-(void)textContentChanged:(UITextField*)textFiled
//{
//    [self doSearch:textFiled.text];
//}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self doSearch:textField.text];
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if([self.delegate respondsToSelector:@selector(TextFieldBeginEditing:)])
    {
        [self.delegate TextFieldBeginEditing:textField];
    }
}

@end

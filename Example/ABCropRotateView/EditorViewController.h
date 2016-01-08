//
//  EditorViewController.h
//  ABCropRotateView
//
//  Created by Anton Bukov on 01.08.2016.
//

#import <UIKit/UIKit.h>

@protocol EditorViewControllerProtocol;

@interface EditorViewController : UIViewController

@property (weak, nonatomic) id<EditorViewControllerProtocol> delegate;
@property (strong, nonatomic) UIImage *image;

@end

//

@protocol EditorViewControllerProtocol <NSObject>

- (void)editorController:(EditorViewController *)controller didEditPhoto:(UIImage *)editedPhoto;

@end
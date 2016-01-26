//
//  ABViewController.m
//  ABCropRotateView
//
//  Created by Anton Bukov on 01.08.2016.
//

#import "EditorViewController.h"
#import "ViewController.h"

@interface ViewController () <EditorViewControllerProtocol, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

#pragma mark - Actions

- (IBAction)cameraTapped:(id)sender {
    UIImagePickerController *controller = [[UIImagePickerController alloc] init];
    controller.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    controller.delegate = self;
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - View

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

#pragma mark - Image Picker

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    EditorViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"vc_editor"];
    controller.delegate = self;
    controller.image = info[UIImagePickerControllerOriginalImage];
    [picker presentViewController:controller animated:YES completion:nil];
}

- (void)editorController:(EditorViewController *)controller didEditPhoto:(UIImage *)editedPhoto {
    self.imageView.image = editedPhoto;
    [controller.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    [controller.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end

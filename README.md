This is a iOS project for presenting views in iPad with a 3D effect to add depth.

Please see the example project include in this repo for an example of how to use this project.

Basic Example:

    self.topViewController = [[TopViewController alloc] initWithNibName:@"TopViewController" bundle:nil];
    UITapGestureRecognizer* tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    self.depthView = [[JFDepthView alloc] initWithGestureRecognizer:tapRec];
    self.depthView.delegate = self.topViewController = [[TopViewController alloc] initWithNibName:@"TopViewController" bundle:nil];
    UITapGestureRecognizer* tapRec = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    self.depthView = [[JFDepthView alloc] initWithGestureRecognizer:tapRec];
    self.depthView.delegate = self;
    
Delegate Methods:

    - (void)willPresentDepthView;
    - (void)didPresentDepthView;
    - (void)willDismissDepthView;
    - (void)didDismissDepthView;

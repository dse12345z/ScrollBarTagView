ScrollBarTagView
=============
![alt tag](http://i.imgur.com/fKq70uf.gif) 

Installation
=============

#### Common

copy ScrollBarTagView folder (ScrollBarTagView.h / ScrollBarTagView.m)

#### From CocoaPods

1.add the following line to your Podfile:

     pod 'ScrollBarTagView', '~> 0.0.1'

2.install ScrollBarTagView into your project:

     pod install

Usage
=============

1.create yourself tagView
 
2.- (void)viewDidAppear written under the code

    [ScrollBarTagView initWithScrollView:yourScrollView withTagView: ^UIView *{
        // custom your tagView
        return tagView;
    } didScroll: ^(id scrollBarTagView, id tagView, CGFloat offset) {
        // Scroll to change your tagView
    }];

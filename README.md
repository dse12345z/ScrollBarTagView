ScrollBarTagView
=============
![alt tag](http://i.imgur.com/i3YnNVi.gif)

Usage
=============
1.import ScrollBarTagView folder (ScrollBarTagView.h / ScrollBarTagView.m)

2.create yourself tagView

3.- (void)viewDidAppear written under the code

    [ScrollBarTagView initWithScrollView:yourScrollView withTagView: ^UIView *{
        // custom your tagView
        return tagView;
    } didScroll: ^(id tagView, id offset) {
        // Scroll to change your tagView
    }];

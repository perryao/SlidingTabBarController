# Description

In iOS, navigation is typically achieved through the use of a UITabBarController, or a reveal menu. However, the reveal menu pattern is known for some usability disadvantages, mainly the fact that users have no context as to where they are in the app. Also, the menu items are buried behind a hamburger icon, making it unlikely for users to ever make it to those pages.

The tab bar is great because it always shows the user where they are and where they can go, but it is limited to only 5 tabs. Any more than that, and an additional "More" tab is automatically created. While I generally lean towards the notion that your information architecture should be modified to fit within the 5 available tabs, I can definitely see the case where an app might have up to 5 very important screens, and a few others that are less important but still need to be there. 

Therefore, I have come up with the idea to merge the two patterns. SlidingTabBarController demonstrates how a tab bar might conceal additional menu items below it, which are accessible by dragging the tab bar upwards. This comes with the added benefit that all menu controls are located near the bottom of the screen, which is ideal for the larger screen sizes we have today.

###### Note
This is not production ready yet. I would like to get input and contributions from other developers in the iOS community to determine whether this even has a place on iOS. 


# Demo
![Demo Image](https://raw.githubusercontent.com/perryao/SlidingTabBarController/master/slidingTabBar.gif){:height="640px" width="360px"}


# Requirements
Xcode 7

### Special Thanks 

To @aloisbarreras for implementing the "rubber band" effect and
to the folks at objc.io for their article on Interactive UIKit Dynamics(http://www.objc.io/issues/12-animations/interactive-animations/)



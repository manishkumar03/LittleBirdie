# LittleBirdie

<h2 align="center">
  <img src="https://github.com/manishkumar03/LittleBirdie/blob/main/Resources/AppIconSource.jpg" width="224px"/><br/>
  A Minimalist Twitter Client for iOS
</h2>

## Overview
LittleBirdie is a minimalist Twitter client app for iOS written in Swift. I wrote this app to explore the usage of OAuth 1.0 and also to experiment with writing a modern networking stack for iOS. The accompanying [blog post](https://manishkumar03.github.io/2021/04/06/OAuth-flow-for-Twitter.html) explains the OAuth 1.0 flow in detail. 


## Features
- **OAuth 1.0:** No third-party libraries; implemented OAuth 1.0 from scratch, including the functions required to compute HMAC-SHA1 hash and derive OAuth signature etc.
- **Modern Networking Stack:** A neteworking stack based on generics. The usage of `APIRequest`, `APIResponse` and `RequestAdapter` makes the networking stack flexible and extensible.
- **MVVM Design Pattern:** Shows how to use MVVM the right way by using data binding so that any change in model automatically triggers the view refresh.
- **Insightful:** Copious amount of comments and an accompanying blog post describe the thought process behind the design choices.
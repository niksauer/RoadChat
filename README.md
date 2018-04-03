# RoadChat

<a href="https://app.swaggerhub.com/apis/niksauer/RoadChat/1.0.0">
    <img src="http://img.shields.io/badge/read_the-docs-92A8D1.svg" alt="Documentation">
</a>
<a href="license">
    <img src="http://img.shields.io/badge/license-MIT-brightgreen.svg" alt="MIT License">
</a>
<a href="https://swift.org">
    <img src="http://img.shields.io/badge/swift-4.0-brightgreen.svg" alt="Swift 4.0">
</a>

### Preview
<img src="https://github.com/niksauer/RoadChat/blob/beta/Docs/PreviewScreenshot.png" width="300">

### Setup 
1. `git clone <url>`
2. `git submodule update --init`

### Submodules
This project uses `git submodules` to manage dependencies (such as [RoadChatKit](https://github.com/niksauer/RoadChatKit)). Therefore, setup becomes a two-step process. To **update to** the **newest availble commit** from the tracked branch, run: `git submodule update --remote`.

Additionally, checkouts will happen in a `DETACHED-state`, i.e. any changes or updates pulled in, must be committed to its remote branch or this repository respectively in order to persist. For a full explanation, please read [ActiveState](https://www.activestate.com/blog/2014/05/getting-git-submodule-track-branch) and/or [StackOverflow](https://stackoverflow.com/questions/18770545/why-is-my-git-submodule-head-detached-from-master).

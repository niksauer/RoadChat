# RoadChat

<a href="https://app.swaggerhub.com/apis/niksauer/RoadChat/1.0.0">
    <img src="http://img.shields.io/badge/read_the-docs-92A8D1.svg" alt="Documentation">
</a>
<a href="license">
    <img src="http://img.shields.io/badge/license-AGPLv3-brightgreen.svg" alt="MIT License">
</a>
<a href="https://swift.org">
    <img src="http://img.shields.io/badge/swift-4.1-brightgreen.svg" alt="Swift 4.0">
</a>

### Preview
<img src="https://github.com/niksauer/RoadChat/blob/beta/Docs/PreviewScreenshot.png">

### Setup 
1. `git clone <url>`
2. `git submodule update --recursive --init`

### Dependencies
- [ColorCircle](https://github.com/niksauer/ColorCircle)
- [Locksmith](https://github.com/matthewpalmer/Locksmith)
- [Parchment](https://github.com/rechsteiner/Parchment)
- [RoadChatKit](https://github.com/niksauer/RoadChatKit)
- [SwiftyBeaver](https://github.com/SwiftyBeaver/SwiftyBeaver)

### Submodules
This project uses `git submodules` to manage its dependencies. Therefore, setup becomes a two-step process. To **update to** the **newest availble commit** from the tracked branch of each submodule, run: `git submodule update --recursive --remote`.

Additionally, checkouts will happen in a `DETACHED-state`, i.e. any changes or updates pulled in, must be committed to its remote branch or this repository respectively in order to persist. For a full explanation, please read [ActiveState](https://www.activestate.com/blog/2014/05/getting-git-submodule-track-branch) and/or [StackOverflow](https://stackoverflow.com/questions/18770545/why-is-my-git-submodule-head-detached-from-master).

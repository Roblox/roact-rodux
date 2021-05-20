# RoactRodux Changelog

## Unreleased
* Switch to Roact's better-supported `createContext` feature [#38](https://github.com/roblox/roact-rodux/pulls/38)
* As a consequence of the above, remove `UNSTABLE_getStore` API

## 0.2.2 (2020-05-14)
* Changed order of connection to store so that Parent components are connected to the store before their children.
	* This should resolve some issues with components receiving bad combinations of props and store state.

## 0.2.1 (2020-03-20)
* Update to latest Rotriever manifest format.

## 0.2.0 (2019-10-24)
* Initial release.
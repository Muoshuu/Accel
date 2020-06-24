# Accel
A comprehensive redesign of the Roblox API built around asynchronicity, inspired by JavaScript.

## Features
- Built entirely around Promises.
- Standard case throughout the entire source.
- No deprecated features included.
- Import modules from relative paths.

## Documentation
- Promise documentation can be found [here](https://eryn.io/roblox-lua-promise/lib/).
- BigNum documentation can be found [here](https://rostrap.github.io/Libraries/Math/BigNum).

Documentation for this library has not been completed but a link will be available here when it is.

## Libraries

#### Class
A built-in class library that has been designed to be as versatile as possible. Supports custom metamethods, getters, setters, and is based on JavaScript prototypes.

#### Console
Similar to JavaScript's `console` library, this library contains functions for debugging. Primarily useful for quickly formatting output.<br>

#### Color
Extends Roblox's Color3 library. Includes functions for conversion between Roblox's Color3, RGB, HSV, Hex, and Integer.

#### Create
A simple function designed to streamline Roblox instance creation. Designed similarly to Roblox's `RbxUtility.Create` without [the accompanying performance issue](https://devforum.roblox.com/t/psa-dont-use-instance-new-with-parent-argument/30296). It also includes `Create.folder` and `Create.value` to quickly create folders and value objects.

#### LZW
A text compression library. NetworkService's integration of MessagingService uses this library to automatically compress and chunk data sent to other servers.

#### Math
An extension of Roblox's standard math library. Currently only includes Euler's number as a constant and `math.round`.

#### String
Extends Roblox's standard string library. Includes functions for generating unique identifiers, trimming whitespace, reversing utf8, and getting the pixel width of a string or character based on font and font size.

#### Table
Extends Roblox's standard table library. Designed around JavaScript's Array and Object prototypes, it includes several useful functions for modifying tables in place or otherwise.

#### Vector
Extends Roblox's Vector2 & Vector3 libraries. Includes functions for conversion between cartesian and spherical coordinates and unpacking vectors.

## Condensed Services
This library condenses multiple Roblox services into single ones.<br>
Here is a list of services this library includes and what Roblox services they are based on:

#### AssetService
- MarketplaceService
- InsertService
- AssetService

#### GameService
- AssetService
- DataModel

#### NetworkService
###### Also includes client/server networking.
- DataStoreService
- HttpService
- MessagingService

#### PlayerService
- Players
- BadgeService
- SocialService
- GroupService
- LocalizationService
- Chat

#### InterfaceService
- GuiService
- StarterGui
- HapticService
- ContextActionService
- UserInputService
- LocalizationService
- VRService

#### RuntimeService
- RunService

#### UtilityService
- CollectionService
- TextService
- TweenService
- PhysicsService
- PathfindingService

#### WorldService
- Workspace
- Lighting
- SoundService

# Attribution
- [evaera](https://github.com/evaera) for [roblox-promise-lua]()
- [1waffle1](https://devforum.roblox.com/u/1waffle1) for [LZW.lua](https://devforum.roblox.com/t/text-compression/163637)
- [Validark](https://github.com/Validark) for [BigNum.lua](https://raw.githubusercontent.com/RoStrap/Math/master/BigNum.lua)
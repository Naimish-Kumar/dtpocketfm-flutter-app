# dtpocketfm

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


## Player changes for Web & Other OS for extended

#For [Web] :
    - changes in pubspec.yaml dependencies :
        => enable pod_player library
        => disable better_player library
    - enable PodPlayer 
    - disable other players like Better, Vimeo & Youtube
    - disable [player_better.dart] file code related to Better Player
    - enable [player_pod.dart] file code related to Better Player

#For [Other] :
    - changes in pubspec.yaml dependencies :
        => disable pod_player library
        => enable better_player library
    - disable PodPlayer 
    - enable other players like Better, Vimeo & Youtube
    - enable [player_better.dart] file code related to Better Player
    - disable [player_pod.dart] file code related to Better Player

Make above Player related changes (For [Web] or [Other]) in following files :
    - [moviedetails.dart] (in openPlayer function)
    - [tvshowdetails.dart] (in openPlayer function)
    - [episodebyseason.dart] (in openPlayer function)
    - [channels.dart] (in openPlayer function)
    - [utils.dart] (in openPlayer function)
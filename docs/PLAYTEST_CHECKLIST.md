# Playtest Checklist

Use this checklist to validate the MVP after each build.

## Basic Flow
- [ ] Game launches without errors
- [ ] Main menu appears with title "Trash Panda Tycoon"
- [ ] New Game button works
- [ ] Continue button is disabled if no save exists
- [ ] Continue button works if save exists
- [ ] Reset Save works with confirmation prompt

## Gameplay
- [ ] Items spawn on the conveyor belt
- [ ] Items can be dragged with mouse
- [ ] Items snap back if not dropped on a bin
- [ ] Dropping a correct item on the matching bin gives coins
- [ ] Dropping a wrong item on a bin increases mess meter
- [ ] Items that fall off the bottom increase mess meter
- [ ] 30-second round timer counts down
- [ ] Round ends when timer expires
- [ ] Round ends early when mess meter fills
- [ ] Feedback text appears on correct/wrong sort

## Results Screen
- [ ] Results screen shows after round ends
- [ ] Coins earned are displayed
- [ ] Correct sorts count is displayed
- [ ] Wrong sorts count is displayed
- [ ] Missed items count is displayed
- [ ] Total coins are displayed
- [ ] Next Round button starts a new round
- [ ] Upgrade button opens upgrade screen

## Upgrades
- [ ] Upgrade screen shows 4 upgrades
- [ ] Each upgrade shows name, description, level, cost
- [ ] Buying an upgrade reduces coin total
- [ ] Trash Value upgrade increases coins per sort
- [ ] Spawn Rate upgrade makes items appear faster
- [ ] Mess Capacity upgrade increases max mess
- [ ] Maxed upgrade shows "MAXED" and is disabled
- [ ] Upgrade costs increase per level
- [ ] Back button returns to results screen

## Save / Load
- [ ] Coins persist after closing and reopening the game
- [ ] Upgrade levels persist after closing and reopening
- [ ] Best round score persists
- [ ] Reset Save clears all progress

## Platform Stubs
- [ ] "Watch Ad x2" button works and doubles earnings
- [ ] Doubled amount matches the tooltip
- [ ] Console shows [FakeAds] log messages
- [ ] Console shows [FakeIAP] log messages if applicable

## Structural
- [ ] No C# files in the project
- [ ] No Mono dependencies
- [ ] All scripts are typed GDScript
- [ ] project.godot has `dotnet/enabled=false`
- [ ] No real SDKs or plugins
- [ ] Portrait 720x1280 resolution
- [ ] All scenes load without errors

## Notes for Testing
- Run from Godot editor (F5)
- Check Output panel for errors and log messages
- Check Debugger panel for script errors
- Test on windowed mode at 720x1280

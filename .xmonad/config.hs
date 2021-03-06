------------------------------------------------------------------------
---IMPORTS
------------------------------------------------------------------------
-- Base

-- import Control.Monad ((>=>), join, liftM, when)   -- For Custom Fullscreen Function
-- import System.Environment (setEnv)

-- Data

-- import Data.Maybe (isJust, maybeToList)
import Data.List
import qualified Data.Map as M
import Data.Monoid
import System.Exit (exitSuccess)
import System.FilePath ((</>))
import System.IO (hPutStrLn)
import XMonad
-- Utilities
-- import XMonad.Util.Loggers

-- Hooks

-- required for xcomposite in obs to work

-- Actions

import XMonad.Actions.CopyWindow (copy, copyToAll, kill1, killAllOtherCopies, wsContainingCopies)
import XMonad.Actions.CycleWS (WSType (EmptyWS, HiddenNonEmptyWS), findWorkspace, moveTo, shiftTo, toggleWS')
import XMonad.Actions.DynamicWorkspaces (withNthWorkspace)
import XMonad.Actions.FloatKeys
import XMonad.Actions.Minimize (minimizeWindow)
import XMonad.Actions.Promote
import XMonad.Actions.RotSlaves (rotAllDown, rotAllUp)
import qualified XMonad.Actions.Search as S
import XMonad.Actions.WindowGo (raiseMaybe, runOrRaise)
import XMonad.Actions.WithAll (killAll, sinkAll)
import XMonad.Hooks.DynamicLog (PP (..), dynamicLogWithPP, shorten, wrap, xmobarColor, xmobarPP)
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.FadeInactive
-- Layouts

-- Layouts modifiers

import XMonad.Hooks.InsertPosition
import XMonad.Hooks.ManageDocks (ToggleStruts (..), avoidStruts, docksEventHook, manageDocks)
import XMonad.Hooks.ManageHelpers (doCenterFloat, doFullFloat, doRectFloat, isDialog)
import XMonad.Layout.LayoutModifier
import XMonad.Layout.LimitWindows (limitWindows)
import XMonad.Layout.MultiToggle ((??), EOT (EOT), Toggle (..), mkToggle, single)
import XMonad.Layout.MultiToggle.Instances (StdTransformers (MIRROR, NBFULL, NOBORDERS))
import XMonad.Layout.NoBorders
import XMonad.Layout.OneBig
import XMonad.Layout.Reflect (REFLECTX (..), REFLECTY (..), reflectHoriz, reflectVert)
import XMonad.Layout.Renamed (Rename (CutWordsLeft, Replace), renamed)
import XMonad.Layout.ResizableTile
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Spacing
import XMonad.Layout.Tabbed (simpleTabbed, addTabsAlways, inactiveBorderColor, activeTextColor, tabbed, shrinkText)
import XMonad.Layout.WindowArranger (WindowArrangerMsg (..), windowArrange)
--     -- Prompt
import XMonad.Prompt
-- import XMonad.Prompt.Input
-- import XMonad.Prompt.FuzzyMatch
-- import XMonad.Prompt.Man
-- import XMonad.Prompt.Shell (shellPrompt)
-- import XMonad.Prompt.Ssh
-- import XMonad.Prompt.XMonad
import XMonad.Prompt.Window
import qualified XMonad.StackSet as W
import XMonad.Util.EZConfig (additionalKeysP)
import XMonad.Util.NamedScratchpad
import XMonad.Util.Run (spawnPipe)
import XMonad.Util.SpawnOnce
import XMonad.Util.WorkspaceCompare (getSortByIndex)

-- import Control.Arrow (first)

------------------------------------------------------------------------
---VARIABLES
------------------------------------------------------------------------
-- myFont :: String
-- myFont = "xft:Iosevka Nerd Font:bold:size=10"

myHome :: String
myHome = "/home/shaurya/"

myModMask :: KeyMask
myModMask = mod4Mask -- Sets modkey to super/windows key

myTerminal :: String
myTerminal = "kitty " -- Sets default terminal

myBrowser :: String
myBrowser = "chromium "                  -- Sets firefox as browser for tree select

myEditor :: String
myEditor = myTerminal ++ " -e nvim " -- Sets vim as editor for tree select

myBorderWidth :: Dimension
myBorderWidth = 3 -- Sets border width for windows

myNormColor :: String
myNormColor = "#1d2021" -- Border color of normal windows

myFocusColor :: String
myFocusColor = "#458588" -- Border color of focused windows

-- altMask :: KeyMask
-- altMask = mod1Mask                      -- Setting this for use in xprompts

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset -- Getting no. of windows on current workspace

------------------------------------------------------------------------
---XPROMPT SETTINGS
------------------------------------------------------------------------
-- sXPConfig :: XPConfig
-- sXPConfig = def
--       { font                = myFont
--       , bgColor             = "#1d2021"
--       , fgColor             = "#ebdbb2"
--       , bgHLight            = "#fabd2f"
--       , fgHLight            = "#1d2021"
--       , borderColor         = "#535974"
--       , promptBorderWidth   = 0
--       , promptKeymap        = sXPKeymap
--       , position            = Top
-- --    , position            = CenteredAt { xpCenterY = 0.3, xpWidth = 0.3 }
--       , height              = 20
--       , historySize         = 256
--       , historyFilter       = id
--       , defaultText         = []
--       , autoComplete        = Nothing  -- set Just 100000 for .1 sec
--       , showCompletionOnTab = False
--       -- , searchPredicate     = isPrefixOf
--       , searchPredicate     = fuzzyMatch
--       , alwaysHighlight     = True
--       , maxComplRows        = Just 15      -- set to Just 5 for 5 rows
--       }
--
-- -- The same config above minus the autocomplete feature which is annoying
-- -- on certain Xprompts, like the search engine prompts.
-- sXPConfig' :: XPConfig
-- sXPConfig' = sXPConfig
--       { autoComplete        = Nothing
--       }
--
-- -- A list of all of the standard Xmonad prompts and a key press assigned to them.
-- -- These are used in conjunction with keybinding I set later in the config.
-- promptList :: [(String, XPConfig -> X ())]
-- promptList = [ ("m", manPrompt)          -- manpages prompt
--              , ("r", shellPrompt)        -- run an application
--              , ("s", sshPrompt)          -- ssh prompt
--              , ("x", xmonadPrompt)       -- xmonad prompt
--              ]
--
-- -- Adding a list for windowPrompt with my preferred options.
-- windowPromptList = [ ("b", Bring)
--                    , ("g", Goto )
--                    , ("c", BringCopy)
--                    , ("m", BringToMaster)
--                    ]
--
-- ------------------------------------------------------------------------
-- ---XPROMPT KEYMAP (emacs-like key bindings for xprompts)
-- ------------------------------------------------------------------------
-- sXPKeymap :: M.Map (KeyMask,KeySym) (XP ())
-- sXPKeymap = M.fromList $
--      map (first $ (,) controlMask)   -- control + <key>
--      [ (xK_z, killBefore)            -- kill line backwards
--      , (xK_k, killAfter)             -- kill line forwards
--      , (xK_a, startOfLine)           -- move to the beginning of the line
--      , (xK_e, endOfLine)             -- move to the end of the line
--      , (xK_m, deleteString Next)     -- delete a character foward
--      , (xK_b, moveCursor Prev)       -- move cursor forward
--      , (xK_f, moveCursor Next)       -- move cursor backward
--      , (xK_BackSpace, killWord Prev) -- kill the previous word
--      , (xK_y, pasteString)           -- paste a string
--      , (xK_g, quit)                  -- quit out of prompt
--      , (xK_bracketleft, quit)
--      ]
--      ++
--      map (first $ (,) altMask)       -- meta key + <key>
--      [ (xK_BackSpace, killWord Prev) -- kill the prev word
--      , (xK_f, moveWord Next)         -- move a word forward
--      , (xK_b, moveWord Prev)         -- move a word backward
--      , (xK_d, killWord Next)         -- kill the next word
--      , (xK_n, moveHistory W.focusUp')   -- move up thru history
--      , (xK_p, moveHistory W.focusDown') -- move down thru history
--      ]
--      ++
--      map (first $ (,) 0) -- <key>
--      [ (xK_Return, setSuccess True >> setDone True)
--      , (xK_KP_Enter, setSuccess True >> setDone True)
--      , (xK_BackSpace, deleteString Prev)
--      , (xK_Delete, deleteString Next)
--      , (xK_Left, moveCursor Prev)
--      , (xK_Right, moveCursor Next)
--      , (xK_Home, startOfLine)
--      , (xK_End, endOfLine)
--      , (xK_Down, moveHistory W.focusUp')
--      , (xK_Up, moveHistory W.focusDown')
--      , (xK_Escape, quit)
--      ]

------------------------------------------------------------------------
---SEARCH ENGINES
------------------------------------------------------------------------
-- Adding custom search engines.
-- archwiki, reddit :: S.SearchEngine
--
-- archwiki = S.searchEngine "archwiki" "https://wiki.archlinux.org/index.php?search="
-- reddit   = S.searchEngine "reddit" "https://www.reddit.com/search/?q="
--
-- -- Search engines to use.
-- searchList :: [(String, S.SearchEngine)]
-- searchList = [ ("a", archwiki)
--              , ("d", S.duckduckgo)
--              , ("g", S.google)
--              , ("h", S.hoogle)
--              , ("i", S.images)
--              , ("r", reddit)
--              , ("s", S.stackage)
--              , ("t", S.thesaurus)
--              , ("v", S.vocabulary)
--              , ("w", S.wikipedia)
--              , ("y", S.youtube)
--              , ("z", S.amazon)
--              ]

------------------------------------------------------------------------
---SCRATCHPADS
------------------------------------------------------------------------
-- Allows to have several floating scratchpads running different applications.
-- Import Util.NamedScratchpad.  Bind a key to namedScratchpadSpawnAction.
myScratchPads :: [NamedScratchpad]
myScratchPads =
  -- [ NS "terminal" spawnTerm findTerm manageTerm                               -- Terminal
  [ NS "pulse" spawnPulse findPulse managePulse -- Pavucontrol
      -- , NS "calculator" spawnCalculator findCalculator manageCalculator           -- Calculator
  ]
  where
    -- spawnTerm  = myTerminal ++ " -n scratchpad"
    -- findTerm   = resource =? "scratchpad"
    -- manageTerm = customFloating $ W.RationalRect l t w h
    --            where
    --              h = 0.95
    --              w = 0.95
    --              t = 0.98 -h
    --              l = 0.975 -w

    spawnPulse = "pavucontrol"
    findPulse = resource =? "pavucontrol"
    managePulse = customFloating $ W.RationalRect l t w h
      where
        h = 0.9
        w = 0.9
        t = 0.95 - h
        l = 0.95 - w

-- spawnCalculator  = "qalculate-gtk"
-- findCalculator   = resource =? "qalculate-gtk"
-- manageCalculator = customFloating $ W.RationalRect l t w h
--            where
--              h = 0.9
--              w = 0.9
--              t = 0.95 -h
--              l = 0.95 -w

------------------------------------------------------------------------
---WORKSPACES
------------------------------------------------------------------------
-- xmobarEscape :: String -> String
-- xmobarEscape = concatMap doubleLts
--   where
--     doubleLts '<' = "<<"
--     doubleLts x = [x]

myWorkspaces :: [String]
myWorkspaces = ["web", "code", "term", "read", "chat", "watch", "7", "8", "9"]

------------------------------------------------------------------------
---WINDOW RULES
------------------------------------------------------------------------
-- Android Studio Fix
(~=?) :: Eq a => Query [a] -> [a] -> Query Bool
q ~=? x = fmap (isInfixOf x) q

-- Do not treat menus and settings popup as a separate window.
manageIdeaCompletionWindow = (className =? "jetbrains-studio") <&&> (title ~=? "win") --> doIgnore

-- My Window Rules
myManageHook :: Query (Data.Monoid.Endo WindowSet)
myManageHook =
  (isDialog --> doF W.swapUp) -- Bring Dialog Window on Top of Parent Floating Window
    <+> insertPosition Below Newer -- Insert New Windows at the Bottom of Stack Area
      -- <+> namedScratchpadManageHook myScratchPads       -- Adding Rules for Named Scratchpads
    <+> manageIdeaCompletionWindow -- Adding Fix for Android Studio
    <+> composeAll
      [ (className =? "firefox" <&&> title =? "Library") --> doCenterFloat, -- Float Firefox Downloads Window to Centre
          -- , stringProperty "_NET_WM_NAME" =? "Emulator" --> doCenterFloat                                  -- Float Android Emulator to Centre
        (className =? "Lxappearance") --> doCenterFloat, -- Float Lxappearance to Centre
        isDialog --> doCenterFloat -- Float Dialog Windows to Centre
      ]

------------------------------------------------------------------------
---AUTOSTART
------------------------------------------------------------------------
-- Firefox Fullscreen Support
setFullscreenSupport :: X ()
setFullscreenSupport = withDisplay $ \dpy -> do
  r <- asks theRoot
  a <- getAtom "_NET_SUPPORTED"
  c <- getAtom "ATOM"
  supp <-
    mapM
      getAtom
      [ "_NET_WM_STATE_HIDDEN",
        "_NET_WM_STATE_FULLSCREEN",
        "_NET_NUMBER_OF_DESKTOPS",
        "_NET_CLIENT_LIST",
        "_NET_CLIENT_LIST_STACKING",
        "_NET_CURRENT_DESKTOP",
        "_NET_DESKTOP_NAMES",
        "_NET_ACTIVE_WINDOW",
        "_NET_WM_DESKTOP",
        "_NET_WM_STRUT"
      ]
  io $ changeProperty32 dpy r a c propModeReplace (fmap fromIntegral supp)

-- My Startup Applications
myStartupHook :: X ()
myStartupHook = do
  mapM_
    spawnOnce
    [ "stalonetray",
      "feh --bg-scale /home/shaurya/Desktop/wallpaper.png",
      "nm-applet",
      "blueman-applet",
      "synclient TapButton1=1",
      "xset r rate 300 30",
      "setxkbmap -option ctrl:nocaps",
      "xfce4-clipman",
      "dunst",
      myHome </> "scripts/discharging.sh",
      "xset dpms 0 0 3600"
    ]
  setFullscreenSupport -- Adding Firefox Fullscreen Support

------------------------------------------------------------------------
---LAYOUTS
------------------------------------------------------------------------
-- Below implementation makes it easier to use spacingRaw module to set required spacing just by changing the value of i.
mySpacing :: Integer -> l a -> XMonad.Layout.LayoutModifier.ModifiedLayout Spacing l a
mySpacing i = spacingRaw True (Border i i i i) False (Border i i i i) True

myLayoutHook =
  avoidStruts
    $ windowArrange
    $ mkToggle (NBFULL ?? NOBORDERS ?? EOT)
    $ myDefaultLayout
  where
    myDefaultLayout = smartBorders tall ||| noBorders full

tall =
  renamed [Replace "tall"]
    $ mySpacing 3
    $ ResizableTall 1 (3 / 100) (1 / 2) []

full =
  renamed [Replace "full"]
    $ limitWindows 20
    $ Full

------------------------------------------------------------------------
---INACTIVE WINDOW TRANSPARENCY
------------------------------------------------------------------------
myLogHook :: X ()
myLogHook = fadeInactiveLogHook fadeAmount
  where
    fadeAmount = 0.95

------------------------------------------------------------------------
---KEYBINDINGS
------------------------------------------------------------------------
-- Function to toggle floating state on focused window.
toggleFloat w =
  windows
    ( \s ->
        if M.member w (W.floating s)
          then W.sink w s
          else (W.float w (W.RationalRect (1 / 6) (1 / 6) (2 / 3) (2 / 3)) s)
    )

-- Skipping NSP workspace
getSortByIndexNoSP =
  fmap (. namedScratchpadFilterOutWorkspace) getSortByIndex

-- Function to move to next non-empty WS skipping NSP.
nextNonEmptyWS = findWorkspace getSortByIndexNoSP Next HiddenNonEmptyWS 1
  >>= \t -> (windows . W.view $ t)

-- Function to move to previous non-empty WS skipping NSP.
prevNonEmptyWS = findWorkspace getSortByIndexNoSP Prev HiddenNonEmptyWS 1
  >>= \t -> (windows . W.view $ t)

-- Function to move focused  window to next empty WS skipping NSP and move to that WS.
shiftToNextEmptyWS = findWorkspace getSortByIndexNoSP Next EmptyWS 1
  >>= \t -> (windows . W.shift $ t) >> (windows . W.greedyView $ t)

-- Function to move focused window to previous empty WS skipping NSP and move to that WS.
shiftToPrevEmptyWS = findWorkspace getSortByIndexNoSP Prev EmptyWS 1
  >>= \t -> (windows . W.shift $ t) >> (windows . W.greedyView $ t)

-- Function toggle copy of a window on all other WS.
toggleCopyToAll = wsContainingCopies >>= \ws -> case ws of
  [] -> windows copyToAll
  _ -> killAllOtherCopies

-- My Preferred Keybindings
myKeys :: [(String, X ())]
myKeys =
  -- Xmonad
  [ ("M-C-r", spawn "xmonad --recompile"), -- Recompiles xmonad
    ("M-S-r", spawn "xmonad --restart"), -- Restarts xmonad
    ("M-C-q", io exitSuccess), -- Quits xmonad

    -- Workspaces
    ("M-<Tab>", toggleWS' ["NSP"]), -- Toggle to the previous WS excluding NSP
    ("M-.", nextNonEmptyWS), -- Move to next non-empty WS skipping NSP
    ("M-,", prevNonEmptyWS), -- Move to previous non-empty WS skipping NSP
    ("M-S-.", shiftToNextEmptyWS), -- Shift focused window to next empty WS skipping NSP and move to that WS
    ("M-S-,", shiftToPrevEmptyWS), -- Shift focused window to previous empty WS skipping NSP and move to that WS

    -- Windows
    ("M-S-q", kill1), -- Kill the currently focused client
    ("M-M1-a", killAll), -- Kill all the windows on current workspace
    ("M-C-a", toggleCopyToAll), -- Copy/Delete window to/from all other workspaces
    ("M-S-a", killAllOtherCopies), -- Kill all the copies of focused window

    -- Floating Windows
    ("M-<Delete>", withFocused $ windows . W.sink), -- Push floating window back to tile
    ("M-S-<Delete>", sinkAll), -- Push ALL floating windows back to tile

    -- Windows Navigation
    ("M-m", windows W.focusMaster), -- Move focus to the master window
    ("M-j", windows W.focusDown), -- Move focus to the next window
    ("M-k", windows W.focusUp), -- Move focus to the prev window
    ("M-S-m", windows W.swapMaster), -- Swap the focused window and the master window
    ("M-S-j", windows W.swapDown), -- Swap the focused window with the next window
    ("M-S-k", windows W.swapUp), -- Swap the focused window with the prev window
    ("M-<Backspace>", promote), -- Moves focused window to master, all others maintain order
    ("M1-<Tab>", rotAllDown), -- Rotate all windows clockwise and keep focus in place
    ("M1-S-<Tab>", rotAllUp), -- Rotate all windows anti-clockwise and keep focus in place

    -- Floating Windows Actions
    ("M-<Up>", withFocused (keysMoveWindow (0, -10))), --  Move window up
    ("M-<Down>", withFocused (keysMoveWindow (0, 10))), --  Move window down
    ("M-<Right>", withFocused (keysMoveWindow (10, 0))), --  Move window to right
    ("M-<Left>", withFocused (keysMoveWindow (-10, 0))), --  Move window to left
    ("M-S-<Up>", withFocused (keysResizeWindow (0, 10) (0, 1))), --  Increase size of window up
    ("M-S-<Down>", withFocused (keysResizeWindow (0, 10) (0, 0))), --  Increase size of window down
    ("M-S-<Right>", withFocused (keysResizeWindow (10, 0) (0, 1))), --  Increase size of window right
    ("M-S-<Left>", withFocused (keysResizeWindow (10, 0) (1, 1))), --  Increase size of window left
    ("M-C-<Up>", withFocused (keysResizeWindow (0, -10) (0, 1))), --  Decrease size of window up
    ("M-C-<Down>", withFocused (keysResizeWindow (0, -10) (0, 0))), --  Decrease size of window down
    ("M-C-<Right>", withFocused (keysResizeWindow (-10, 0) (0, 1))), --  Decrease size of window right
    ("M-C-<Left>", withFocused (keysResizeWindow (-10, 0) (1, 1))), --  Decrease size of window left

    -- Layouts
    ("M-<Space>", sendMessage NextLayout), -- Switch to next layout
    ("M-C-m", sendMessage $ Toggle NBFULL), -- Toggle Monocle Layout
    ("M-S-<Space>", withFocused toggleFloat), -- Toggle a window between floating and tiling states
    ("M-S-n", sendMessage $ Toggle NOBORDERS), -- Toggles noborder
    ("M-S-f", sendMessage (Toggle NBFULL) >> sendMessage ToggleStruts), -- Toggles fullscreen
    ("M-S-x", sendMessage $ Toggle REFLECTX), -- Swap master/stack positions horizontally
    ("M-S-y", sendMessage $ Toggle REFLECTY), -- Swap master/stack positions vertically
    ("M1-S-m", sendMessage $ Toggle MIRROR), -- Toggle layout between vertical and horizontal states
    ("M-C-M1-<Up>", sendMessage Arrange),
    ("M-C-M1-<Down>", sendMessage DeArrange),
    ("M-h", sendMessage Shrink), -- Resize horizontally to left
    ("M-l", sendMessage Expand), -- Resize horizontally to right
    ("M-C-j", sendMessage MirrorShrink), -- Resize vertically down
    ("M-C-k", sendMessage MirrorExpand), -- Resize vertically up

    -- Scratchpads
    -- , ("M-<Return>", namedScratchpadAction myScratchPads "terminal")       -- Terminal
    ("M-S-p", namedScratchpadAction myScratchPads "pulse"), -- Pavucontrol
      -- , ("M-q", namedScratchpadAction myScratchPads "calculator")            -- Qalculator-gtk

    -- Bar Toggle
    ("M-b", sendMessage ToggleStruts), -- Hide Xmobar

    -- Menus
    ("M-d", spawn "rofi -show run"), -- rofi run
    ("M-C-w", spawn "rofi -show window"), -- rofi window(show all opened applications)

    -- Multimedia keys
    ("<XF86AudioLowerVolume>", spawn "amixer -q sset Master 5%- unmute"),
    ("<XF86AudioRaiseVolume>", spawn "amixer -q sset Master 5%+ unmute"),
    ("<XF86AudioMute>", spawn "amixer -q set Master toggle"),
    ("<XF86AudioPlay>", spawn "playerctl play-pause"),
    ("<XF86AudioPrev>", spawn "playerctl prev"),
    ("<XF86AudioNext>", spawn "playerctl next"),

    -- My Applications
    ("M-<Return>", spawn myTerminal), -- Terminal
    ("M-g", spawn myBrowser), -- Google chrome browser
    ("M-n", spawn myEditor), -- Neovim text editor
    ("M-r", spawn $ myTerminal ++ "-e ranger"), -- Ranger file manager
    ("M-t", spawn "thunar"), -- Thunar file manager
    ("M-x s", spawn "mylock && systemctl suspend"),
    ("M-<Print>", spawn "gnome-screenshot -c"),
    ("<Print>", spawn "gnome-screenshot -i")
  ]
    -- Copy window by pressing Mod+c, then press any key through 1-9 to copy it to that WS.
    -- ++ [("M-c " ++ (show i), windows $ copy ws) | (i, ws) <- zip ([1 .. 9] :: [Int]) myWorkspaces]

-- -- Appending search engine prompts to keybindings list.
-- -- Look at "search engines" section of this config for values for "k".
-- ++ [("M-s " ++ k, S.promptSearch sXPConfig' f) | (k,f) <- searchList ]
-- -- Appending some extra xprompts to keybindings list.
-- -- Look at "xprompt settings" section this of config for values for "k".
-- ++ [("M-p " ++ k, f sXPConfig') | (k,f) <- promptList ]
-- -- Invoke windowPrompt by pressing Mod+w, then press 'k' to invoke associated option.
-- -- Look at windowPromptList section for values of k.
-- ++ [("M-w " ++ k, windowPrompt sXPConfig f allWindows) | (k,f) <- windowPromptList ]

------------------------------------------------------------------------
---MAIN
------------------------------------------------------------------------
main :: IO ()
main = do
  -- Launching xmobar
  xmproc <- spawnPipe "xmobar /home/shaurya/.config/xmobar/xmobarrc"
  -- Xmonad Settings
  xmonad $
    ewmh
      def
        { manageHook = myManageHook <+> manageDocks,
          startupHook = myStartupHook,
          layoutHook = myLayoutHook,
          handleEventHook = docksEventHook <+> fullscreenEventHook,
          modMask = myModMask,
          terminal = myTerminal,
          focusFollowsMouse = False,
          borderWidth = myBorderWidth,
          normalBorderColor = myNormColor,
          focusedBorderColor = myFocusColor,
          workspaces = myWorkspaces,
          logHook =
            myLogHook
              <+> dynamicLogWithPP
                xmobarPP
                  { ppOutput = \x -> hPutStrLn xmproc x,
                    ppCurrent = xmobarColor "#d79920" "" . wrap "(" ")", -- Current workspace in xmobar
                    ppHidden = xmobarColor "#a89983" "", -- Hidden workspaces in xmobar
                    ppTitle = xmobarColor "#989719" "" . shorten 40, -- Title of active window in xmobar
                    ppVisible = xmobarColor "#d79920" "",
                    ppUrgent = xmobarColor "#cc231c" "" . wrap "!" "!", -- Urgent workspace
          --          ppLayout = xmobarColor "#b16185" "" . (++),
                    ppSep = "<fc=#ebdbb2>}-{</fc>", -- Separators in xmobar
                    ppWsSep = "}-{",
                    ppExtras = [windowCount], -- No. of windows current workspace
                    ppOrder = \(ws : l : t : ex) -> [ws, xmobarColor "#b16185" "" $ l ++ " (" ++ concat ex ++ ")", t]
                  }
        }
      `additionalKeysP` myKeys
---------------------------------------------------------------------------- EOF --------------------------------------------------------------------------------------

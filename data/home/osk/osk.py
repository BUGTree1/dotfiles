#!/usr/bin/env python3
"""
sunshine_gamepad2key.py
Reads the virtual gamepad that Sunshine creates for Moonlight's on-screen
overlay and converts the inputs into X11 keyboard and mouse events.
"""

import sys
import evdev
from evdev import InputDevice, ecodes
from pynput.keyboard import Controller as KeyboardController, Key
from pynput.mouse import Controller as MouseController, Button as MouseButton

# =====================================================================
#  MAPPING CONFIGURATION  -- EDIT THIS FREELY
# =====================================================================
# Special key names understood by resolve_key():
#   space, enter, return, tab, esc, escape, backspace,
#   shift, ctrl, control, alt, cmd, caps_lock,
#   up, down, left, right, home, end, page_up, page_down,
#   insert, delete, f1 .. f19, slash, ...
# Mouse buttons: lmb (Left), rmb (Right), mmb (Middle)

#w s a d q e tab space left right 1 2 v c m lmb mmb rmb

# 1. Standard Buttons
BUTTON_MAP = {
    ecodes.BTN_A:      'f',         # BTN_SOUTH
    ecodes.BTN_B:      'space',     # BTN_EAST
    ecodes.BTN_X:      '1',         # BTN_WEST
    ecodes.BTN_Y:      '2',         # BTN_NORTH
    ecodes.BTN_TL:     'v',         # LB / L1
    ecodes.BTN_TR:     'c',         # RB / R1
    ecodes.BTN_SELECT: 'esc',       # Share / Select
    ecodes.BTN_START:  'enter',     # Options / Start
    ecodes.BTN_THUMBL: 'a',         # L3 (not in moonlight)
    ecodes.BTN_THUMBR: 'a',         # R3 (not in moonlight)
    ecodes.BTN_MODE:   'a',         # Guide / Home (not in moonlight)
}

# 2. Triggers (L2 / R2)
# Sunshine maps these as ABS_Z and ABS_RZ, ranging from 0 to 255.
# Format: axis_code: (threshold, press_key)
TRIGGER_MAP = {
    ecodes.ABS_Z:  (128, 'tab'),   # LT / L2
    ecodes.ABS_RZ: (128, 'shift'), # RT / R2
}

# 3. D-Pad (HAT)
# Sunshine maps these as ABS_HAT0X and ABS_HAT0Y.
# Format: axis_code: { value: key }
HAT_MAP = {
    ecodes.ABS_HAT0X: { -1: 'lmb',  1: 'rmb' },
    ecodes.ABS_HAT0Y: { -1: 'mmb',  1: 'm'   },
}

# 4. Analog Sticks
# Format: axis_code: (negative_key, positive_key)
# Pushing stick up gives negative Y, down gives positive Y. 
# Left gives negative X, right gives positive X.
STICK_MAP = {
    ecodes.ABS_X:  ('a', 'd'),       # Left stick horizontal
    ecodes.ABS_Y:  ('w', 's'),       # Left stick vertical
    ecodes.ABS_RX: ('left', 'right'),       # Right stick horizontal
    ecodes.ABS_RY: ('e', 'q'),       # Right stick vertical
}

STICK_THRESHOLD = 15000  # Deadzone for analog sticks (out of 32767)

# =====================================================================


class MouseAction:
    """Wrapper to distinguish mouse buttons from keyboard keys."""
    def __init__(self, button):
        self.button = button


def resolve_key(name):
    """Translate a string into a pynput Key, MouseAction, or literal char."""
    if name is None:
        return None
    
    # Case-insensitive matching for ease of use
    if isinstance(name, str):
        name = name.lower()

    if hasattr(Key, name):
        return getattr(Key, name)
    
    aliases = {
        'esc': Key.esc, 'escape': Key.esc,
        'enter': Key.enter, 'return': Key.enter,
        'shift': Key.shift, 'ctrl': Key.ctrl, 'control': Key.ctrl,
        'alt': Key.alt, 'cmd': Key.cmd,
        'space': Key.space, 'tab': Key.tab, 'backspace': Key.backspace,
        'up': Key.up, 'down': Key.down, 'left': Key.left, 'right': Key.right,
        'slash': '/',
        # Mouse buttons
        'lmb': MouseAction(MouseButton.left),
        'rmb': MouseAction(MouseButton.right),
        'mmb': MouseAction(MouseButton.middle),
    }
    return aliases.get(name, name)


# Resolve all dictionaries upfront for performance
RESOLVED_BUTTONS = {c: resolve_key(n) for c, n in BUTTON_MAP.items()}
RESOLVED_TRIGGERS = {c: (thr, resolve_key(pk)) for c, (thr, pk) in TRIGGER_MAP.items()}
RESOLVED_HAT = {c: {v: resolve_key(k) for v, k in d.items()} for c, d in HAT_MAP.items()}
RESOLVED_STICK = {c: (resolve_key(neg), resolve_key(pos)) for c, (neg, pos) in STICK_MAP.items()}


def find_gamepad():
    """Return list of (path, name) for devices that look like gamepads."""
    gamepad_buttons = {
        ecodes.BTN_A, ecodes.BTN_B, ecodes.BTN_X, ecodes.BTN_Y,
        ecodes.BTN_TL, ecodes.BTN_TR, ecodes.BTN_START, ecodes.BTN_SELECT,
        ecodes.BTN_THUMBL, ecodes.BTN_THUMBR, ecodes.BTN_MODE,
    }
    found = []
    for path in evdev.list_devices():
        try:
            dev = InputDevice(path)
            keys = set(dev.capabilities().get(ecodes.EV_KEY, []))
            if gamepad_buttons & keys:
                found.append((path, dev.name))
        except Exception:
            continue
    return found


def main():
    print("Scanning /dev/input for gamepad devices ...")
    candidates = find_gamepad()
    if not candidates:
        print("No gamepad found. Connect Moonlight with the on-screen overlay first.")
        sys.exit(1)

    print("Available gamepad devices:")
    for i, (p, n) in enumerate(candidates):
        print(f"  [{i}] {n}  ->  {p}")

    if len(candidates) == 1:
        idx = 0
    else:
        try:
            idx = int(input("Pick device index: ").strip())
        except (ValueError, EOFError):
            idx = 0
    path, name = candidates[idx]

    dev = InputDevice(path)
    print(f"\nListening on: {name} ({path})")
    print("Press Ctrl+C to quit.\n")

    keyboard = KeyboardController()
    mouse = MouseController()

    def press_input(key):
        if isinstance(key, MouseAction):
            mouse.press(key.button)
        else:
            keyboard.press(key)

    def release_input(key):
        if isinstance(key, MouseAction):
            mouse.release(key.button)
        else:
            keyboard.release(key)

    pressed_buttons = set()
    trigger_state = {ax: False for ax in RESOLVED_TRIGGERS}
    hat_state = {ax: None for ax in RESOLVED_HAT}
    stick_state = {ax: {'neg': False, 'pos': False} for ax in RESOLVED_STICK}

    try:
        for event in dev.read_loop():
            # --- Digital buttons ---
            if event.type == ecodes.EV_KEY:
                key = RESOLVED_BUTTONS.get(event.code)
                if key is None:
                    continue
                if event.value == 1 and event.code not in pressed_buttons:
                    press_input(key)
                    pressed_buttons.add(event.code)
                elif event.value == 0 and event.code in pressed_buttons:
                    release_input(key)
                    pressed_buttons.discard(event.code)

            # --- Analog Axes (Triggers, D-Pad, Sticks) ---
            elif event.type == ecodes.EV_ABS:
                
                # Triggers
                if event.code in RESOLVED_TRIGGERS:
                    thr, pkey = RESOLVED_TRIGGERS[event.code]
                    active = event.value >= thr
                    if active and not trigger_state[event.code]:
                        press_input(pkey)
                        trigger_state[event.code] = True
                    elif not active and trigger_state[event.code]:
                        release_input(pkey)
                        trigger_state[event.code] = False
                
                # D-Pad
                elif event.code in RESOLVED_HAT:
                    target_key = RESOLVED_HAT[event.code].get(event.value)
                    if event.value == 0:
                        if hat_state[event.code] is not None:
                            release_input(hat_state[event.code])
                            hat_state[event.code] = None
                    elif target_key is not None:
                        if hat_state[event.code] is not None and hat_state[event.code] != target_key:
                            release_input(hat_state[event.code])
                        if hat_state[event.code] != target_key:
                            press_input(target_key)
                            hat_state[event.code] = target_key

                # Analog Sticks
                elif event.code in RESOLVED_STICK:
                    neg_key, pos_key = RESOLVED_STICK[event.code]
                    state = stick_state[event.code]
                    
                    if event.value <= -STICK_THRESHOLD:
                        if not state['neg']:
                            if state['pos']:
                                release_input(pos_key)
                                state['pos'] = False
                            press_input(neg_key)
                            state['neg'] = True
                    elif event.value >= STICK_THRESHOLD:
                        if not state['pos']:
                            if state['neg']:
                                release_input(neg_key)
                                state['neg'] = False
                            press_input(pos_key)
                            state['pos'] = True
                    else:
                        # Deadzone - release both
                        if state['neg']:
                            release_input(neg_key)
                            state['neg'] = False
                        if state['pos']:
                            release_input(pos_key)
                            state['pos'] = False

    except KeyboardInterrupt:
        print("\nShutting down ...")
    finally:
        # Make sure nothing stays stuck
        for code in list(pressed_buttons):
            release_input(RESOLVED_BUTTONS[code])
        for ax, active in trigger_state.items():
            if active:
                _, pkey = RESOLVED_TRIGGERS[ax]
                release_input(pkey)
        for ax, key in hat_state.items():
            if key is not None:
                release_input(key)
        for ax, state in stick_state.items():
            if state['neg']:
                release_input(RESOLVED_STICK[ax][0])
            if state['pos']:
                release_input(RESOLVED_STICK[ax][1])


if __name__ == "__main__":
    main()

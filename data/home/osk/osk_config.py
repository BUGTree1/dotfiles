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
    ecodes.ABS_Z:  (128, 'tab'),   # L2
    ecodes.ABS_RZ: (128, 'shift'),   # R2
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

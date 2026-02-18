import {
  FromAndToKeyCode,
  layer,
  map,
  mapSimultaneous,
  ModifierKeyCode,
  rule,
  writeToProfile,
} from 'karabiner.ts'

import { nestedLeader } from './nestedLeader.rule'

/**
 * spacebar + hjkl = arrows
 * spacebar + d/u = page_up & page_down
 */
function motion_layer() {
  return layer('spacebar', 'arrow-layer').manipulators([
    map('h').to('left_arrow'),
    map('j').to('down_arrow'),
    map('k').to('up_arrow'),
    map('l').to('right_arrow'),
    map('d').to('page_down'),
    map('u').to('page_up'),
  ])
}

const mapHomerowModKey = (key: FromAndToKeyCode, modifier: ModifierKeyCode) => {
  return map(key, 'optionalAny')
    .toIfAlone(key, undefined, { halt: true })
    .toIfHeldDown(modifier, undefined, {})
    .toDelayedAction([], { key_code: key })
    .parameters({
      'basic.to_if_held_down_threshold_milliseconds': 100,
      'basic.to_delayed_action_delay_milliseconds': 100
    })
}

const rules = [
  // Add hyper key
  rule('Caps lock -> Hyper').manipulators([
    map('caps_lock').toHyper().toIfAlone('escape'),
  ]),

  rule('Homerow mods [SCGA]').manipulators([
    // mapHomerowModKey('a', 'left_shift'),
    // mapHomerowModKey('s', 'left_control'),
    // mapHomerowModKey('d', 'left_command'),
    mapHomerowModKey('f', 'left_option'),
    // mapHomerowModKey('j', 'right_option')
    // mapHomerowModKey('k', 'right_command')
    // mapHomerowModKey('l', 'right_control')
    // mapHomerowModKey('æ', 'right_shift')
  ]),

  rule('Overwrites: All').manipulators([
    map('right_shift').to('fn'),
    map('fn').to('right_control'),
    map('m', 'left_command').to('m')
  ]),

  rule('Left cmd + Right cmd to fn + F12').manipulators([
    mapSimultaneous([
      { key_code: 'left_command' },
      { key_code: 'right_command' },
    ]).to('f12', 'fn')
  ]),

  // rule('Overwrites: Apple keyboards',
  //   ifDevice([{ vendor_id: 76 }, { vendor_id: 1452 }]),
  // ).manipulators([
  //   map('grave_accent_and_tilde').to('non_us_backslash'),
  //   map('non_us_backslash').to('grave_accent_and_tilde')
  // ]),

  motion_layer(),
  // nestedLeader()
]

const profileName = 'Default profile'
// const profileName = '--dry-run'
writeToProfile(profileName, rules, {
  'simlayer.threshold_milliseconds': 125,
  'duo_layer.threshold_milliseconds': 125,
  'basic.to_if_alone_timeout_milliseconds': 500, //150,
  'basic.to_if_held_down_threshold_milliseconds': 150,
  'basic.to_delayed_action_delay_milliseconds': 200,
})


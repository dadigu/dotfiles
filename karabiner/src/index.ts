import {
  FromAndToKeyCode,
  ifDevice,
  ifVar,
  layer,
  map,
  ModifierKeyCode,
  rule,
  toRemoveNotificationMessage,
  toUnsetVar,
  withCondition,
  withMapper,
  writeToProfile,
  ToEvent,
  ManipulatorMap,
} from 'karabiner.ts'

/**
 * Generate notifications and manipulators for raycast
 */
function app_raycast_map(toEach: ToEvent[] = []) {
  const keyMap = {
    e: {
      desc: 'Emoji picker',
      cmd: 'open -g raycast://extensions/raycast/emoji-symbols/search-emoji-symbols',
    },
    c: {
      desc: 'Color picker',
      cmd: 'open -g raycast://extensions/thomas/color-picker/pick-color',
    },
    o: {
      desc: 'Recognise text (OCR)',
      cmd: 'open -g raycast://extensions/huzef44/screenocr/recognize-text',
    }
  }

  const notification = 'Raycast: \n\n' + Object.entries(keyMap)
    .map(([key, { desc }]) => `${key} → ${desc}`)
    .join('\n')

  const manipulators = withMapper(keyMap)((k, { cmd }) => {
    return map(k).to$(cmd).to(toEach)
  })

  return { notification, manipulators }
}

/**
 * Generate notifications and manipulators for apps
 */
function open_apps_map(toEach: ToEvent[] = []) {
  const keyMap = {
    t: 'Ghostty',
    b: 'Zen Browser',
    v: 'Ferdium',
    c: 'Visual Studio Code',
  }

  const notification = 'Open apps: \n\n' + Object.entries(keyMap)
    .map(([key, app]) => `${key} → ${app}`)
    .join('\n')

  const manipulators = withMapper(keyMap)((k, app) => {
    return map(k).toApp(app).to(toEach)
  })

  return { notification, manipulators }

}

function nested_leader() {
  const escape = [toUnsetVar('leader'), toRemoveNotificationMessage('leader')]
  const raycast = app_raycast_map(escape)
  const openApps = open_apps_map(escape)

  const sublayerMap = {
    r: {
      desc: 'Raycast',
      notification: raycast.notification,
      manipulators: raycast.manipulators
    },
    o: {
      desc: 'Open apps',
      notification: openApps.notification,
      manipulators: openApps.manipulators
    }
  }

  const leaderNotification = 'Leader key: \n\n' + Object.entries(sublayerMap)
    .map(([key, { desc }]) => `${key} → ${desc}`)
    .join('\n')

  return rule('Leader Key').manipulators([
    // When no leader key or nested leader key is on
    withCondition(ifVar('leader', 0))([
      // Leader key
      map('spacebar', 'Hyper') // Or mapSimultaneous(['l', ';']) ...
        .toVar('leader', 1)
        .toNotificationMessage('leader', leaderNotification),
    ]),

    // When leader key or nested leader key is on
    withCondition(ifVar('leader', 0).unless())([
      // Escape key(s)
      map('escape').to(escape),
    ]),

    // When leader key but no nested leader key is on
    withCondition(ifVar('leader', 1))([
      // Nested leader keys
      withMapper(sublayerMap)((k, { notification }) =>
        map(k)
          .toVar('leader', k)
          .toNotificationMessage('leader', notification),
      ),
    ]),
    // Generate sublayers
    ...Object.entries(sublayerMap).map(([k, { manipulators }]) => {
      return withCondition(ifVar('leader', k))(manipulators as unknown as ManipulatorMap)
    }),
  ])
}

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

  rule('Homerow mods').manipulators([
    mapHomerowModKey('f', 'left_option')
    // map('f').toIfHeldDown('left_option').toIfAlone('f').parameters({
    //   'basic.to_if_held_down_threshold_milliseconds': 150,
    // })
  ]),

  rule('Overwrites: All').manipulators([
    map('right_shift').to('fn'),
    map('fn').to('right_control'),
    map('m', 'left_command').to('m')
  ]),

  // rule('Overwrites: Apple keyboards',
  //   ifDevice([{ vendor_id: 76 }, { vendor_id: 1452 }]),
  // ).manipulators([
  //   map('grave_accent_and_tilde').to('non_us_backslash'),
  //   map('non_us_backslash').to('grave_accent_and_tilde')
  // ]),

  motion_layer(),
  nested_leader(),
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


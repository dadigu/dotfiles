import {
  hyperLayer,
  layer,
  LayerKeyParam,
  map,
  rule,
  toApp,
  writeToProfile,
} from 'karabiner.ts'

// // ! Change '--dry-run' to your Karabiner-Elements Profile name.
// // (--dry-run print the config json into console)
// // + Create a new profile if needed.
// writeToProfile('--dry-run', [
//   // It is not required, but recommended to put symbol alias to layers,
//   // (If you type fast, use simlayer instead, see https://evan-liu.github.io/karabiner.ts/rules/simlayer)
//   // to make it easier to write '←' instead of 'left_arrow'.
//   // Supported alias: https://github.com/evan-liu/karabiner.ts/blob/main/src/utils/key-alias.ts
//   layer('/', 'symbol-mode').manipulators([
//     //     / + [ 1    2    3    4    5 ] =>
//     withMapper(['⌘', '⌥', '⌃', '⇧', '⇪'])((k, i) =>
//       map((i + 1) as NumberKeyValue).toPaste(k),
//     ),
//     withMapper(['←', '→', '↑', '↓', '␣', '⏎', '⇥', '⎋', '⌫', '⌦', '⇪'])((k) =>
//       map(k).toPaste(k),
//     ),
//   ]),
//
//   rule('Key mapping').manipulators([
//     // config key mappings
//     map(1).to(1)
//   ]),
// ])

/**
 * Application launcher with Hyper + leaderKey 
 */
function app_launcher(leaderKey: LayerKeyParam) {
  const map = {
    t: 'WezTerm',
    b: 'Zen Browser',
    f: 'Ferdium',
    c: 'Visual Studio Code',
  }

  const notification = Object.entries(map).reduce((acc, [key, app]) => {
    acc = acc + `${key}  →  ${app} \n`

    return acc
  }, 'Open apps: \n \n')

  return hyperLayer(leaderKey)
    .description('Open Apps')
    .leaderMode()
    .notification(notification)
    .manipulators(Object.entries(map).reduce((acc, [key, app]) => {
      acc[key] = toApp(app)
      return acc
    }, {}))
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

const rules = [
  // Add hyper key
  rule('Caps lock -> Hyper').manipulators([
    map('caps_lock').toHyper().toIfAlone('escape'),
  ]),

  // Disable minimizing
  rule('Disable Cmd+m (minimize) on all applications').manipulators([
    map('m', 'left_command').to('m')
  ]),

  rule('Homerow mods').manipulators([
    map('f').toIfHeldDown('left_option').toIfAlone('f')
  ]),

  rule('Various overwrites').manipulators([
    map('right_shift').to('fn')
  ]),

  motion_layer(),
  app_launcher('spacebar'),
]

const profileName = 'Default profile'
// const profileName = '--dry-run'
writeToProfile(profileName, rules, {
  'simlayer.threshold_milliseconds': 125,
  'duo_layer.threshold_milliseconds': 125,
  'basic.to_if_alone_timeout_milliseconds': 150,
  'basic.to_if_held_down_threshold_milliseconds': 150,
  'basic.to_delayed_action_delay_milliseconds': 200,
})


import {
  ifVar,
  map,
  rule,
  toRemoveNotificationMessage,
  toUnsetVar,
  withCondition,
  withMapper,
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

/**
 * Generate notifications and manipulators for cleanshot
 */
function cleanshot_map(toEach: ToEvent[] = []) {
  const keyMap = {
    c: {
      desc: 'Capture & Copy',
      cmd: 'open -g cleanshot://capture-area?action=copy',
    },
    s: {
      desc: 'Capture full screen & Copy',
      cmd: 'open -g cleanshot://capture-fullscreen?action=copy',
    },
    a: {
      desc: 'Annotate from clipboard',
      cmd: 'open -g cleanshot://open-from-clipboard',
    },
    r: {
      desc: 'Screen recording',
      cmd: 'open -g cleanshot://record-screen',
    },
    h: {
      desc: 'Open history',
      cmd: 'open -g cleanshot://open-history',
    },
    'comma': {
      desc: 'Open settings',
      cmd: 'open -g cleanshot://open-settings',
    },
    'u': {
      desc: 'All-in-one mode',
      cmd: 'open -g cleanshot://all-in-one',
    },
  }

  const notification = 'Yabai: \n\n' + Object.entries(keyMap)
    .map(([key, { desc }]) => `${key} → ${desc}`)
    .join('\n')

  const manipulators = withMapper(keyMap)((k, { cmd }) => {
    return map(k).to$(cmd).to(toEach)
  })

  return { notification, manipulators }
}

/**
 * Generate notifications and manipulators for finder
 */
function finder_map(toEach: ToEvent[] = []) {
  const keyMap = {
    d: {
      desc: 'Downloads',
      cmd: 'open ~/Downloads',
    },
    c: {
      desc: 'Development',
      cmd: 'open ~/Development',
    },
  }

  const notification = 'Finder: \n\n' + Object.entries(keyMap)
    .map(([key, { desc }]) => `${key} → ${desc}`)
    .join('\n')

  const manipulators = withMapper(keyMap)((k, { cmd }) => {
    return map(k).to$(cmd).to(toEach)
  })

  return { notification, manipulators }
}

/**
 * Put it all together
 */
export function nestedLeader() {
  const escape = [toUnsetVar('leader'), toRemoveNotificationMessage('leader')]
  const raycast = app_raycast_map(escape)
  const openApps = open_apps_map(escape)
  const cleanshot = cleanshot_map(escape)
  const finder = finder_map(escape)

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
    },
    c: {
      desc: 'CleanShotX',
      notification: cleanshot.notification,
      manipulators: cleanshot.manipulators,
    },
    g: {
      desc: 'Finder',
      notification: finder.notification,
      manipulators: finder.manipulators,
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

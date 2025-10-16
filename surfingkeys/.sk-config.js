const {
  mapkey,
  map,
  unmap,
  Front,
  Hints,
} = api;

// Open tablist in omnibar
mapkey('<Space>', 'Choose a tab with omnibar', function () {
  Front.openOmnibar({ type: "Tabs" });
});

// Perform alt+click to click as glance click in zen browser
// https://www.reddit.com/r/zen_browser/comments/1gjatb0/simulating_the_new_glance_action_with_surfingkeys/
mapkey("gf", "Zen browser Glance click", () => {
  Hints.create("*[href]", (element) => {
    const event = new MouseEvent("click", {
      //ctrlKey: true,
      altKey: true,
      bubbles: true,
    });
    element.dispatchEvent(event);
  });
});

// an example to replace `T` with `gt`, click `Default mappings` to see how `T` works.
map('gt', 'T');

//api.unmap('P');
// Remap history to J,K
map('J', 'S');
map('K', 'D');

// Remap tab switching to H, L
map('H', 'E');
map('L', 'R');

// an example to remove mapkey `Ctrl-i`
unmap('<ctrl-i>');

// Update hint characters
Hints.setCharacters('sadjklewcmpgh');
// Set hint style overwrite properties
Hints.style('font-family:sans-serif');
// Set (visual) hint style overwrite properties
Hints.style('font-family:sans-serif', 'text');

// Settings

// Update scroll-speed. Default "70"
settings.scrollStepSize = 100;
// Set default search-engine to DuckDuckGo. Default "g"
settings.defaultSearchEngine = "d";
// Whether to wait for explicit input when there is only a single hint available. Default "false"
settings.hintExplicit = true;
// Whether new tab is active after entering hint while holding shift. Default "false"
settings.hintShiftNonActive = true;
// Which mode to fall back after yanking text in visual mode. Value could be one of ["", "Caret", "Normal"], default is "", which means no action after yank.
settings.modeAfterYank = 'Normal';
// Max list of omnibar results
settings.omnibarMaxResults = 15;

// set theme
settings.theme = `
.sk_theme {
    font-family: Input Sans Condensed, Charcoal, sans-serif;
    font-size: 10pt;
    background: #24272e;
    color: #abb2bf;
}
.sk_theme tbody {
    color: #fff;
}
.sk_theme input {
    color: #d0d0d0;
}
.sk_theme .url {
    color: #61afef;
}
.sk_theme .annotation {
    color: #56b6c2;
}
.sk_theme .omnibar_highlight {
    color: #528bff;
}
.sk_theme .omnibar_timestamp {
    color: #e5c07b;
}
.sk_theme .omnibar_visitcount {
    color: #98c379;
}
.sk_theme #sk_omnibarSearchResult ul li:nth-child(odd) {
    background: #303030;
}
.sk_theme #sk_omnibarSearchResult ul li.focused {
    background: #3e4452;
}
#sk_status, #sk_find {
    font-size: 20pt;
}`;
// click `Save` button to make above settings to take effect.</ctrl-i></ctrl-y>

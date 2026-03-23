local icons = require("icons")
local colors = require("colors")
local settings = require("settings")
local widgets = require("helpers.widgets")

local github = sbar.add("item", "widgets.github", {
  position = "right",
  icon = {
    string = ":git_hub:",
    font = "sketchybar-app-font:Regular:16.0",
    color = colors.grey,
  },
  label = { drawing = false },
  updates = "on",
  update_freq = 180,
  popup = { align = "center" },
})

widgets.bracket(github)

local type_map = {
  Issue       = { icon = icons.git.issue,        color = colors.green,   label = "Issue" },
  PullRequest = { icon = icons.git.pull_request, color = colors.magenta, label = "PR" },
  Discussion  = { icon = icons.git.discussion,   color = colors.white,   label = "Discussion" },
  Commit      = { icon = icons.git.commit,       color = colors.white,   label = "Commit" },
  CheckSuite  = { icon = icons.git.checksuite,   color = colors.yellow,  label = "CI" },
}

local reason_map = {
  mention = "mentioned", review_requested = "review", assign = "assigned",
  ci_activity = "CI", state_change = "changed", comment = "comment",
}

local function build_url(owner, repo, type_str, api_url)
  local number = tostring(api_url or ""):match("(%d+)$") or ""
  local paths = { Issue = "issues", PullRequest = "pull", Discussion = "discussions", Commit = "commit" }
  if paths[type_str] and number ~= "" then
    return "https://github.com/" .. owner .. "/" .. repo .. "/" .. paths[type_str] .. "/" .. number
  end
  return "https://github.com/" .. owner .. "/" .. repo
end

local cache = {}
local page = 1
local per_page = 10

local function render_page()
  if #cache == 0 then return end
  local total_pages = math.ceil(#cache / per_page)
  if page > total_pages then page = total_pages end
  local skip = (page - 1) * per_page

  sbar.remove("/github.n\\..*/")

  for i = skip + 1, math.min(skip + per_page, #cache) do
    local n = cache[i]
    local info = type_map[n.type] or { icon = icons.git.issue, color = colors.blue, label = n.type }
    local title = n.title
    if #title > 55 then title = title:sub(1, 52) .. "..." end
    local url = build_url(n.owner, n.repo, n.type, n.api_url)
    local reason = reason_map[n.reason] or ""
    local header = info.label
    if reason ~= "" then header = header .. " · " .. reason end

    -- Title item
    sbar.add("item", "github.n.h" .. i, {
      position = "popup." .. github.name,
      icon = {
        string = info.icon .. " " .. n.owner .. "/" .. n.repo,
        font = {
          style = settings.font.style_map['Bold'],
          size = settings.font.size.lg
        },
        color = info.color,
        padding_left = 10
      },
      label = {
        string = header,
        font = {
          size = settings.font.size.xs
        },
        color = colors.grey,
        padding_left = 6,
        padding_right = 10
      },
      background = {
        color = colors.transparent,
        border_width = 0
      },
      padding_left = 0,
      padding_right = 0,
      click_script = "open '" .. url .. "'; sketchybar --set " .. github.name .. " popup.drawing=off",
    })
    -- Subtitle item
    sbar.add("item", "github.n.t" .. i, {
      position = "popup." .. github.name,
      icon = { drawing = false },
      label = {
        string = title,
        font = {
          style = settings.font.style_map["Semibold"],
          size = settings.font.size.md
        },
        color = colors.white,
        padding_left = 25,
        padding_right = 10
      },
      y_offset = 15,
      background = { color = colors.transparent, border_width = 0 },
      padding_left = 0, padding_right = 0,
      click_script = "open '" .. url .. "'; sketchybar --set " .. github.name .. " popup.drawing=off",
    })
  end

  if total_pages > 1 then
    sbar.add("item", "github.n.page", {
      position = "popup." .. github.name,
      icon = {
        string = "Page " .. page .. "/" .. total_pages,
        font = {
          size = settings.font.size.xs,
        },
        color = colors.grey,
        padding_left = 10
      },
      label = {
        string = "Next 􀆊",
        font = {
          size = settings.font.size.xs,
          style = settings.font.style_map['Semibold']
        },
        color = colors.blue,
        padding_left = 8,
        padding_right = 10
      },
      y_offset = 8,
      background = { color = colors.transparent, border_width = 0 },
      click_script = "sketchybar --trigger github_next_page",
    })
  end

  sbar.add("item", "github.n.open", {
    position = "popup." .. github.name,
    icon = {
      string = "􀆪  Open on GitHub",
      font = {
        size = settings.font.size.xs,
      },
      color = colors.blue,
      padding_left = 10
    },
    label = { drawing = false },
    y_offset = 8,
    background = { color = colors.transparent, border_width = 0 },
    click_script = "open 'https://github.com/notifications'; sketchybar --set " .. github.name .. " popup.drawing=off",
  })
end

sbar.add("event", "github_next_page")
github:subscribe("github_next_page", function()
  local total_pages = math.ceil(#cache / per_page)
  page = (page % total_pages) + 1
  render_page()
end)

github:subscribe({ "routine", "forced" }, function()
  sbar.exec("gh api notifications", function(notifications)
    if type(notifications) ~= "table" or #notifications == 0 then
      github:set({ icon = { color = colors.grey }, label = { drawing = false } })
      sbar.remove("/github.n\\..*/")
      cache = {}
      return
    end

    cache = {}
    page = 1
    for _, n in ipairs(notifications) do
      local subject = n.subject or {}
      local repo = n.repository or {}
      table.insert(cache, {
        owner = (repo.owner or {}).login or "",
        repo = repo.name or "",
        type = subject.type or "",
        title = subject.title or "",
        reason = n.reason or "",
        api_url = subject.url or "",
      })
    end

    github:set({
      icon = { color = colors.blue },
      label = { string = tostring(#cache), drawing = true },
    })
    render_page()
  end)
end)

github:subscribe("mouse.clicked", function()
  github:set({ popup = { drawing = "toggle" } })
end)

github:subscribe("mouse.exited.global", function()
  github:set({ popup = { drawing = false } })
end)

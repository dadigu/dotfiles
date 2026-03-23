local icons = require("icons")
local colors = require("colors")
local settings = require("settings")
local widgets = require("helpers.widgets")

local linear = sbar.add("item", "widgets.linear", {
  position = "right",
  icon = {
    string = ":linear:",
    font = "sketchybar-app-font:Regular:16.0",
    color = colors.grey,
  },
  label = { drawing = false },
  updates = "on",
  update_freq = 180,
  popup = { align = "center" },
})

widgets.bracket(linear)

local type_map = {
  issueAssignment             = { icon = icons.git.issue,       color = colors.green,   label = "Assigned to you" },
  issueMention                = { icon = icons.linear.mention,  color = colors.blue,    label = "Mentioned you" },
  issueComment                = { icon = icons.git.discussion,  color = colors.white,   label = "Commented" },
  issueNewComment             = { icon = icons.git.discussion,  color = colors.white,   label = "Commented" },
  issueStatusChanged          = { icon = icons.linear.status,   color = colors.cyan,    label = "Status changed" },
  issuePriorityChanged        = { icon = icons.linear.priority, color = colors.orange,  label = "Priority changed" },
  issueBlocking               = { icon = icons.linear.blocking, color = colors.red,     label = "Blocking" },
  issueUnblocked              = { icon = icons.linear.status,   color = colors.green,   label = "Unblocked" },
  issueDue                    = { icon = icons.linear.calendar, color = colors.orange,  label = "Due soon" },
  issueCreated                = { icon = icons.git.issue,       color = colors.green,   label = "Created" },
  projectUpdateMentionPrompt  = { icon = icons.linear.mention,  color = colors.blue,    label = "Mentioned you" },
  projectUpdateCreated        = { icon = icons.linear.project,  color = colors.magenta, label = "New update" },
  projectUpdateNewComment     = { icon = icons.git.discussion,  color = colors.white,   label = "Replied" },
}

local function relative_time(created)
  if not created then return "" end
  local y, mo, d, h, mi, s = created:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)")
  if not y then return "" end
  local ts = os.time({ year = tonumber(y), month = tonumber(mo), day = tonumber(d), hour = tonumber(h), min = tonumber(mi), sec = tonumber(s) })
  local diff = os.time() - ts
  if diff < 3600 then return math.floor(diff / 60) .. "m"
  elseif diff < 86400 then return math.floor(diff / 3600) .. "h"
  else return math.floor(diff / 86400) .. "d" end
end

local cache = {}
local page = 1
local per_page = 10

-- Write query file once
local query_file = "/tmp/sketchybar_linear_query.json"
local qf = io.open(query_file, "w")
if qf then
  qf:write('{"query":"{ notifications(first: 30) { nodes { type readAt createdAt actor { name } ... on IssueNotification { issue { identifier title url team { name } } } ... on ProjectNotification { projectUpdate { body user { name } } project { name url } } } } }"}')
  qf:close()
end

local function render_page()
  if #cache == 0 then return end
  local total_pages = math.ceil(#cache / per_page)
  if page > total_pages then page = total_pages end
  local skip = (page - 1) * per_page

  sbar.remove("/linear.n\\..*/")

  for i = skip + 1, math.min(skip + per_page, #cache) do
    local n = cache[i]
    local info = type_map[n.type] or { icon = icons.linear.project, color = colors.magenta, label = "Update" }
    local title = n.title
    if #title > 45 then title = title:sub(1, 42) .. "..." end

    local subtitle = info.label
    if n.actor ~= "" then subtitle = n.actor .. " · " .. subtitle end
    subtitle = subtitle .. " · " .. relative_time(n.created)

    -- Title item
    sbar.add("item", "linear.n.h" .. i, {
      position = "popup." .. linear.name,
      icon = {
        string = info.icon,
        font = {
          style = settings.font.style_map['Bold'],
          size = settings.font.size.lg
        },
        color = info.color,
        padding_left = 10,
        padding_right = 6
      },
      label = {
        string = title,
        font = {
          style = settings.font.style_map["Bold"],
          size = settings.font.size.lg
        },
        color = colors.white,
        padding_right = 10
      },
      background = {
        color = colors.transparent,
        border_width = 0
      },
      padding_left = 0,
      padding_right = 0,
      click_script = "open '" .. (n.url or "") .. "'; sketchybar --set " .. linear.name .. " popup.drawing=off",
    })

    -- Subtitle item
    sbar.add("item", "linear.n.t" .. i, {
      position = "popup." .. linear.name,
      icon = {
        drawing = false
      },
      label = {
        string = subtitle,
        font = {
          style = settings.font.style_map["Semibold"],
          size = settings.font.size.md
        },
        color = colors.grey,
        padding_left = 35,
        padding_right = 10
      },
      y_offset = 15,
      background = {
        color = colors.transparent,
        border_width = 0
      },
      padding_left = 0,
      padding_right = 0,
      click_script = "open '" .. (n.url or "") .. "'; sketchybar --set " .. linear.name .. " popup.drawing=off",
    })
  end

  if total_pages > 1 then
    sbar.add("item", "linear.n.page", {
      position = "popup." .. linear.name,
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
        color = colors.magenta,
        padding_left = 8,
        padding_right = 10
      },
      y_offset = 8,
      background = { color = colors.transparent, border_width = 0 },
      click_script = "sketchybar --trigger linear_next_page",
    })
  end

  sbar.add("item", "linear.n.open", {
    position = "popup." .. linear.name,
    icon = {
      string = "􀆪  Open on Linear",
      font = {
        size = settings.font.size.xs,
      },
      color = colors.magenta,
      padding_left = 10
    },
    label = { drawing = false },
    y_offset = 8,
    background = { color = colors.transparent, border_width = 0 },
    click_script = "open 'https://linear.app'; sketchybar --set " .. linear.name .. " popup.drawing=off",
  })
end

sbar.add("event", "linear_next_page")
linear:subscribe("linear_next_page", function()
  local total_pages = math.ceil(#cache / per_page)
  page = (page % total_pages) + 1
  render_page()
end)

linear:subscribe({ "routine", "forced" }, function()
  local api_key = ENV and ENV.LINEAR_API_KEY
  if not api_key or api_key == "" then
    linear:set({ icon = { color = colors.grey }, label = { drawing = false } })
    return
  end

  sbar.exec("curl -s --max-time 10 -H 'Authorization: " .. api_key .. "' -H 'Content-Type: application/json' -d @" .. query_file .. " https://api.linear.app/graphql", function(response)
    if type(response) ~= "table" or not response.data or not response.data.notifications then
      linear:set({ icon = { color = colors.grey }, label = { drawing = false } })
      return
    end

    cache = {}
    page = 1
    for _, n in ipairs(response.data.notifications.nodes) do
      if not n.readAt then
        local entry = { type = n.type or "", actor = "", created = n.createdAt or "" }
        if n.actor then entry.actor = n.actor.name or "" end
        if n.issue then
          entry.title = n.issue.title or ""
          entry.url = n.issue.url or ""
        elseif n.project then
          entry.title = n.project.name or ""
          entry.url = n.project.url or ""
        end
        if entry.title then table.insert(cache, entry) end
      end
    end

    if #cache == 0 then
      linear:set({ icon = { color = colors.grey }, label = { drawing = false } })
      sbar.remove("/linear.n\\..*/")
      return
    end

    linear:set({
      icon = { color = colors.magenta },
      label = { string = tostring(#cache), drawing = true },
    })
    render_page()
  end)
end)

linear:subscribe("mouse.clicked", function()
  linear:set({ popup = { drawing = "toggle" } })
end)

linear:subscribe("mouse.exited.global", function()
  linear:set({ popup = { drawing = false } })
end)

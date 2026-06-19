require("bunny"):setup({
  hops = {
    { key = "/",          path = "/",                              desc = "FS Root"   },
    { key = "~",          path = "~",                              desc = "User Home" },
    { key = "m",          path = "~/Music",                        desc = "Music"     },
    { key = "d",          path = "~/Desktop",                      desc = "Desktop"   },
    { key = "D",          path = "~/Documents",                    desc = "Documents" },
    { key = { "m", "d" }, path = "/media/D",                       desc = "D drive"   },
    { key = { "m", "e" }, path = "/media/E",                       desc = "E drive"   },
    { key = { "l", "b" }, path = "~/.local/share/bottles/bottles", desc = "Bottles"   }
    -- key and path attributes are required, desc is optional
  },
  desc_strategy = "path", -- If desc isn't present, use "path" or "filename", default is "path"
  ephemeral = true, -- Enable ephemeral hops, default is true
  tabs = true, -- Enable tab hops, default is true
  notify = false, -- Notify after hopping, default is false
  fuzzy_cmd = "fzf", -- Fuzzy searching command, default is "fzf"
})


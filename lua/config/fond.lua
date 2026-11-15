-- Fond d'écran derrière nvim, dans kitty (maison et cluster).
--
-- Quand nvim s'ouvre, il demande à kitty d'afficher l'image derrière le texte ;
-- quand il se ferme (ou avec Ctrl-Z), il l'enlève : le terminal normal reste
-- sans image. Le texte est lisible par-dessus car tokyonight est déjà
-- transparent (transparent = true dans lua/plugins/ui.lua).
--
-- Côté kitty : kitty/fond.conf (contrôle à distance + assombrissement).
-- La 1re fois sur une machine, nvim ajoute lui-même la ligne include dans
-- ~/.config/kitty/kitty.conf ; il faut ensuite ouvrir un NOUVEAU kitty.
--
-- L'image est dans le repo privé divers (ce repo-ci est public).
-- Pour la changer : remplace ~/42/divers/fond/fond.jpg, en prenant une image
-- d'au moins 1920 px de large (plus petite, kitty l'agrandit : c'est flou).
-- Assombrissement : background_tint dans kitty/fond.conf.

local image = vim.fn.expand("~/42/divers/fond/fond.jpg")
local snippet = vim.fn.stdpath("config") .. "/kitty/fond.conf"
local kitty_conf = vim.fn.expand("~/.config/kitty/kitty.conf")
local win = vim.env.KITTY_WINDOW_ID

-- pas dans kitty, ou nvim lancé depuis le terminal d'un autre nvim
-- (sinon, en quittant, il enlèverait le fond du nvim de dessous)
if not win or vim.env.NVIM or vim.fn.filereadable(image) == 0 then
  return
end

-- 1re fois sur cette machine : ajoute l'include à kitty.conf
local function installer()
  local f = io.open(kitty_conf, "r")
  local contenu = f and f:read("*a") or ""
  if f then
    f:close()
  end
  if contenu:find("nvim/kitty/fond.conf", 1, true) then
    return -- déjà fait : ce kitty a juste été ouvert avant
  end
  vim.fn.mkdir(vim.fn.fnamemodify(kitty_conf, ":h"), "p")
  f = io.open(kitty_conf, "a")
  if not f then
    return
  end
  f:write("\n# fond d'écran derrière nvim (ajouté par ~/.config/nvim/lua/config/fond.lua)\n")
  f:write("include " .. snippet .. "\n")
  f:close()
  vim.schedule(function()
    vim.notify("Fond nvim : kitty est configuré. Ouvre un nouveau kitty pour voir l'image.")
  end)
end

local kitten = vim.fn.executable("kitten") == 1 and { "kitten", "@" } or { "kitty", "@" }
local actif = false
local en_cours -- dernière commande envoyée à kitty

local function envoyer(args, attendre)
  if en_cours then
    en_cours:wait(1000) -- garde l'ordre : afficher puis enlever
  end
  local cmd = vim.list_extend(vim.deepcopy(kitten), args)
  local ok, job = pcall(vim.system, cmd, { text = true }, function(res)
    if res.code ~= 0 then
      vim.schedule(function()
        vim.notify("Fond nvim : kitty a refusé\n" .. (res.stderr or ""), vim.log.levels.WARN)
      end)
    end
  end)
  en_cours = ok and job or nil
  if en_cours and attendre then
    en_cours:wait(1000)
  end
end

local function afficher()
  envoyer({ "set-background-image", "--match", "id:" .. win, "--layout", "cscaled", image })
end

local function enlever()
  envoyer({ "set-background-image", "--match", "id:" .. win, "none" }, true)
end

local groupe = vim.api.nvim_create_augroup("fond", { clear = true })

vim.api.nvim_create_autocmd("UIEnter", {
  group = groupe,
  callback = function()
    if actif then
      return
    end
    if not vim.env.KITTY_LISTEN_ON then
      installer() -- kitty sans contrôle à distance
      return
    end
    actif = true
    afficher()
  end,
})

vim.api.nvim_create_autocmd({ "VimLeavePre", "VimSuspend" }, {
  group = groupe,
  callback = function()
    if actif then
      enlever()
    end
  end,
})

vim.api.nvim_create_autocmd("VimResume", {
  group = groupe,
  callback = function()
    if actif then
      afficher()
    end
  end,
})

local slave = "proxysql.slave.meliseginf.com"
local master = "proxysql.master.meliseginf.com"
local port = "6612"
local user = "mgiampaolo"

local function secret()
  return vim.fn.system("security find-generic-password -a " .. user .. " -s meli-pw -w 2>/dev/null"):gsub("\n", "")
end

local function urlencode_pw(pw)
  return pw:gsub("%%", "%%25"):gsub("#", "%%23"):gsub("%$", "%%24")
end

local function mysql(host, db)
  return string.format("mysql://%s:%s@%s:%s/%s", user, urlencode_pw(secret()), host, port, db)
end

return {
  {
    "tpope/vim-dadbod",
    lazy = true,
  },
  {
    "kristijanhusak/vim-dadbod-completion",
    lazy = true,
    dependencies = { "tpope/vim-dadbod" },
  },
  {
    "saghen/blink.cmp",
    opts = {
      sources = {
        per_filetype = {
          sql = { "dadbod", "buffer" },
          mysql = { "dadbod", "buffer" },
        },
        providers = {
          dadbod = {
            name = "Dadbod",
            module = "vim_dadbod_completion.blink",
          },
        },
      },
    },
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = { "tpope/vim-dadbod", "kristijanhusak/vim-dadbod-completion" },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    keys = {},
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_save_location = vim.fn.expand("~/Desktop/db")
      vim.g.db_ui_auto_execute_table_helpers = 1

      local all_dbs = {
        { name = "BigQuery",                  url = "bigquery:meli-bi-data" },
        { name = "Rule Engine SBX",          url = mysql(slave,  "sandbox") },
        { name = "Rule Engine PROD",          url = mysql(slave,  "ruleengine") },
        { name = "Rule Engine STAGE/PREPROD", url = mysql(slave,  "stagingdb") },
        { name = "Account Taxes STAGE",       url = mysql(slave,  "stgmptaxes") },
        { name = "Account Taxes PROD",        url = mysql(slave,  "mptaxes") },
        { name = "Account Taxes PROD MASTER", url = mysql(master, "mptaxes") },
        { name = "Pricing taxes",             url = mysql(slave,  "pritaxes") },
        { name = "Pricing tags",              url = mysql(slave,  "pricingtag") },
      }

      if vim.env.NVIM_DB_MODE == "bigquery" then
        vim.g.dbs = { all_dbs[1] }
      else
        vim.g.dbs = all_dbs
      end
    end,
  },
}

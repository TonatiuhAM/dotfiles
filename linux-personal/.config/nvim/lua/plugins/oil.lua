return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  lazy = false,
  opts = {
    default_file_explorer = false,
    delete_to_trash = true,
    skip_confirm_for_simple_edits = false,
    view_options = {
      show_hidden = true,
    },
    keymaps = {
      ["q"] = "actions.close",
      ["<BS>"] = { "actions.parent", mode = "n" },
    },
    preview_split = "auto",
    preview_win = {
      update_on_cursor_moved = true,
      preview_method = "fast_scratch",
    },
    watch_for_changes = true,
  },
}

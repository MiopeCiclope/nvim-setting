return {
  {
    dir = "~/projects/autotag",
    dev = true,
    config = function()
      require("autotag").setup()
    end,
  },
}

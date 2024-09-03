return {
	dir = "~/projects/job-notifier",
	dev = true,
	config = function()
		local scanner = require("job-notifier")
		scanner:setup({
			meta = {
				{
					name = "react",
					cmd = "npm start",
					logFile = "reactLog.txt",
					stages = {
						["Compiling"] = {
							text = "Building",
							color = "black",
						},
						["No issues found"] = {
							text = "Success",
							color = "green",
						},
						["ERROR in"] = {
							text = "Fail",
							color = "red",
						},
					},
				},
				{
					name = "watcher",
					cmd = "npm run watch",
					logFile = "watcherLog.txt",
					stages = {
						["Executing command"] = {
							text = "Watching",
							color = "black",
						},
						["NODE_ENV=production"] = {
							text = "Building",
							color = "black",
						},
						["Nx read the output"] = {
							text = "Success",
							color = "green",
						},
						["Failed"] = {
							text = "Fail",
							color = "red",
						},
					},
				},
			},
		})
	end,
}

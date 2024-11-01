return {
	dir = "~/projects/job-notifier",
	dev = true,
	config = function()
		local scanner = require("job-notifier")
		scanner:setup({
			meta = {
				{
					name = "build",
					cmd = "npm run build",
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
					name = "react",
					cmd = "npm start",
					stages = {
						["NODE_ENV=development"] = {
							text = "Building",
							color = "black",
						},
						["successfully"] = {
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
				{
					name = "e2e",
					cmd = "npm run local",
					stages = {},
				},
				{
					name = "dotner",
					cmd = "dotnet run",
					stages = {},
				},
			},
		})
	end,
}

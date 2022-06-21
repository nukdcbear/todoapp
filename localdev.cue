package todoapp

import (
	"dagger.io/dagger"
)

client: {
	filesystem: "./build": write: contents: actions.build.output
	env: {
		NETLIFY_TOKEN: dagger.#Secret
		USER:          string
		APP_NAME:      string
	}
}
actions: deploy: {
	token: client.env.NETLIFY_TOKEN
	site:  client.env.APP_NAME
}

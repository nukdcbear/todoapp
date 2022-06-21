package todoapp

import (
	"dagger.io/dagger"

	"dagger.io/dagger/core"
	"universe.dagger.io/netlify"
	"universe.dagger.io/yarn"
)

dagger.#Plan & {
	client: {
		env: {
			NETLIFY_TOKEN: dagger.#Secret
			USER:  string
			NETLIFY_TEAM:  string
			APP_NAME:  string
		}
	}

	actions: {
		// Load the todoapp source code
		source: core.#Source & {
			path: "."
			exclude: [
				"node_modules",
				"build",
				"*.cue",
				"*.md",
				".git",
			]
		}

		// Build todoapp
		build: yarn.#Script & {
			name:   "build"
			source: actions.source.output
		}

		// Test todoapp
		test: yarn.#Script & {
			name:   "test"
			source: actions.source.output

			// This environment variable disables watch mode
			// in "react-scripts test".
			// We don't set it for all commands, because it causes warnings
			// to be treated as fatal errors.
			// See https://create-react-app.dev/docs/advanced-configuration
			container: env: CI: "true"
		}

		// Deploy todoapp
		deploy: netlify.#Deploy & {
			contents: actions.build.output
			site:     client.env.APP_NAME
			token:    client.env.NETLIFY_TOKEN
			team:     client.env.NETLIFY_TEAM
		}
	}
}

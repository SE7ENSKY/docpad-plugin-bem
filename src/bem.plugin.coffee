async = require 'async'

module.exports = (BasePlugin) ->
	class BemPlugin extends BasePlugin
		name: 'bem'

		config:
			blocksPaths: [ 'blocks' ]

		alreadyAddedAssets: []

		populateCollections: (opts,next) ->
			docpadConfig = @docpad.getConfig()
			config = docpadConfig.plugins.bem
			async.each config.blocksPaths, (blocksPath, done) =>
				@docpad.parseDocumentDirectory
					path: "#{docpadConfig.srcPath}/#{blocksPath}"
					createFunction: (data, opts) ->
						data.relativePath = "#{blocksPath}/#{data.relativePath}"
						@createModel data, opts
				, done
			, next

			@ # chaining

		extendCollections: (opts) ->
			docpadConfig = @docpad.getConfig()
			config = docpadConfig.plugins.bem
			for blocksPath in config.blocksPaths
				@docpad.setCollection 'bemAssets', @docpad.getDatabase().createLiveChildCollection()
					.setQuery('isBemAsset', {
						$or:
							isBemAsset: yes
							fullPath: $startsWith: "#{docpadConfig.srcPath}/#{blocksPath}"
					})
					.on('add', (model) ->
						model.setDefaults
							isBemAsset: yes
							render: true
							write: true
					)

			@ # chaining

		renderBefore: (opts) ->
			docpadConfig = @docpad.getConfig()
			config = docpadConfig.plugins.bem
			allBemAssets = @docpad.database.findAllLive(isBemAsset: true).toJSON()
			cssAssets = []
			jsAssets = []
			for asset in allBemAssets
				continue if asset.url in @alreadyAddedAssets
				@alreadyAddedAssets.push asset.url
				cssAssets.push asset.url if asset.outExtension is 'css'
				jsAssets.push asset.url if asset.outExtension is 'js'
			@docpad.getBlock('styles').add cssAssets
			@docpad.getBlock('scripts').add jsAssets

			@ # chaining
async = require 'async'

module.exports = (BasePlugin) ->
	class BemPlugin extends BasePlugin
		name: 'bem'

		config:
			blocksPaths: [ 'blocks' ]

		constructor: ->
			super

			@renderedBlocks = {}

		renderBlock: (blockName, templateData, blockPlaceholder) ->
			blockDocument = @docpad.getCollection('bemHtmlAssets').findOne blockName: blockName
			if not blockDocument
				@renderedBlocks[blockPlaceholder] = "[block not found: #{blockName}]"
			else
				templateData.block = @block
				@docpad.renderDocument blockDocument, templateData: templateData, (err, result, document) =>
					if err
						@renderedBlocks[blockPlaceholder] = "[error rendering block: #{blockName}]"
						console.log "error rendering block #{blockDocument.get('blocksPath')}/#{blockName}"
						console.log err
					else
						# console.log "successfully rendered block #{blockName}"
						@renderedBlocks[blockPlaceholder] = result

		block: (blockName, data = {}) =>
			@referencesOthers?()
			# ToDo: do escapes

			tag = data.tag or "div"
			
			classes = [blockName]
			
			if data.mods
				classes.push "#{blockName}_#{key}_#{value}" for key, value of data.mods
				delete data.mods

			if data.class
				classes.push data.class
				delete data.class

			attrs = "class=\"#{classes.join ' '}\""
			if data.attrs
				attrs += " #{key}=\"#{value}\"" for key, value of data.attrs
				delete data.attrs

			blockPlaceholder = "[block:#{Math.random()}]"

			@renderBlock blockName, data, blockPlaceholder

			"<#{tag} #{attrs}>#{blockPlaceholder}</#{tag}>"

		extendTemplateData: ({templateData}) ->
			self = @
			templateData.block = (args...) ->
				@referencesOthers?()
				self.block args...
			@ # chaining

		renderDocument: (opts, next) ->
			{templateData, file} = opts
			return next() if not opts.content
			blockPlaceholders = opts.content.match ///\[block:([^\]]+)\]///g
			return next() if not blockPlaceholders

			async.each blockPlaceholders, (blockPlaceholder, doneBlock) =>
				async.until =>
					@renderedBlocks[blockPlaceholder]
				, setImmediate, =>
					opts.content = opts.content.replace blockPlaceholder, @renderedBlocks[blockPlaceholder]
					delete @renderedBlocks[blockPlaceholder]
					doneBlock()
			, next

			@ # chaining

		populateCollections: (opts, next) ->
			docpadConfig = @docpad.getConfig()
			config = docpadConfig.plugins.bem
			async.each config.blocksPaths, (blocksPath, done) =>
				@docpad.parseDocumentDirectory
					path: "#{docpadConfig.srcPath}/#{blocksPath}"
				, done
			, next

			@ # chaining

		extendCollections: (opts) ->
			docpadConfig = @docpad.getConfig()
			config = docpadConfig.plugins.bem
			
			@docpad.setCollection 'bemCssAssets', @docpad.getDatabase().createLiveChildCollection()
				.setQuery('isBemCssAsset', isBemAsset: yes, outExtension: 'css')
				.on("add", (model) =>
					model.setDefaults
						render: yes
						write: yes
					@docpad.getBlock('styles').add [ model.get('url') ]
				)
			@docpad.setCollection 'bemJsAssets', @docpad.getDatabase().createLiveChildCollection()
				.setQuery('isBemJsAsset', isBemAsset: yes, outExtension: 'js')
				.on("add", (model) =>
					model.setDefaults
						render: yes
						write: yes
					@docpad.getBlock('scripts').add [ model.get('url') ]
				)
			@docpad.setCollection 'bemHtmlAssets', @docpad.getDatabase().createLiveChildCollection()
				.setQuery('isBemHtmlAsset', isBemAsset: yes, outExtension: 'html')
				.on("add", (model) =>
					model.setDefaults
						render: no
						write: no
				)

			@docpad.setCollection 'bemAssets', @docpad.getDatabase().createLiveChildCollection()
				.setQuery('isBemAsset',
					fullPath: $startsWith: ("#{docpadConfig.srcPath}/#{blocksPath}/" for blocksPath in config.blocksPaths)
				)
				.on('add', (model) =>
					model.setDefaults
						isBemAsset: yes
					fullPath = model.get("fullPath")
					for blocksPath in config.blocksPaths
						if fullPath.indexOf "#{docpadConfig.srcPath}/#{blocksPath}/" is 0
							model.set
								blocksPath: blocksPath
								blockName: fullPath.replace("#{docpadConfig.srcPath}/#{blocksPath}/", "").split("/")[0]
				)

			@ # chaining

		# 	@ # chaining
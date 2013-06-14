handlebars = require 'handlebars'
path = require 'path'
fs = require 'fs'

module.exports = (env, callback) ->

  # default partial directory is `partials`
  options = env.config.handlebars || {"partialDir": "partials"}

  # Support for Handlebars templates
  class HandlebarsTemplate extends env.TemplatePlugin

    constructor: (@tpl) ->

    render: (locals, callback) ->
      try
        rendered = @tpl(locals)
        callback null, new Buffer rendered
      catch error
        callback error

  HandlebarsTemplate.fromFile = (filepath, callback) ->
    fs.readFile filepath.full, (error, contents) ->
      if error then callback error
      else
        try
          tpl = handlebars.compile contents.toString()
          callback null, new HandlebarsTemplate tpl
        catch error
          callback error

  # Support for Handlebars partials
  class HandlebarsPartial extends HandlebarsTemplate

  HandlebarsPartial.fromFile = (filepath, callback) ->
    fs.readFile filepath.full, (error, contents) ->
      if error then callback error
      else
        try
          ext = path.extname(filepath.relative)
          basename = path.basename(filepath.relative, ext)
          tpl = handlebars.compile contents.toString()
          handlebars.registerPartial(basename, tpl)
          callback null, new HandlebarsPartial tpl
        catch error
          callback error

  # Registering the plugins
  env.registerTemplatePlugin '**/*.*(html)', HandlebarsTemplate
  env.registerTemplatePlugin "**/#{options.partialDir}/*.*(html)", HandlebarsPartial
  # return callback
  callback()
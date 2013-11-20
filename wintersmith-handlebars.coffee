handlebars = require 'handlebars'
path = require 'path'
fs = require 'fs'

module.exports = (env, callback) ->

  # default partial directory is `partials`, helper directory to `helpers`
  options = env.config.handlebars || {"partialDir": "partials", "helperDir": "helpers"}

  # Support for Handlebars templates
  class HandlebarsTemplate extends env.TemplatePlugin

    constructor: (@tpl) ->

    render: (locals, callback) ->
      try
        rendered = @tpl locals
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
          ext = path.extname filepath.relative
          basename = path.basename filepath.relative, ext
          tpl = handlebars.compile contents.toString()
          handlebars.registerPartial basename, tpl
          callback null, new HandlebarsPartial tpl
        catch error
          callback error


  # Support for Handlebars partials
  class HandlebarsHelper extends HandlebarsTemplate

  HandlebarsHelper.fromFile = (filepath, callback) ->
    try
      ext = path.extname filepath.relative
      basename = path.basename filepath.relative, ext
      fn = require filepath.full
      if fn
        handlebars.registerHelper basename, fn
        callback null, null
      else
        error = new Error 'Could not load helper function'
        callback error
    catch error
      callback error


  # Registering the plugins
  env.registerTemplatePlugin '**/*.*(html|hbs)', HandlebarsTemplate
  env.registerTemplatePlugin "**/#{options.partialDir}/*.*(html|hbs)", HandlebarsPartial
  env.registerTemplatePlugin "**/#{options.helperDir}/*.*(js)", HandlebarsHelper
  # return callback
  callback()

Handlebars = require 'handlebars'
path = require 'path'
fs = require 'fs'

module.exports = (env, callback) ->
  # Default partial directory is `partials`, helper directory to `helpers`
  defaults =
    partialDir: "partials"
    helperDir: "helpers"
  
  # Extend options with ones defined in config.json
  options = env.config.handlebars or {}
  for key, value of defaults
    options[key] ?= defaults[key]

  # Support for Handlebars templates
  class HandlebarsTemplate extends env.TemplatePlugin
    constructor: (@tpl, @layout, @filepath) ->
    render: (locals, callback) ->
      if @layout
        tpl = Handlebars.compile fs.readFileSync(@filepath.full).toString()
        compiled = tpl locals
        locals.yield = new Handlebars.SafeString(compiled)
    
      try
        rendered = @tpl locals
        callback null, new Buffer rendered
      catch error
        callback error

  HandlebarsTemplate.fromFile = (filepath, callback) ->
    if typeof options.layout == 'string'
      compilepath =
        full: path.join(path.dirname(filepath.full), options.layout)
        relative: options.layout
      layout = true
    else
      compilepath = filepath
      layout = false
    
    fs.readFile compilepath.full, (error, contents) ->
      if error then callback error
      else
        try
          tpl = Handlebars.compile contents.toString()
          callback null, new HandlebarsTemplate tpl, layout, filepath
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
          tpl = Handlebars.compile contents.toString()
          Handlebars.registerPartial basename, tpl
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
        Handlebars.registerHelper basename, fn
        callback null, null
      else
        error = new Error 'Could not load helper function'
        callback error
    catch error
      callback error

  # Registering the plugins
  env.registerTemplatePlugin '**/*.*(html)', HandlebarsTemplate
  env.registerTemplatePlugin "**/#{options.partialDir}/*.*(html)", HandlebarsPartial
  env.registerTemplatePlugin "**/#{options.helperDir}/*.*(js)", HandlebarsHelper
  
  callback() # Return callback
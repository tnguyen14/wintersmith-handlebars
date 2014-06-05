Handlebars = require 'handlebars'
path = require 'path'
fs = require 'fs'
layoutPattern = /{{!<\s+([A-Za-z0-9\._\-\/]+)\s*}}/
extend = (obj, mixin) ->
  obj[name] = method for name, method of mixin
  obj

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
    constructor: (@tpl, @raw, @filepath) ->
    render: (locals, callback) ->
      try
        layout = @raw.toString().match(layoutPattern)
        if layout and layout.length
          @filepath =
            full: path.join(path.dirname(@filepath.full), layout[1])
            relative: layout[1]
          HandlebarsTemplate.fromFile @filepath, (error, layout, filepath) =>
            if error then callback error
            else
              context = extend locals,
                body: @raw.toString()
              layout.render context, (error, contents) =>
                if error then callback error
                else
                  if contents
                    @tpl = Handlebars.compile contents.toString()
                    rendered = @tpl locals
                    callback null, new Buffer rendered
        else
          rendered = @tpl locals
          callback null, new Buffer rendered
      catch error
      callback error

  HandlebarsTemplate.fromFile = (filepath, callback) ->
    fs.readFile filepath.full, (error, contents) ->
      if error then callback error
      else
        try
          tpl = Handlebars.compile contents.toString()
          callback null, new HandlebarsTemplate tpl, contents, filepath
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
      fn = env.loadModule filepath.full
      if fn
        Handlebars.registerHelper basename, fn
        callback null, null
      else
        error = new Error 'Could not load helper function'
        callback error
    catch error
      callback error

  # Registering the plugins
  env.registerTemplatePlugin '**/*.*(html|hbs)', HandlebarsTemplate
  env.registerTemplatePlugin "**/#{options.partialDir}/*.*(html|hbs)", HandlebarsPartial
  env.registerTemplatePlugin "**/#{options.helperDir}/*.*(js|coffee)", HandlebarsHelper

  callback() # Return callback

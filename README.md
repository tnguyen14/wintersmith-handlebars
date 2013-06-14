## Handlebars plugin for Wintersmith
This plugin provides support for using [Handlebars](http://handlebarsjs.com) for [Wintersmith](http://wintersmith.io).

This plugin was inspired from [wintersmith-hogan](https://github.com/sfrdmn/wintersmith-hogan).

### How to use
Either

1. Download the repo and copy the `wintersmith-handlebars.coffee` file into your `plugins` directory of your `wintersmith` install.
2. Remember to add `wintersmith-handlebars.coffee` to your `config.json` file as well.
3. Starting writing handlebars templates in your templates directory as `.html` files

Or

1. Install it as a node module via `npm install wintersmith-handlebars`
2. Follow steps 2 and 3 above.

#### Partials
This plugin provides support for [partials in handlebars](https://github.com/wycats/handlebars.js/#partials).

To start using it, just add a `partials` directory in your template folder and add partial template files in there.

You can also rename this file to any other fancy name you would like. For eg, if you want it to be `bits`, you can simply define that in your `config.json` as follows:

```json
"handlebars": {
  "partialDir": "bits"
}
```
#### Helpers
You can add helpers for Handlebars by adding functions in the helper directory. By default, this direcotry is named `helpers`, and is placed under `templates`. You can specify custom name for this folder in `config.json`:
```json
"handlebars": {
  "helperDir": "helpers"
}
```

Each helper is its own file. The filename will be registered as the helper name.

An example of a helper function:
```js
module.exports = function(stuff) {
  console.log(stuff);
    return;
}
```
See `examples` folder for more information.

#### Note
To use the `locals` variables in the template, instead of writing `{{locals.name}}` like in the jade template, simply just write `{{name}}`. This applies for other variables as well.

See the wiki for a [sample 'locals' context](https://github.com/tnguyen14/wintersmith-handlebars/wiki/Sample-locals-variables) being passed to the compiled handlebars template to see what's available and how to call them.

### Under development
This plugin is my first attempt at bringing support for handlebars to wintersmith. It is still very new, experimental and under development (read: there might be bugs).

If for some reason it doesn't work for me, please submit an issue and I will hopefully fix it.

#### Smith away!
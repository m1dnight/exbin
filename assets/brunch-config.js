exports.config = {
  // See http://brunch.io/#documentation for docs.
  files: {
      javascripts: {
          joinTo: "js/app.js"
      },
      stylesheets: {
          joinTo: "css/app.css",
          order: {
              after: ["css/app.css"] // concat app.css last
          }
      },
      templates: {
          joinTo: "js/app.js"
      }
  },

  conventions: {
      assets: /^(static)/
  },

  // Phoenix paths configuration
  paths: {
      // Dependencies and current project directories to watch
      watched: ["static", "css", "js", "vendor", "scss", "fonts"],
      // Where to compile files to
      public: "../priv/static"
  },

  // Configure your plugins
  plugins: {
      babel: {
          // Do not use ES6 compiler in vendor code
          ignore: [/vendor/]
      },
      sass: {
          native: true,
          options: {
              includePaths: ["node_modules/bootstrap/scss", "node_modules/font-awesome/scss"], // Tell sass-brunch where to look for files to @import
              precision: 8 // Minimum precision required by bootstrap-sass
          }
      },
      copycat: {
        "fonts" : ["static/fonts", "node_modules/font-awesome/fonts"],
        "css" : ["node_modules/highlight.js/styles/atom-one-dark.css"],
        verbose : false, //shows each file that is copied to the destination directory
        onlyChanged: true //only copy a file if it's modified time has changed (only effective when using brunch watch)
      }
  },

  modules: {
      autoRequire: {
          "js/app.js": ["js/app"]
      }
  },

  npm: {
      enabled: true,
      globals: {
          $: 'jquery',
          jQuery: 'jquery',
          Tether: 'tether',
          Popper: "popper.js",
          bootstrap: 'bootstrap',
          hljs: 'highlight.js'
      }
  }
};
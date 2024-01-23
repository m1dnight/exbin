[
  import_deps: [:ecto, :phoenix],
  inputs: ["*.{ex,exs}", "priv/*/seeds.exs", "{config,lib,test}/**/*.{ex,exs}", "rel/overlays/*.{exs}"],
  subdirectories: ["priv/*/migrations"],
  line_length: 120
]

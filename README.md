# Phosphor Icons

This package will import the beautiful icon set from Phosphor Icons including all available variants.

Check them at [Phosphor Icons](https://phosphoricons.com/)!

## Installation

The package can be installed by adding `phosphor_icons` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    # If installing via Git, you MUST include `submodules: true`
    {:phosphor_icons, github: "javiercr/phosphor_icons", submodules: true, compile: false, app: false}
  ]
end
```

The docs can be found at <https://hexdocs.pm/phosphor_icons>.

## Usage with Phoenix <.icon />

If you are using the default Phoenix's `CoreComponents.icon` with Tailwind CSS, you can simply use the icons like this:

```html
<!-- regular styled icons -->
<.icon name="pi-NAME" />

<!-- variants -->
<.icon name="pi-NAME-VARIANT" />
```

where:

- `NAME` is the icon name shown in the [Phosphor Icons website](https://phosphoricons.com/#toolbar).
- `VARIANT` is one of the available variants: `thin`, `light`, `bold`, `fill`, `duotone`

Here are some examples:

```html
<.icon name="pi-drop-thin" />
<.icon name="pi-drop-light" />
<.icon name="pi-drop" /> <!-- regular -->
<.icon name="pi-drop-bold" />
<.icon name="pi-drop-fill" />
<.icon name="pi-drop-duotone" />

<.icon name="pi-drop-half-bottom-thin" />
<.icon name="pi-drop-half-bottom-light" />
<.icon name="pi-drop-half-bottom" /> <!-- regular -->
<.icon name="pi-drop-half-bottom-bold" />
<.icon name="pi-drop-half-bottom-fill" />
<.icon name="pi-drop-half-bottom-duotone" />
```

### Tailwind v4 CSS Config (Phoenix >= 1.8.0)

You can automatically set up the Tailwind CSS v4 plugin for your Phoenix project by running the following mix task:

```bash
mix phosphor_icons.install
```

This task will:
1. Create a `phosphor_icons.js` plugin file in your `assets/vendor` directory.
2. Automatically add the `@plugin "../vendor/phosphor_icons";` directive to your `assets/css/app.css` file.

## Usage of SVG images

This package is simply importing all the SVG icons.

They can be found in your `deps` folder at:
`deps/phosphor_icons/core/raw/VARIANT/NAME.svg` where:

- `VARIANT` is one of the available variant: `thin`, `light`, `regular`, `bold`, `fill`, `duotone`
- `NAME` is the icon name shown in the [Phosphor Icons website](https://phosphoricons.com/#toolbar).

## Disclaimer

This package is not affiliated with Phosphor Icons.

This repo is using the Phosphor Icons Core repository as a source: [`phosphor-icons/core`](https://github.com/phosphor-icons/core).

The version of this package should match the Phosphor Icons version.

## License

MIT
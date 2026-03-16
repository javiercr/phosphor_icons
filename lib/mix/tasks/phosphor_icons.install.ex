defmodule Mix.Tasks.PhosphorIcons.Install do
  use Mix.Task

  @shortdoc "Installs Phosphor Icons Tailwind plugin in a Phoenix project"
  @moduledoc """
  Installs the Phosphor Icons Tailwind plugin.

      $ mix phosphor_icons.install

  This task will:
    1. Create `assets/vendor/phosphor_icons.js`
    2. Add `@plugin "../vendor/phosphor_icons";` to `assets/css/app.css`
  """

  @plugin_code """
  const plugin = require("tailwindcss/plugin")
  const fs = require("fs")
  const path = require("path")

  module.exports = plugin(function({ matchComponents, theme }) {
    let baseDir = path.join(__dirname, "../../deps/phosphor_icons/core/raw")
    // for an umbrella app use the following instead
    // let baseDir = path.join(__dirname, "../../../../deps/phosphor_icons/core/raw")
    let values = {}

    if (!fs.existsSync(baseDir)) {
      throw new Error(
        "Phosphor Icons: The directory " + baseDir + " does not exist.\\n" +
        "If you installed this package from Git, make sure you included the `submodules: true` option in your mix.exs:\\n" +
        "{:phosphor_icons, git: \\"...\\", submodules: true}"
      );
    }

    let icons = fs
      .readdirSync(baseDir, { withFileTypes: true })
      .filter((dirent) => dirent.isDirectory())
      .map((dirent) => dirent.name)

    icons.forEach((dir) => {
      fs.readdirSync(path.join(baseDir, dir)).forEach((file) => {
        if (path.extname(file) === ".svg") {
          let name = path.basename(file, ".svg")
          values[name] = { name, fullPath: path.join(baseDir, dir, file) }
        }
      })
    })

    matchComponents({
      "pi": ({ name, fullPath }) => {
        let content = fs
          .readFileSync(fullPath)
          .toString()
          .replace(/\\r?\\n|\\r/g, "")

        return {
          [`--pi-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
          "-webkit-mask": `var(--pi-${name})`,
          "mask": `var(--pi-${name})`,
          "mask-repeat": "no-repeat",
          "background-color": "currentColor",
          "vertical-align": "middle",
          "display": "inline-block",
          "width": theme("spacing.10"),
          "height": theme("spacing.10")
        }
      }
    }, { values })
  })
  """

  @impl Mix.Task
  def run(_args) do
    create_plugin_file()
    update_app_css()
    update_core_components()
  end

  defp create_plugin_file do
    vendor_dir = "assets/vendor"
    plugin_file = Path.join(vendor_dir, "phosphor_icons.js")

    if File.dir?(vendor_dir) do
      if File.exists?(plugin_file) do
        Mix.shell().info("[:phosphor_icons] #{plugin_file} already exists.")
      else
        File.write!(plugin_file, @plugin_code)
        Mix.shell().info("[:phosphor_icons] Created #{plugin_file}")
      end
    else
      Mix.shell().error(
        "[:phosphor_icons] Directory #{vendor_dir} does not exist. Are you in the root of a Phoenix project?"
      )
    end
  end

  defp update_app_css do
    app_css = "assets/css/app.css"

    if File.exists?(app_css) do
      content = File.read!(app_css)
      plugin_directive = ~s(@plugin "../vendor/phosphor_icons";)

      if String.contains?(content, plugin_directive) do
        Mix.shell().info("[:phosphor_icons] #{app_css} already contains the plugin directive.")
      else
        new_content =
          String.trim_trailing(content) <>
            "\\n\\n/* Phosphor Icons */\\n" <> plugin_directive <> "\\n"

        File.write!(app_css, new_content)
        Mix.shell().info("[:phosphor_icons] Added plugin directive to #{app_css}")
      end
    else
      Mix.shell().error(
        "[:phosphor_icons] #{app_css} does not exist. Cannot append plugin directive."
      )
    end
  end

  defp update_core_components do
    case Path.wildcard("lib/*_web/components/core_components.ex") do
      [file | _] ->
        content = File.read!(file)

        if String.contains?(content, ~s(def icon(%{name: "pi-" <> _})) do
          Mix.shell().info("[:phosphor_icons] #{file} already contains pi- icon function.")
        else
          # Find the heroicon function and insert the phosphor icon function after it
          hero_icon_regex = ~r/def icon\\(%\\{name: "hero-" <> _\\} = assigns\\) do[\\s\\S]*?end/

          phosphor_component = """


            @doc \"\"\"
            Renders a [Phosphoricon](https://phosphoricons.com/).

            Phosphoricons come in six styles – thin, light, regular, bold, fill, and duotone.
            By default, the regular style is used, but bold and duotone may
            be applied by using the `-bold` and `-duotone` suffix.

            You can customize the size and colors of the icons by setting
            width, height, and background color classes.

            Icons are extracted from the `deps/phosphor_icons` directory and bundled within
            your compiled app.css by the plugin in `assets/vendor/phosphor_icons.js`.

            ## Examples

                <.icon name="pi-phosphor-logo" />
                <.icon name="pi-fire" class="ml-1 size-3 motion-safe:animate-spin" />
            \"\"\"
            def icon(%{name: "pi-" <> _} = assigns) do
              ~H\"\"\"
              <span class={[@name, @class]} />
              \"\"\"
            end\
          """

          case Regex.run(hero_icon_regex, content) do
            [match] ->
              new_content = String.replace(content, match, match <> phosphor_component)
              File.write!(file, new_content)
              Mix.shell().info("[:phosphor_icons] Added pi- icon function to #{file}")

            nil ->
              Mix.shell().warning(
                "[:phosphor_icons] Could not find the default `hero-` icon function in #{file}. You may need to add the `pi-` icon function manually."
              )
          end
        end

      [] ->
        Mix.shell().warning(
          "[:phosphor_icons] core_components.ex not found, skipping component injection."
        )
    end
  end
end

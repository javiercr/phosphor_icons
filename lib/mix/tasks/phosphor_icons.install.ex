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
            "\n\n/* Phosphor Icons */\n" <> plugin_directive <> "\n"

        File.write!(app_css, new_content)
        Mix.shell().info("[:phosphor_icons] Added plugin directive to #{app_css}")
      end
    else
      Mix.shell().error(
        "[:phosphor_icons] #{app_css} does not exist. Cannot append plugin directive."
      )
    end
  end
end

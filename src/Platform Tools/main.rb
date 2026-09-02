require 'gtk4'
require 'adwaita'

class PlatformToolsDemo
  TOOLS = [
    ['Adwaita Demo', 'adwaita-1-demo', 'https://gitlab.gnome.org/GNOME/libadwaita/-/tree/1.5.0/demo'],
    ['GTK Demo', 'gtk4-demo', 'https://gitlab.gnome.org/GNOME/gtk/-/tree/4.14.2/demos/gtk-demo'],
    ['GTK Widget Factory', 'gtk4-widget-factory',
     'https://gitlab.gnome.org/GNOME/gtk/-/tree/4.14.2/demos/widget-factory']
  ].freeze

  INSPECTOR_HINT = "As with most GTK applications, you can use the keyboard shortcut\n" \
                   'to open the Inspector and select an object to see what it is made of:'

  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)
        app.add_action(platform_tools_action)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(tools_box)
              b.append(inspector_box)

              tools_box.tap do |box|
                tool_widgets.each { |widget| box.append(widget) }
              end

              inspector_box.tap do |box|
                box.append(inspector_label)
                box.append(inspector_shortcut)
                box.append(inspector_link)
              end
            end
          end
        end

        platform_tools_action.tap do |action|
          action.signal_connect('activate') { |_, target| launch(target.get_string.first) }
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.platformtools', :default_flags)
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0)

  def platform_tools_action
    @platform_tools_action ||= Gio::SimpleAction.new('platform_tools', GLib::VariantType.new('s'))
  end

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Platform Tools'
      win.set_default_size(640, 760)
    end
  end

  def status_page = @status_page ||= Adwaita::StatusPage.new.tap { |page| page.title = 'Platform Tools' }

  def tools_box
    @tools_box ||= Gtk::Box.new(:vertical, 0).tap { |box| box.halign = :center }
  end

  def tool_widgets
    @tool_widgets ||= TOOLS.flat_map { |label, command, source| [tool_button(label, command), source_link(source)] }
  end

  def inspector_box
    @inspector_box ||= Gtk::Box.new(:vertical, 0).tap do |box|
      box.halign = :center
    end
  end

  def inspector_label
    @inspector_label ||= Gtk::Label.new(INSPECTOR_HINT).tap do |label|
      label.justify = :center
      label.add_css_class('body')
    end
  end

  def inspector_shortcut
    @inspector_shortcut ||= Gtk::ShortcutLabel.new('<Control><Shift>I').tap do |shortcut|
      shortcut.halign = :center
      shortcut.margin_top = 6
    end
  end

  def inspector_link
    @inspector_link ||= Gtk::LinkButton.new(
      'https://developer.gnome.org/documentation/tools/inspector.html'
    ).tap do |btn|
      btn.label = 'The GTK Inspector'
      btn.margin_top = 6
      btn.halign = :center
    end
  end

  private

  def tool_button(label, command)
    Gtk::Button.new.tap do |btn|
      btn.label = label
      btn.set_detailed_action_name("app.platform_tools::#{command}")
      btn.add_css_class('pill')
    end
  end

  def source_link(uri)
    Gtk::LinkButton.new(uri).tap do |btn|
      btn.label = 'Source Code'
      btn.margin_bottom = 30
      btn.add_css_class('caption')
    end
  end

  def launch(command)
    Gio::Subprocess.new([command], Gio::SubprocessFlags::NONE)
  rescue GLib::Error => e
    warn "Could not launch #{command}: #{e.message}"
  end
end

PlatformToolsDemo.new.build.run

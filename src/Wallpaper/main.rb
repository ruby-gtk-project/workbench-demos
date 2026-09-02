require 'gtk4'
require 'adwaita'

# libportal has no Ruby gem, so the wallpaper portal is called over D-Bus.
class WallpaperDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(button)
              b.append(reference_button)

              button.tap do |btn|
                btn.signal_connect('clicked') { set_wallpaper }
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.wallpaper', :default_flags)
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0).tap { |box| box.halign = :center }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Wallpaper'
      win.set_default_size(560, 520)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Wallpaper'
      page.description = 'Request to set the user desktop background image'
      page.margin_top = 48
    end
  end

  def button
    @button ||= Gtk::Button.new.tap do |btn|
      btn.label = 'Set Wallpaper…'
      btn.margin_bottom = 42
      btn.halign = :center
      btn.add_css_class('suggested-action')
      btn.add_css_class('pill')
    end
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new('https://libportal.org/method.Portal.set_wallpaper.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end

  def session_bus = @session_bus ||= Gio.bus_get_sync(Gio::BusType::SESSION)

  def portal
    @portal ||= Gio::DBusProxy.new(
      session_bus,
      Gio::DBusProxyFlags::NONE,
      nil,
      'org.freedesktop.portal.Desktop',
      '/org/freedesktop/portal/desktop',
      'org.freedesktop.portal.Wallpaper'
    )
  end

  def wallpaper = @wallpaper ||= Gio::File.new_for_path(File.join(__dir__, 'wallpaper.png'))

  private

  def set_wallpaper
    portal.call_sync(
      'SetWallpaperURI',
      GLib::Variant.new(['', wallpaper.uri, wallpaper_options], '(ssa{sv})'),
      Gio::DBusCallFlags::NONE,
      -1
    ).then { |reply| await_response(reply.get_child_value(0).string) }
  end

  def wallpaper_options
    {
      'show-preview' => GLib::Variant.new(true),
      'set-on' => GLib::Variant.new('both')
    }
  end

  def await_response(request_path)
    session_bus.signal_subscribe(
      'org.freedesktop.portal.Desktop',
      'org.freedesktop.portal.Request',
      'Response',
      request_path,
      nil,
      Gio::DBusSignalFlags::NONE
    ) do |_connection, _sender, _path, _interface, _signal, parameters|
      if parameters.get_child_value(0).get_uint32.zero?
        puts 'Wallpaper set successfully'
      else
        puts 'Could not set wallpaper'
      end
    end
  end
end

WallpaperDemo.new.build.run

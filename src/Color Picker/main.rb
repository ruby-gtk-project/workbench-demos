require 'gtk4'
require 'adwaita'

# libportal has no Ruby bindings, so the screenshot portal's PickColor is
# called directly over D-Bus.
class ColorPickerDemo
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
                btn.signal_connect('clicked') { pick_color }
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.colorpicker', :default_flags)
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0).tap { |box| box.halign = :center }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Color Picker'
      win.set_default_size(560, 520)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Color Picker'
      page.description = 'Pick color from anywhere on-screen'
      page.margin_top = 48
    end
  end

  def button
    @button ||= Gtk::Button.new.tap do |btn|
      btn.label = 'Select Color'
      btn.margin_bottom = 42
      btn.halign = :center
      btn.add_css_class('suggested-action')
      btn.add_css_class('pill')
    end
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new('https://libportal.org/method.Portal.pick_color.html').tap do |btn|
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
      'org.freedesktop.portal.Screenshot'
    )
  end

  private

  def pick_color
    portal.call_sync(
      'PickColor',
      GLib::Variant.new(['', {}], '(sa{sv})'),
      Gio::DBusCallFlags::NONE,
      -1
    ).then { |reply| await_response(reply.get_child_value(0).string) }
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
      report_color(parameters.get_child_value(1)['color'])
    end
  end

  # The portal returns (ddd): red, green and blue components in the range [0,1].
  def report_color(components)
    Gdk::RGBA.new(*(0..2).map { |i| components.get_child_value(i).get_double }, 1.0).then do |color|
      puts "Selected color is: #{color}"
    end
  end
end

ColorPickerDemo.new.build.run

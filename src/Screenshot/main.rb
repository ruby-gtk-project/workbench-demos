require 'gtk4'
require 'adwaita'

# libportal has no Ruby gem, so the screenshot portal is called over D-Bus.
class ScreenshotDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(picture_box)
              b.append(button)
              b.append(reference_button)

              picture_box.tap { |box| box.append(picture) }

              button.tap do |btn|
                btn.signal_connect('clicked') { take_screenshot }
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.screenshot', :default_flags)
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0).tap { |box| box.halign = :center }
  def picture = @picture ||= Gtk::Picture.new

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Screenshot'
      win.set_default_size(560, 640)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Screenshot'
      page.description = 'Take a picture of the screen'
      page.margin_top = 48
    end
  end

  def picture_box
    @picture_box ||= Gtk::Box.new(:horizontal, 0).tap do |box|
      box.margin_bottom = 12
      box.set_size_request(256, 256)
    end
  end

  def button
    @button ||= Gtk::Button.new.tap do |btn|
      btn.label = 'Take Screenshot'
      btn.margin_bottom = 42
      btn.halign = :center
      btn.add_css_class('suggested-action')
    end
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new('https://libportal.org/method.Portal.take_screenshot.html').tap do |btn|
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

  def take_screenshot
    portal.call_sync(
      'Screenshot',
      GLib::Variant.new(['', {}], '(sa{sv})'),
      Gio::DBusCallFlags::NONE,
      -1
    ).then { |reply| await_response(reply.get_child_value(0).string) }
  rescue GLib::Error
    permission_error_dialog.present(window)
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
        picture.file = Gio::File.new_for_uri(parameters.get_child_value(1)['uri'].get_string.first)
      else
        permission_error_dialog.present(window)
      end
    end
  end

  def permission_error_dialog
    @permission_error_dialog ||= Adwaita::AlertDialog.new(
      'Permission Error',
      "Ensure Screenshot permission is enabled in\nSettings → Apps → Workbench"
    ).tap do |dialog|
      dialog.close_response = 'ok'
      dialog.add_response('ok', 'OK')
    end
  end
end

ScreenshotDemo.new.build.run

require 'gtk4'
require 'adwaita'

# libportal has no Ruby bindings, so the email portal is called over D-Bus.
class EmailDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(entry)
              b.append(button)
              b.append(reference_button)

              button.tap do |btn|
                btn.signal_connect('clicked') { compose_email }
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.email', :default_flags)
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0).tap { |box| box.halign = :center }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Email'
      win.set_default_size(560, 560)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Email'
      page.description = 'Trigger an email'
      page.margin_top = 48
    end
  end

  def entry
    @entry ||= Gtk::Entry.new.tap do |e|
      e.input_purpose = :email
      e.placeholder_text = 'Email address'
      e.margin_bottom = 18
    end
  end

  def button
    @button ||= Gtk::Button.new.tap do |btn|
      btn.label = 'Send Email'
      btn.margin_bottom = 42
      btn.halign = :center
      btn.add_css_class('suggested-action')
      btn.add_css_class('pill')
    end
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new('https://libportal.org/method.Portal.compose_email.html').tap do |btn|
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
      'org.freedesktop.portal.Email'
    )
  end

  private

  def compose_email
    portal.call_sync(
      'ComposeEmail',
      GLib::Variant.new(['', options], '(sa{sv})'),
      Gio::DBusCallFlags::NONE,
      -1
    ).then { |reply| await_response(reply.get_child_value(0).string) }
  end

  def options
    {
      'addresses' => GLib::Variant.new([entry.text], 'as'),
      'subject' => GLib::Variant.new('Email from Workbench'),
      'body' => GLib::Variant.new('Hello World!')
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
        puts 'Success'
      else
        puts 'Failure, verify that you have an email application.'
      end
    end
  end
end

EmailDemo.new.build.run

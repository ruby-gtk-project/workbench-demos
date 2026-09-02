require 'gtk4'
require 'adwaita'

# Requests user information through the org.freedesktop.portal.Account XDG portal.
class AccountDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = clamp

            clamp.tap do |c|
              c.child = content_box

              content_box.tap do |b|
                b.append(form_box)
                b.append(revealer)
                b.append(reference_button)

                form_box.tap do |form|
                  form.append(entry)
                  form.append(button)

                  button.tap do |btn|
                    btn.signal_connect('clicked') { request_user_information }
                  end
                end

                revealer.tap do |r|
                  r.child = list_box

                  list_box.tap do |list|
                    list.append(avatar_row)
                    list.append(username_row)
                    list.append(name_row)

                    avatar_row.tap { |row| row.child = avatar }
                    username_row.tap { |row| row.add_suffix(username) }
                    name_row.tap { |row| row.add_suffix(name) }
                  end
                end
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.account', :default_flags)
  def clamp = @clamp ||= Adwaita::Clamp.new.tap { |c| c.maximum_size = 340 }
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0)
  def username = @username ||= Gtk::Label.new('unknown')
  def name = @name ||= Gtk::Label.new('unknown')

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Account'
      win.set_default_size(560, 720)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Account'
      page.description = 'Request information about the user'
      page.margin_top = 48
    end
  end

  def form_box
    @form_box ||= Gtk::Box.new(:vertical, 18).tap do |box|
      box.margin_bottom = 30
    end
  end

  def entry
    @entry ||= Adwaita::EntryRow.new.tap do |row|
      row.title = 'Reason'
      row.halign = :fill
      row.add_css_class('card')
    end
  end

  def button
    @button ||= Gtk::Button.new.tap do |btn|
      btn.label = 'Request'
      btn.halign = :center
      btn.add_css_class('suggested-action')
      btn.add_css_class('pill')
    end
  end

  def revealer
    @revealer ||= Gtk::Revealer.new.tap do |r|
      r.transition_duration = 300
      r.transition_type = :slide_up
    end
  end

  def list_box
    @list_box ||= Gtk::ListBox.new.tap do |list|
      list.selection_mode = :none
      list.margin_bottom = 18
      list.add_css_class('boxed-list')
    end
  end

  def avatar_row = @avatar_row ||= Gtk::ListBoxRow.new.tap { |row| row.activatable = false }
  def username_row = @username_row ||= Adwaita::ActionRow.new.tap { |row| row.title = 'Username' }
  def name_row = @name_row ||= Adwaita::ActionRow.new.tap { |row| row.title = 'Full name' }

  def avatar
    @avatar ||= Adwaita::Avatar.new(80, nil, false).tap do |a|
      a.hexpand = true
      a.margin_top = 18
      a.margin_bottom = 18
    end
  end

  def reference_button
    @reference_button ||=
      Gtk::LinkButton.new('https://libportal.org/method.Portal.get_user_information.html').tap do |btn|
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
      'org.freedesktop.portal.Account'
    )
  end

  private

  # The portal replies asynchronously on a request object path; the reply
  # dictionary carries "id", "name" and "image".
  def request_user_information
    portal.call_sync(
      'GetUserInformation',
      GLib::Variant.new(['', { 'reason' => GLib::Variant.new(entry.text) }], '(sa{sv})'),
      Gio::DBusCallFlags::NONE,
      -1
    ).then do |reply|
      subscribe_to_response(reply.get_child_value(0).string)
      entry.text = ''
    end
  end

  def subscribe_to_response(request_path)
    session_bus.signal_subscribe(
      'org.freedesktop.portal.Desktop',
      'org.freedesktop.portal.Request',
      'Response',
      request_path,
      nil,
      Gio::DBusSignalFlags::NONE
    ) do |_connection, _sender, _path, _interface, _signal, parameters|
      show_user_information(parameters.get_child_value(1))
    end
  end

  def show_user_information(results)
    username.label = results['id'].get_string.first
    name.label = results['name'].get_string.first
    avatar.set_custom_image(Gdk::Texture.new(Gio::File.new_for_uri(results['image'].get_string.first)))
    revealer.reveal_child = true
    puts 'Information retrieved'
  end
end

AccountDemo.new.build.run

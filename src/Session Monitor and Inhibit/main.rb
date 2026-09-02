require 'gtk4'
require 'adwaita'

# libportal has no Ruby gem, so the inhibit portal is called over D-Bus.
class SessionMonitorDemo
  # org.freedesktop.portal.Inhibit flags: 1 logout, 8 idle. Suspend (2) and
  # user switch (4) exist too, but GNOME does not honour them because they do
  # not end the user's session.
  LOGOUT = 1
  IDLE = 8

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
                b.append(entry)
                b.append(actions_label)
                b.append(switches_list)
                b.append(buttons_box)
                b.append(references_box)

                switches_list.tap do |list|
                  list.append(switch_row_logout)
                  list.append(switch_row_idle)
                end

                buttons_box.tap do |box|
                  box.append(button_start)
                  box.append(button_stop)

                  button_start.tap { |btn| btn.signal_connect('clicked') { start_session } }
                  button_stop.tap { |btn| btn.signal_connect('clicked') { stop_session } }
                end

                references_box.tap do |box|
                  box.append(references_title)
                  box.append(references_row)

                  references_row.tap do |row|
                    row.append(monitor_link)
                    row.append(inhibit_link)
                  end
                end
              end
            end
          end
        end

        monitor_session_state

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.sessionmonitor', :default_flags)
  def clamp = @clamp ||= Adwaita::Clamp.new.tap { |c| c.maximum_size = 380 }
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0)
  def request_paths = @request_paths ||= []

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Session Monitor and Inhibit'
      win.set_default_size(640, 760)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Session Monitor and Inhibit'
      page.description = 'Monitor the login session state and inhibit session state changes'
    end
  end

  def entry
    @entry ||= Adwaita::EntryRow.new.tap do |row|
      row.title = 'Reason'
      row.add_css_class('card')
    end
  end

  def actions_label
    @actions_label ||= Gtk::Label.new('Actions to inhibit that can end user’s session').tap do |label|
      label.margin_top = 12
      label.halign = :start
      label.add_css_class('dim-label')
    end
  end

  def switches_list
    @switches_list ||= Gtk::ListBox.new.tap do |list|
      list.selection_mode = :none
      list.add_css_class('boxed-list')
    end
  end

  def switch_row_logout = @switch_row_logout ||= Adwaita::SwitchRow.new.tap { |row| row.title = 'Logout' }
  def switch_row_idle = @switch_row_idle ||= Adwaita::SwitchRow.new.tap { |row| row.title = 'Idle' }

  def buttons_box
    @buttons_box ||= Gtk::Box.new(:horizontal, 0).tap do |box|
      box.margin_top = 12
      box.homogeneous = true
    end
  end

  def button_start
    @button_start ||= Gtk::Button.new.tap do |btn|
      btn.halign = :center
      btn.label = 'Start Session'
      btn.add_css_class('suggested-action')
      btn.add_css_class('pill')
    end
  end

  def button_stop
    @button_stop ||= Gtk::Button.new.tap do |btn|
      btn.halign = :center
      btn.label = 'Stop Session'
      btn.sensitive = false
      btn.add_css_class('destructive-action')
      btn.add_css_class('pill')
    end
  end

  def references_box
    @references_box ||= Gtk::Box.new(:vertical, 0).tap do |box|
      box.margin_top = 24
      box.halign = :center
    end
  end

  def references_title
    @references_title ||= Gtk::Label.new('API References').tap { |label| label.add_css_class('title-2') }
  end

  def references_row = @references_row ||= Gtk::Box.new(:horizontal, 0)

  def monitor_link
    @monitor_link ||= Gtk::LinkButton.new(
      'https://libportal.org/method.Portal.session_monitor_start.html'
    ).tap { |btn| btn.label = 'Session Monitor' }
  end

  def inhibit_link
    @inhibit_link ||= Gtk::LinkButton.new(
      'https://libportal.org/method.Portal.session_inhibit.html'
    ).tap { |btn| btn.label = 'Session Inhibit' }
  end

  def session_bus = @session_bus ||= Gio.bus_get_sync(Gio::BusType::SESSION)

  def portal
    @portal ||= Gio::DBusProxy.new(
      session_bus,
      Gio::DBusProxyFlags::NONE,
      nil,
      'org.freedesktop.portal.Desktop',
      '/org/freedesktop/portal/desktop',
      'org.freedesktop.portal.Inhibit'
    )
  end

  private

  def start_session
    button_start.sensitive = false
    button_stop.sensitive = true

    inhibit(LOGOUT) if switch_row_logout.active?
    inhibit(IDLE) if switch_row_idle.active?
  end

  def inhibit(flags)
    portal.call_sync(
      'Inhibit',
      GLib::Variant.new(['', flags, { 'reason' => GLib::Variant.new(entry.text) }], '(sua{sv})'),
      Gio::DBusCallFlags::NONE,
      -1
    ).then { |reply| request_paths << reply.get_child_value(0).path }
  end

  def stop_session
    request_paths.each { |path| close_request(path) }
    @request_paths = []
    button_start.sensitive = true
    button_stop.sensitive = false
  end

  def close_request(path)
    session_bus.call_sync(
      'org.freedesktop.portal.Desktop', path, 'org.freedesktop.portal.Request',
      'Close', nil, nil, Gio::DBusCallFlags::NONE, -1
    )
  end

  def monitor_session_state
    session_bus.signal_subscribe(
      'org.freedesktop.portal.Desktop',
      'org.freedesktop.portal.Inhibit',
      'StateChanged',
      nil, nil,
      Gio::DBusSignalFlags::NONE
    ) do |_connection, _sender, _path, _interface, _signal, parameters|
      report_state(parameters.get_child_value(1))
    end
  end

  def report_state(state)
    puts 'Screensaver is active' if state['screensaver-active']

    case state['session-state']
    when 1 then puts 'Session: Running'
    when 2 then puts 'Session: Query End'
    when 3 then puts 'Session: Ending'
    end
  end
end

SessionMonitorDemo.new.build.run

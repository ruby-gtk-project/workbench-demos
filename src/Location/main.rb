require 'gtk4'
require 'adwaita'

# libportal has no Ruby gem, so the location portal is driven over D-Bus.
class LocationDemo
  ACCURACIES = ['Exact', 'Street', 'Neighborhood', 'City', 'Country', 'None'].freeze
  # The portal's accuracy levels run none(0) … exact(5), the reverse of the list above.
  ACCURACY_LEVELS = [5, 4, 3, 2, 1, 0].freeze

  READINGS = { 'Latitude' => 'In degrees', 'Longitude' => 'In degrees', 'Accuracy' => 'In meters',
               'Altitude' => 'In meters', 'Speed' => 'In meters per second',
               'Heading' => 'In degrees, clockwise', 'Description' => nil, 'Timestamp' => nil }.freeze

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
                b.append(settings_list)
                b.append(buttons_box)
                b.append(revealer)
                b.append(reference_button)

                settings_list.tap do |list|
                  list.append(distance_threshold)
                  list.append(time_threshold)
                  list.append(accuracy_button)

                  distance_threshold.tap do |row|
                    row.signal_connect('notify::value') { restart('Distance threshold changed') }
                  end

                  time_threshold.tap do |row|
                    row.signal_connect('notify::value') { restart('Time threshold changed') }
                  end

                  accuracy_button.tap do |row|
                    row.signal_connect('notify::selected-item') { restart('Accuracy changed') }
                  end
                end

                buttons_box.tap do |box|
                  box.append(start)
                  box.append(close)

                  start.tap { |btn| btn.signal_connect('clicked') { start_session } }
                  close.tap { |btn| btn.signal_connect('clicked') { close_session } }
                end

                revealer.tap do |r|
                  r.child = readings_list

                  readings_list.tap do |list|
                    reading_rows.each_value { |row| list.append(row) }
                  end
                end
              end
            end
          end
        end

        subscribe_to_updates

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.location', :default_flags)
  def clamp = @clamp ||= Adwaita::Clamp.new.tap { |c| c.maximum_size = 480 }
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0).tap { |box| box.halign = :center }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Location'
      win.set_default_size(640, 900)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Location'
      page.description = 'Request the user location'
      page.margin_top = 48
    end
  end

  def settings_list = @settings_list ||= boxed_list
  def readings_list = @readings_list ||= boxed_list

  def distance_threshold
    @distance_threshold ||= spin_row('Distance Threshold', 'In meters').tap { |row| row.wrap = true }
  end

  def time_threshold = @time_threshold ||= spin_row('Time Threshold', 'In seconds')

  def accuracy_button
    @accuracy_button ||= Adwaita::ComboRow.new.tap do |row|
      row.title = 'Accuracy'
      row.model = Gtk::StringList.new(ACCURACIES)
    end
  end

  def buttons_box
    @buttons_box ||= Gtk::Box.new(:horizontal, 30).tap do |box|
      box.halign = :center
      box.margin_bottom = 24
    end
  end

  def start
    @start ||= Gtk::Button.new.tap do |btn|
      btn.label = 'Start Session'
      btn.halign = :center
      btn.add_css_class('suggested-action')
      btn.add_css_class('pill')
    end
  end

  def close
    @close ||= Gtk::Button.new.tap do |btn|
      btn.label = 'Close Session'
      btn.halign = :center
      btn.sensitive = false
      btn.add_css_class('destructive-action')
      btn.add_css_class('pill')
    end
  end

  def revealer
    @revealer ||= Gtk::Revealer.new.tap do |r|
      r.transition_duration = 300
      r.transition_type = :slide_up
    end
  end

  def reading_labels
    @reading_labels ||= READINGS.keys.to_h { |title| [title, Gtk::Label.new('unknown')] }
  end

  def reading_rows
    @reading_rows ||= READINGS.to_h do |title, subtitle|
      [title, Adwaita::ActionRow.new.tap do |row|
        row.title = title
        row.subtitle = subtitle if subtitle
        row.add_suffix(reading_labels[title])
      end]
    end
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new(
      'https://libportal.org/method.Portal.location_monitor_start.html'
    ).tap { |btn| btn.label = 'API Reference' }
  end

  def session_bus = @session_bus ||= Gio.bus_get_sync(Gio::BusType::SESSION)

  def portal
    @portal ||= Gio::DBusProxy.new(
      session_bus,
      Gio::DBusProxyFlags::NONE,
      nil,
      'org.freedesktop.portal.Desktop',
      '/org/freedesktop/portal/desktop',
      'org.freedesktop.portal.Location'
    )
  end

  def session_path = @session_path

  private

  def boxed_list
    Gtk::ListBox.new.tap do |list|
      list.selection_mode = :none
      list.margin_bottom = 18
      list.add_css_class('boxed-list')
    end
  end

  def spin_row(title, subtitle)
    Adwaita::SpinRow.new(Gtk::Adjustment.new(0, 0, 100, 1, 10, 0), 1, 0).tap do |row|
      row.title = title
      row.subtitle = subtitle
    end
  end

  def start_session
    start.sensitive = false
    close.sensitive = true

    portal.call_sync('CreateSession', GLib::Variant.new([session_options], '(a{sv})'),
                     Gio::DBusCallFlags::NONE, -1).then do |reply|
      @session_path = reply.get_child_value(0).path
      portal.call_sync('Start', GLib::Variant.new([session_path, '', {}], '(osa{sv})'),
                       Gio::DBusCallFlags::NONE, -1)
      puts 'Location access granted'
      revealer.reveal_child = true
    end
  end

  def session_options
    {
      'distance-threshold' => GLib::Variant.new(distance_threshold.value.to_i, 'u'),
      'time-threshold' => GLib::Variant.new(time_threshold.value.to_i, 'u'),
      'accuracy' => GLib::Variant.new(ACCURACY_LEVELS[accuracy_button.selected], 'u')
    }
  end

  def close_session
    start.sensitive = true
    close.sensitive = false
    stop_session
    puts 'Session closed'
  end

  def stop_session
    session_path.then do |path|
      if path
        session_bus.call_sync(
          'org.freedesktop.portal.Desktop', path, 'org.freedesktop.portal.Session',
          'Close', nil, nil, Gio::DBusCallFlags::NONE, -1
        )
        @session_path = nil
      end
    end
    revealer.reveal_child = false
  end

  def restart(message)
    stop_session
    puts message
    start_session
  end

  def subscribe_to_updates
    session_bus.signal_subscribe(
      'org.freedesktop.portal.Desktop',
      'org.freedesktop.portal.Location',
      'LocationUpdated',
      nil, nil,
      Gio::DBusSignalFlags::NONE
    ) do |_connection, _sender, _path, _interface, _signal, parameters|
      show_location(parameters.get_child_value(1))
    end
  end

  def show_location(location)
    reading_labels['Latitude'].label = location['Latitude'].to_s
    reading_labels['Longitude'].label = location['Longitude'].to_s
    reading_labels['Accuracy'].label = location['Accuracy'].to_s
    reading_labels['Altitude'].label = location['Altitude'].to_s
    reading_labels['Speed'].label = location['Speed'].to_s
    reading_labels['Heading'].label = location['Heading'].to_s
    reading_labels['Description'].label = location['Description'].to_s
    reading_labels['Timestamp'].label = Time.at(location['Timestamp'].get_child_value(0).get_uint64).to_s
  end
end

LocationDemo.new.build.run

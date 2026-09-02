require 'gtk4'
require 'adwaita'

# libmanette ships no Ruby gem, so its namespace is loaded straight from the
# typelib through GObject Introspection.
module Manette
  GObjectIntrospection::Loader.load('Manette', self)
end

class GamepadDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(stack)
              b.append(reference_button)

              stack.tap do |s|
                s.add_named(idle_label, 'idle')
                s.add_named(connect_label, 'connect')
                s.add_named(watch_box, 'watch')
                s.visible_child_name = 'connect'

                watch_box.tap do |box|
                  box.append(watch_label)
                  box.append(button_rumble)

                  button_rumble.tap do |btn|
                    btn.signal_connect('clicked') { rumble_all }
                  end
                end
              end
            end
          end
        end

        monitor.tap do |m|
          m.signal_connect('device-connected') { |_, device| add_device(device) }
          m.signal_connect('device-disconnected') { |_, device| remove_device(device) }
        end

        connected_devices

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.gamepad', :default_flags)
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 24).tap { |box| box.halign = :center }
  def stack = @stack ||= Gtk::Stack.new
  def monitor = @monitor ||= Manette::Monitor.new
  def devices = @devices ||= []
  def watch_box = @watch_box ||= Gtk::Box.new(:vertical, 6)

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Gamepad'
      win.set_default_size(640, 520)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Gamepad'
      page.description = 'Respond to gamepads and controllers input'
      page.icon_name = 'gamepad-symbolic'
    end
  end

  def idle_label = @idle_label ||= title('Press Run')
  def connect_label = @connect_label ||= title('Please connect a controller')
  def watch_label = @watch_label ||= title('Press buttons on the controller and watch the Console')

  def button_rumble
    @button_rumble ||= Gtk::Button.new.tap do |btn|
      btn.label = 'Rumble'
      btn.halign = :center
    end
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new('https://gnome.pages.gitlab.gnome.org/libmanette/').tap do |btn|
      btn.label = 'API Reference'
    end
  end

  private

  def title(text)
    Gtk::Label.new(text).tap { |label| label.add_css_class('title-2') }
  end

  def connected_devices
    monitor.iterate.tap do |iterator|
      loop do
        has_next, device = iterator.next
        add_device(device) if device
        break unless has_next
      end
    end
  end

  def add_device(device)
    puts "Device connected: #{device.name}"

    device.signal_connect('button-press-event') { |dev, event| report(dev, 'press', event) }
    device.signal_connect('button-release-event') { |dev, event| report(dev, 'release', event) }
    device.signal_connect('hat-axis-event') { |dev, event| report_hat(dev, event) }
    device.signal_connect('absolute-axis-event') { |dev, event| report_axis(dev, event) }

    devices << device
    stack.visible_child_name = 'watch'
  end

  def remove_device(device)
    puts "Device Disconnected: #{device.name}"

    devices.delete(device)
    stack.visible_child_name = devices.empty? ? 'connect' : 'watch'
  end

  def report(device, action, event)
    success, button = event.button
    puts "#{device.name}: #{action} #{success ? button : event.hardware_code}"
  end

  def report_hat(device, event)
    _success, axis, value = event.hat
    puts "#{device.name}: moved axis #{axis} to #{value}"
  end

  def report_axis(device, event)
    _success, axis, value = event.absolute
    puts "#{device.name}: moved axis #{axis} to #{value}" if value.abs > 0.2
  end

  def rumble_all
    devices.each { |device| device.rumble(1000, 1500, 200) if device.has_rumble? }
  end
end

GamepadDemo.new.build.run

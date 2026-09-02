require 'gtk4'
require 'adwaita'

class PowerProfileMonitorDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = overlay

          overlay.tap do |o|
            o.child = status_page

            status_page.tap do |page|
              page.child = content_box

              content_box.tap do |b|
                b.append(hint_box)
                b.append(reference_button)

                hint_box.tap do |box|
                  box.append(hint_icon)
                  box.append(hint_label)
                end
              end
            end
          end
        end

        power_profile_monitor.tap do |monitor|
          monitor.signal_connect('notify::power-saver-enabled') do
            overlay.add_toast(toast_for(monitor.power_saver_enabled?))
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.powerprofilemonitor', :default_flags)
  def overlay = @overlay ||= Adwaita::ToastOverlay.new
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 24)
  def power_profile_monitor = @power_profile_monitor ||= Gio::PowerProfileMonitor.dup_default

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Power Profile Monitor'
      win.set_default_size(640, 480)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Power Profile Monitor'
      page.description = 'Monitor Power Mode'
    end
  end

  def hint_box
    @hint_box ||= Gtk::Box.new(:horizontal, 6).tap { |box| box.halign = :center }
  end

  def hint_icon
    @hint_icon ||= Gtk::Image.new.tap do |image|
      image.icon_name = 'dialog-information-symbolic'
      image.add_css_class('dim-label')
    end
  end

  def hint_label
    @hint_label ||= Gtk::Label.new(
      "Try toggling on and off “Power Saver“ from Settings → Power\n or from Quick Toggles"
    ).tap { |label| label.add_css_class('dim-label') }
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new('https://docs.gtk.org/gio/iface.PowerProfileMonitor.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end

  private

  def toast_for(enabled)
    Adwaita::Toast.new(enabled ? 'Power Saver Enabled' : 'Power Saver Disabled').tap do |toast|
      toast.priority = Adwaita::ToastPriority::HIGH
    end
  end
end

PowerProfileMonitorDemo.new.build.run

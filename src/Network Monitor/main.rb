require 'gtk4'
require 'adwaita'

class NetworkMonitorDemo
  METERED_STEPS = [
    'To mark your network as metered',
    '1. Go to Settings > Wi-Fi',
    "2. Click on the gear next to your network's name",
    '3. Check off “Metered connection: has data limits or can incur charges”',
    '4. Apply the changes and reconnect to the network'
  ].freeze

  CONNECTIVITY_LABELS = ['Local', 'Limited', 'Portal', 'Full'].freeze

  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        Gtk::StyleContext.add_provider_for_display(
          Gdk::Display.default, css_provider, Gtk::StyleProvider::PRIORITY_APPLICATION
        )

        window.tap do |win|
          win.child = root_box

          root_box.tap do |root|
            root.append(banner)
            root.append(status_page)

            status_page.tap do |page|
              page.child = content_box

              content_box.tap do |b|
                b.append(metered_row)
                b.append(connectivity_section)
                b.append(reference_button)

                metered_row.tap do |row|
                  row.append(metered_labels)
                  row.append(metered_info_button)

                  metered_labels.tap do |labels|
                    labels.append(metered_title)
                    labels.append(metered_subtitle)
                  end

                  metered_info_button.tap { |btn| btn.popover = metered_popover }
                end

                connectivity_section.tap do |section|
                  section.append(connectivity_row)
                  section.append(connectivity_bar_box)

                  connectivity_row.tap do |row|
                    row.append(connectivity_labels)
                    row.append(connectivity_info_button)

                    connectivity_labels.tap do |labels|
                      labels.append(connectivity_title)
                      labels.append(connectivity_subtitle)
                    end

                    connectivity_info_button.tap { |btn| btn.popover = connectivity_popover }
                  end

                  connectivity_bar_box.tap do |box|
                    box.append(level_bar)
                    box.append(connectivity_legend)

                    connectivity_legend.tap do |legend|
                      CONNECTIVITY_LABELS.each { |text| legend.append(Gtk::Label.new(text)) }
                    end
                  end
                end
              end
            end
          end
        end

        network_monitor.tap do |monitor|
          monitor.signal_connect('network-changed') { set_network_status }
        end

        set_network_status

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.networkmonitor', :default_flags)
  def root_box = @root_box ||= Gtk::Box.new(:vertical, 0)
  def network_monitor = @network_monitor ||= Gio::NetworkMonitor.default
  def metered_row = @metered_row ||= info_row
  def connectivity_row = @connectivity_row ||= info_row
  def metered_labels = @metered_labels ||= Gtk::Box.new(:vertical, 6)
  def connectivity_labels = @connectivity_labels ||= Gtk::Box.new(:vertical, 6)
  def connectivity_bar_box = @connectivity_bar_box ||= Gtk::Box.new(:vertical, 12)

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Network Monitor'
      win.set_default_size(720, 700)
    end
  end

  def css_provider
    @css_provider ||= Gtk::CssProvider.new.tap { |provider| provider.load_from_path(File.join(__dir__, 'main.css')) }
  end

  def banner
    @banner ||= Adwaita::Banner.new('Metered Network — syncing paused').tap do |bar|
      bar.button_label = 'Resume'
      bar.use_markup = true
      bar.revealed = false
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Network Monitor'
      page.description = 'Monitor network status'
      page.vexpand = true
    end
  end

  def content_box
    @content_box ||= Gtk::Box.new(:vertical, 54).tap { |box| box.halign = :center }
  end

  def metered_title = @metered_title ||= title('Network Metered')
  def metered_subtitle = @metered_subtitle ||= subtitle('Check if your network is metered')
  def connectivity_title = @connectivity_title ||= title('Network Connectivity')
  def connectivity_subtitle = @connectivity_subtitle ||= subtitle('Check your network connectivity status')

  def metered_info_button = @metered_info_button ||= info_button
  def connectivity_info_button = @connectivity_info_button ||= info_button

  def metered_popover
    @metered_popover ||= Gtk::Popover.new.tap do |popover|
      popover.child = Gtk::Box.new(:vertical, 12).tap do |steps|
        steps.margin_top = 6
        steps.margin_bottom = 6
        steps.margin_start = 6
        steps.margin_end = 6
        METERED_STEPS.each { |text| steps.append(Gtk::Label.new(text).tap { |l| l.halign = :start }) }
      end
    end
  end

  def connectivity_popover
    @connectivity_popover ||= Gtk::Popover.new.tap do |popover|
      popover.child = Gtk::Box.new(:horizontal, 0).tap do |box|
        box.margin_top = 6
        box.margin_bottom = 6
        box.margin_start = 6
        box.margin_end = 6
        box.append(Gtk::Label.new('You can try turning your network off/on'))
      end
    end
  end

  def connectivity_section
    @connectivity_section ||= Gtk::Box.new(:vertical, 24).tap { |box| box.halign = :center }
  end

  def level_bar
    @level_bar ||= Gtk::LevelBar.new.tap do |bar|
      bar.mode = :discrete
      bar.min_value = 0
      bar.max_value = 4
    end
  end

  def connectivity_legend
    @connectivity_legend ||= Gtk::Box.new(:horizontal, 0).tap { |box| box.homogeneous = true }
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new('https://docs.gtk.org/gio/iface.NetworkMonitor.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end

  private

  def info_row
    Gtk::Box.new(:horizontal, 0).tap { |box| box.homogeneous = true }
  end

  def title(text)
    Gtk::Label.new(text).tap do |label|
      label.halign = :start
      label.add_css_class('title-4')
    end
  end

  def subtitle(text)
    Gtk::Label.new(text).tap do |label|
      label.halign = :start
      label.add_css_class('dim-label')
    end
  end

  def info_button
    Gtk::MenuButton.new.tap do |btn|
      btn.halign = :end
      btn.valign = :center
      btn.icon_name = 'dialog-information-symbolic'
    end
  end

  def set_network_status
    banner.revealed = network_monitor.network_metered?
    level_bar.value = network_monitor.connectivity.to_i
  end
end

NetworkMonitorDemo.new.build.run

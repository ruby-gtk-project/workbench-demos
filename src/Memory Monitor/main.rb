require 'gtk4'
require 'adwaita'

class MemoryMonitorDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap { |page| page.child = reference_button }
        end

        memory_monitor.tap do |monitor|
          monitor.signal_connect('low-memory-warning') { |_, level| report(level) }
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.memorymonitor', :default_flags)
  def memory_monitor = @memory_monitor ||= Gio::MemoryMonitor.dup_default
  def cache = @cache ||= { 'a' => 1, 'b' => 2, 'c' => 3 }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Memory Monitor'
      win.set_default_size(560, 420)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Memory Monitor'
      page.description = 'Monitor system memory'
    end
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new('https://docs.gtk.org/gio/iface.MemoryMonitor.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end

  private

  # Compare with inequalities: new levels may be added in the future.
  def report(level)
    if level >= Gio::MemoryMonitorWarningLevel::LOW
      # Processes should free up unneeded resources.
      puts 'Warning Level: Low'
      cache.clear
    end

    # Processes should try harder to free up unneeded resources.
    puts 'Warning Level: Medium' if level >= Gio::MemoryMonitorWarningLevel::MEDIUM

    # The system will start terminating processes to reclaim memory.
    puts 'Warning Level: Critical' if level >= Gio::MemoryMonitorWarningLevel::CRITICAL
  end
end

MemoryMonitorDemo.new.build.run

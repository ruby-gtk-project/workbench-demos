require 'gtk4'
require 'adwaita'

class CalendarDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(calendar)
              b.append(reference_button)

              calendar.tap do |cal|
                cal.signal_connect('notify::day') { puts cal.date.format('%e') }
                cal.signal_connect('notify::month') { puts cal.date.format('%B') }
                cal.signal_connect('notify::year') { puts cal.date.format('%Y') }
                cal.signal_connect('day-selected') { puts cal.date.format_iso8601 }
                cal.mark_day(15)
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.calendar', :default_flags)
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0).tap { |box| box.halign = :center }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Calendar'
      win.set_default_size(560, 600)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Calendar'
      page.description = 'Display a Gregorian calendar, one month at a time'
    end
  end

  def calendar
    @calendar ||= Gtk::Calendar.new.tap do |cal|
      cal.show_day_names = true
      cal.show_week_numbers = false
      cal.show_heading = true
      cal.margin_bottom = 18
      cal.day = 1
    end
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.Calendar.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end
end

CalendarDemo.new.build.run

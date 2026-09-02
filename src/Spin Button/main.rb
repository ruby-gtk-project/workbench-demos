require 'gtk4'
require 'adwaita'

class SpinButtonDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(title_label)
              b.append(time_box)
              b.append(links_box)

              time_box.tap do |box|
                box.append(hours)
                box.append(colon_label)
                box.append(minutes)

                hours.tap do |spin|
                  spin.text = '00'
                  spin.signal_connect('output') { pad(spin) }
                  spin.signal_connect('value-changed') { puts tell_time }
                end

                minutes.tap do |spin|
                  spin.text = '00'
                  spin.signal_connect('output') { pad(spin) }
                  spin.signal_connect('value-changed') { puts tell_time }
                  # Only covers one direction; wrapping backwards needs extra logic.
                  spin.signal_connect('wrapped') { hours.spin(:step_forward, 1) }
                end
              end

              links_box.tap do |box|
                box.append(tutorial_link)
                box.append(reference_link)
                box.append(hig_link)
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.spinbutton', :default_flags)
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 12)
  def colon_label = @colon_label ||= Gtk::Label.new(':')
  def links_box = @links_box ||= Gtk::Box.new(:vertical, 0)

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Spin Button'
      win.set_default_size(560, 620)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Spin Button'
      page.description = 'Let users choose a precise numerical value'
    end
  end

  def title_label
    @title_label ||= Gtk::Label.new('Select Time').tap { |label| label.add_css_class('title-4') }
  end

  def time_box
    @time_box ||= Gtk::Box.new(:horizontal, 6).tap { |box| box.halign = :center }
  end

  def hours = @hours ||= time_spin_button(23)
  def minutes = @minutes ||= time_spin_button(59)

  def tutorial_link
    @tutorial_link ||= Gtk::LinkButton.new(
      'https://developer.gnome.org/documentation/tutorials/beginners/components/spin_button.html'
    ).tap { |btn| btn.label = 'Tutorial' }
  end

  def reference_link
    @reference_link ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.SpinButton.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end

  def hig_link
    @hig_link ||= Gtk::LinkButton.new(
      'https://developer.gnome.org/hig/patterns/controls/spin-buttons.html'
    ).tap { |btn| btn.label = 'Human Interface Guidelines' }
  end

  private

  def time_spin_button(upper)
    Gtk::SpinButton.new(Gtk::Adjustment.new(0, 0, upper, 1, 10, 0), 1, 0).tap do |spin|
      spin.halign = :center
      spin.orientation = :vertical
      spin.wrap = true
    end
  end

  def pad(spin)
    spin.text = format('%02d', spin.adjustment.value.to_i)
    true
  end

  def tell_time
    "The time selected is #{hours.text}:#{minutes.text}"
  end
end

SpinButtonDemo.new.build.run

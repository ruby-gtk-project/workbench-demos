require 'gtk4'
require 'adwaita'

LOREM = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut ' \
        'labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco ' \
        'laboris nisi ut aliquip ex ea commodo consequat. '

class ClampDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(buttons_box)
              b.append(reference_button)
              b.append(clamp)

              buttons_box.tap do |box|
                box.append(button_increase)
                box.append(button_decrease)

                button_increase.tap { |btn| btn.signal_connect('clicked') { resize(300, 200) } }
                button_decrease.tap { |btn| btn.signal_connect('clicked') { resize(-300, -200) } }
              end

              clamp.tap { |c| c.child = label }
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.clamp', :default_flags)
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0).tap { |box| box.halign = :center }
  def label = @label ||= Gtk::Label.new(LOREM).tap { |l| l.wrap = true }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Clamp'
      win.set_default_size(720, 600)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Clamp'
      page.description = 'A widget constraining its child to a given size'
    end
  end

  def buttons_box
    @buttons_box ||= Gtk::Box.new(:horizontal, 6).tap { |box| box.halign = :center }
  end

  def button_increase = @button_increase ||= Gtk::Button.new.tap { |btn| btn.icon_name = 'list-add-symbolic' }
  def button_decrease = @button_decrease ||= Gtk::Button.new.tap { |btn| btn.icon_name = 'list-remove-symbolic' }

  def clamp
    @clamp ||= Adwaita::Clamp.new.tap do |c|
      c.maximum_size = 400
      c.tightening_threshold = 200
      c.margin_top = 24
      c.margin_bottom = 24
    end
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new(
      'https://gnome.pages.gitlab.gnome.org/libadwaita/doc/1.6/class.Clamp.html'
    ).tap do |btn|
      btn.label = 'API Reference'
      btn.margin_top = 12
    end
  end

  private

  def resize(size_delta, threshold_delta)
    clamp.maximum_size += size_delta
    clamp.tightening_threshold += threshold_delta

    puts 'Maximum size reached' if clamp.tightening_threshold == 1000
    puts 'Minimum size reached' if clamp.tightening_threshold.zero?
  end
end

ClampDemo.new.build.run

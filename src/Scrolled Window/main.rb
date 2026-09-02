require 'gtk4'
require 'adwaita'

class ScrolledWindowDemo
  ITEM_COUNT = 20

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
                b.append(controls_box)
                b.append(scrolled_window)
                b.append(reference_button)

                controls_box.tap do |controls|
                  controls.append(orientation_label)
                  controls.append(orientation_toggles)
                  controls.append(goto_label)
                  controls.append(goto_buttons)

                  orientation_toggles.tap do |toggles|
                    toggles.append(toggle_orientation)
                    toggles.append(toggle_vertical)

                    toggle_orientation.tap do |btn|
                      btn.signal_connect('toggled') do
                        container.orientation = btn.active? ? :horizontal : :vertical
                      end
                    end
                  end

                  goto_buttons.tap do |buttons|
                    buttons.append(button_start)
                    buttons.append(button_end)

                    button_start.tap { |btn| btn.signal_connect('clicked') { scroll_to(0) } }
                    button_end.tap { |btn| btn.signal_connect('clicked') { scroll_to(1) } }
                  end
                end

                scrolled_window.tap do |sw|
                  sw.child = container
                  sw.signal_connect('edge-reached') { puts 'Edge Reached' }

                  container.tap do |box|
                    (1..ITEM_COUNT).each { |index| box.append(card("Item #{index}")) }
                  end
                end
              end
            end
          end
        end

        scrollbars.each_value do |scrollbar|
          scrollbar.adjustment.signal_connect('value-changed') { sync_buttons(scrollbar.adjustment) }
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.scrolledwindow', :default_flags)
  def clamp = @clamp ||= Adwaita::Clamp.new
  def orientation_label = @orientation_label ||= Gtk::Label.new('Orientation')
  def goto_label = @goto_label ||= Gtk::Label.new('Go To')
  def container = @container ||= Gtk::Box.new(:horizontal, 0).tap { |box| box.homogeneous = true }
  def auto_scrolling = @auto_scrolling ||= false

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Scrolled Window'
      win.set_default_size(760, 720)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Scrolled Window'
      page.description = 'A container that makes its child scrollable'
    end
  end

  def content_box
    @content_box ||= Gtk::Box.new(:vertical, 12).tap do |box|
      box.hexpand = true
      box.vexpand = true
    end
  end

  def controls_box
    @controls_box ||= Gtk::Box.new(:horizontal, 18).tap { |box| box.halign = :center }
  end

  def orientation_toggles
    @orientation_toggles ||= Gtk::Box.new(:horizontal, 0).tap do |box|
      box.margin_start = 6
      box.homogeneous = true
      box.halign = :center
      box.add_css_class('linked')
    end
  end

  def toggle_orientation
    @toggle_orientation ||= Gtk::ToggleButton.new.tap do |btn|
      btn.label = 'Horizontal'
      btn.active = true
    end
  end

  def toggle_vertical
    @toggle_vertical ||= Gtk::ToggleButton.new.tap do |btn|
      btn.label = 'Vertical'
      btn.group = toggle_orientation
    end
  end

  def goto_buttons
    @goto_buttons ||= Gtk::Box.new(:horizontal, 0).tap { |box| box.add_css_class('linked') }
  end

  def button_start
    @button_start ||= Gtk::Button.new.tap do |btn|
      btn.label = 'Start'
      btn.sensitive = false
    end
  end

  def button_end = @button_end ||= Gtk::Button.new.tap { |btn| btn.label = 'End' }

  def scrolled_window
    @scrolled_window ||= Gtk::ScrolledWindow.new.tap do |sw|
      sw.margin_top = 24
      sw.margin_bottom = 24
      sw.has_frame = true
      sw.propagate_natural_height = true
      sw.max_content_height = 300
    end
  end

  def scrollbars
    @scrollbars ||= { horizontal: scrolled_window.hscrollbar, vertical: scrolled_window.vscrollbar }
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.ScrolledWindow.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end

  private

  def card(label)
    Adwaita::Bin.new.tap do |bin|
      bin.margin_top = 6
      bin.margin_bottom = 6
      bin.margin_start = 6
      bin.margin_end = 6
      bin.add_css_class('card')
      bin.child = Gtk::Label.new(label).tap { |l| l.set_size_request(100, 100) }
    end
  end

  def sync_buttons(adjustment)
    if adjustment.value == adjustment.lower
      button_end.sensitive = true
      button_start.sensitive = false
    elsif adjustment.value == adjustment.upper - adjustment.page_size
      button_end.sensitive = false
      button_start.sensitive = true
    else
      # Both stay disabled while the scrollbar animates on its own.
      button_end.sensitive = !auto_scrolling
      button_start.sensitive = !auto_scrolling
    end
  end

  # direction 0 animates to the start, 1 to the end.
  def scroll_to(direction)
    @auto_scrolling = true
    scrollbars[container.orientation].then { |scrollbar| scroll_animation(scrollbar, direction).play }
  end

  def scroll_animation(scrollbar, direction)
    scrollbar.adjustment.then do |adjustment|
      Adwaita::TimedAnimation.new(
        scrollbar,
        adjustment.value,
        direction.zero? ? 0 : adjustment.upper - adjustment.page_size,
        1000,
        Adwaita::PropertyAnimationTarget.new(adjustment, 'value')
      ).tap do |animation|
        animation.easing = Adwaita::Easing::LINEAR
        animation.signal_connect('done') { @auto_scrolling = false }
      end
    end
  end
end

ScrolledWindowDemo.new.build.run

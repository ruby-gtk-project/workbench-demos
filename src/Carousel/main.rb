require 'gtk4'
require 'adwaita'

class CarouselDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = root_box

          root_box.tap do |root|
            root.append(carousel)
            root.append(indicators)

            carousel.tap do |c|
              c.append(first_page)
              c.append(settings_clamp)
              c.append(last_page)
              c.signal_connect('page-changed') { puts 'Page Changed' }

              first_page.tap { |page| page.child = first_page_link }

              settings_clamp.tap do |clamp|
                clamp.child = settings_group

                settings_group.tap do |group|
                  group.add(orientation_row)
                  group.add(indicator_row)
                  group.add(sw_switch)
                  group.add(ls_switch)

                  sw_switch.tap do |row|
                    row.active = c.allow_scroll_wheel?
                    row.signal_connect('notify::active') { c.allow_scroll_wheel = row.active? }
                  end

                  ls_switch.tap do |row|
                    row.active = c.allow_long_swipes?
                    row.signal_connect('notify::active') { c.allow_long_swipes = row.active? }
                  end

                  indicator_row.tap do |row|
                    row.signal_connect('notify::selected-item') { swap_indicators }
                  end

                  orientation_row.tap do |row|
                    row.signal_connect('notify::selected-item') { apply_orientation(row.selected.zero?) }
                  end
                end
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.carousel', :default_flags)
  def settings_group = @settings_group ||= Adwaita::PreferencesGroup.new.tap { |g| g.add_css_class('boxed-list') }
  def sw_switch = @sw_switch ||= Adwaita::SwitchRow.new.tap { |row| row.title = 'Allow Scroll Wheel' }
  def ls_switch = @ls_switch ||= Adwaita::SwitchRow.new.tap { |row| row.title = 'Allow Long Swipes' }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Carousel'
      win.set_default_size(720, 620)
    end
  end

  def root_box
    @root_box ||= Gtk::Box.new(:vertical, 12).tap do |box|
      box.valign = :center
      box.halign = :center
    end
  end

  def carousel
    @carousel ||= Adwaita::Carousel.new.tap do |c|
      c.halign = :center
      c.valign = :center
      c.allow_long_swipes = true
      c.allow_scroll_wheel = true
      c.spacing = 12
    end
  end

  def first_page
    @first_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Carousel'
      page.description = 'Swipe or scroll to navigate'
      page.icon_name = 'carousel-symbolic'
    end
  end

  def first_page_link
    @first_page_link ||= Gtk::LinkButton.new(
      'https://gnome.pages.gitlab.gnome.org/libadwaita/doc/1.6/class.Carousel.html'
    ).tap do |btn|
      btn.label = 'API Reference'
      btn.margin_top = 12
    end
  end

  def settings_clamp
    @settings_clamp ||= Adwaita::Clamp.new.tap do |clamp|
      clamp.maximum_size = 700
      clamp.halign = :center
      clamp.valign = :center
    end
  end

  def last_page
    @last_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Last Page'
      page.description = 'You’ve reached the end of the carousel'
    end
  end

  def orientation_row
    @orientation_row ||= Adwaita::ComboRow.new.tap do |row|
      row.title = 'Carousel Orientation'
      row.model = Gtk::StringList.new(%w[Horizontal Vertical])
    end
  end

  def indicator_row
    @indicator_row ||= Adwaita::ComboRow.new.tap do |row|
      row.title = 'Page Indicators'
      row.model = Gtk::StringList.new(%w[Dots Lines])
    end
  end

  def indicators
    @indicators ||= build_indicators
  end

  private

  def build_indicators
    (indicator_row.selected.zero? ? Adwaita::CarouselIndicatorDots.new : Adwaita::CarouselIndicatorLines.new)
      .tap do |widget|
        widget.carousel = carousel
        widget.orientation = carousel.orientation
      end
  end

  def swap_indicators
    root_box.remove(indicators)
    @indicators = build_indicators
    root_box.append(indicators)
  end

  def apply_orientation(horizontal)
    root_box.orientation = horizontal ? :vertical : :horizontal
    carousel.orientation = horizontal ? :horizontal : :vertical
    indicators.orientation = carousel.orientation
  end
end

CarouselDemo.new.build.run

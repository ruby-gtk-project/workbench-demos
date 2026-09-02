require 'gtk4'
require 'adwaita'

# libshumate has no Ruby gem; its namespace comes straight from the typelib.
module Shumate
  GObjectIntrospection::Loader.load('Shumate', self)
end

class MapDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        Gtk::StyleContext.add_provider_for_display(
          Gdk::Display.default, css_provider, Gtk::StyleProvider::PRIORITY_APPLICATION
        )

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = clamp

            clamp.tap do |c|
              c.child = content_box

              content_box.tap do |b|
                b.append(controls)
                b.append(map_widget)
                b.append(reference_button)

                controls.tap do |bar|
                  bar.append(coordinates_box)
                  bar.append(separator)
                  bar.append(tools_box)

                  coordinates_box.tap do |box|
                    box.append(entry_latitude)
                    box.append(entry_longitude)
                    box.append(button_go)

                    button_go.tap { |btn| btn.signal_connect('clicked') { go_to_location } }
                    entry_latitude.tap { |e| e.signal_connect('activate') { go_to_location } }
                    entry_longitude.tap { |e| e.signal_connect('activate') { go_to_location } }
                  end

                  tools_box.tap do |box|
                    box.append(button_move)
                    box.append(button_marker)
                  end
                end

                map_widget.tap do |widget|
                  widget.map_source = map_source
                  widget.map.center_on(0, 0)
                  widget.map.add_layer(marker_layer)
                  widget.add_controller(gesture)
                end
              end
            end
          end
        end

        viewport.tap do |vp|
          vp.reference_map_source = map_source
          vp.zoom_level = 5
        end

        marker_layer.add_marker(marker)

        gesture.tap do |g|
          g.signal_connect('pressed') { |_, _n_press, x, y| place_marker(x, y) }
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.map', :default_flags)
  def clamp = @clamp ||= Adwaita::Clamp.new
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0)
  def separator = @separator ||= Gtk::Separator.new(:vertical)
  def gesture = @gesture ||= Gtk::GestureClick.new
  # shumate_map_source_registry_new_with_defaults is not exposed as a Ruby
  # constructor; populate the registry explicitly instead.
  def registry = @registry ||= Shumate::MapSourceRegistry.new.tap(&:populate_defaults)
  def map_source = @map_source ||= registry.get_by_id(Shumate::MAP_SOURCE_OSM_MAPNIK)
  def viewport = @viewport ||= map_widget.viewport

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Map'
      win.set_default_size(800, 720)
    end
  end

  def css_provider
    @css_provider ||= Gtk::CssProvider.new.tap { |provider| provider.load_from_path(File.join(__dir__, 'main.css')) }
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Map'
      page.description = 'Display an interactive map'
    end
  end

  def controls
    @controls ||= Gtk::Box.new(:horizontal, 6).tap do |box|
      box.halign = :center
      box.add_css_class('toolbar')
    end
  end

  def coordinates_box
    @coordinates_box ||= Gtk::Box.new(:horizontal, 0).tap { |box| box.add_css_class('linked') }
  end

  def tools_box
    @tools_box ||= Gtk::Box.new(:horizontal, 0).tap { |box| box.add_css_class('linked') }
  end

  def entry_latitude = @entry_latitude ||= coordinate_entry('Latitude')
  def entry_longitude = @entry_longitude ||= coordinate_entry('Longitude')
  def button_go = @button_go ||= Gtk::Button.new.tap { |btn| btn.label = 'Go' }

  def button_move
    @button_move ||= Gtk::ToggleButton.new.tap do |btn|
      btn.active = true
      btn.icon_name = 'move-tool-symbolic'
      btn.tooltip_text = 'Move Map'
    end
  end

  def button_marker
    @button_marker ||= Gtk::ToggleButton.new.tap do |btn|
      btn.group = button_move
      btn.icon_name = 'map-marker-symbolic'
      btn.tooltip_text = 'Place Marker'
    end
  end

  def map_widget
    @map_widget ||= Shumate::SimpleMap.new.tap do |widget|
      widget.height_request = 360
      widget.show_zoom_buttons = true
    end
  end

  def marker_layer
    @marker_layer ||= Shumate::MarkerLayer.new(viewport).tap { |layer| layer.selection_mode = :single }
  end

  def marker
    @marker ||= Shumate::Marker.new.tap do |m|
      m.child = Gtk::Image.new.tap do |image|
        image.icon_name = 'map-marker-symbolic'
        image.add_css_class('map-marker')
      end
      m.set_location(0, 0)
    end
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new('https://gnome.pages.gitlab.gnome.org/libshumate/index.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end

  private

  def coordinate_entry(placeholder)
    Gtk::Entry.new.tap do |entry|
      entry.input_purpose = :digits
      entry.placeholder_text = placeholder
    end
  end

  def place_marker(x, y)
    button_marker.active?.then do |placing|
      if placing
        viewport.widget_coords_to_location(map_widget, x, y).then do |latitude, longitude|
          marker.set_location(latitude, longitude)
          puts "Marker placed at #{latitude}, #{longitude}"
        end
      end
    end
  end

  def go_to_location
    coordinates.then do |latitude, longitude|
      if latitude.nil? || longitude.nil?
        puts 'Please enter valid coordinates'
      elsif !latitude.between?(Shumate::MIN_LATITUDE, Shumate::MAX_LATITUDE)
        puts "Latitudes must be between #{Shumate::MIN_LATITUDE} and #{Shumate::MAX_LATITUDE}"
      elsif !longitude.between?(Shumate::MIN_LONGITUDE, Shumate::MAX_LONGITUDE)
        puts "Longitudes must be between #{Shumate::MIN_LONGITUDE} and #{Shumate::MAX_LONGITUDE}"
      else
        viewport.zoom_level = 5
        map_widget.map.go_to(latitude, longitude)
      end
    end
  end

  def coordinates
    [Float(entry_latitude.text, exception: false), Float(entry_longitude.text, exception: false)]
  end
end

MapDemo.new.build.run

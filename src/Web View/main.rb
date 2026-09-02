require 'gtk4'
require 'adwaita'

# WebKitGTK 6 has no Ruby gem; its namespace comes straight from the typelib.
module WebKit
  GObjectIntrospection::Loader.load('WebKit', self)
end

class WebViewDemo
  HOME_URI = 'https://www.gnome.org/'

  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = clamp

          clamp.tap do |c|
            c.child = content_box

            content_box.tap do |b|
              b.append(header_box)
              b.append(controls)
              b.append(frame)
              b.append(reference_button)

              header_box.tap do |header|
                header.append(title_label)
                header.append(subtitle_label)
              end

              controls.tap do |bar|
                bar.append(button_back)
                bar.append(button_forward)
                bar.append(url_bar)
                bar.append(button_reload)
                bar.append(button_stop)

                button_back.tap { |btn| btn.signal_connect('clicked') { web_view.go_back } }
                button_forward.tap { |btn| btn.signal_connect('clicked') { web_view.go_forward } }
                button_reload.tap { |btn| btn.signal_connect('clicked') { web_view.reload } }
                button_stop.tap { |btn| btn.signal_connect('clicked') { web_view.stop_loading } }

                url_bar.tap do |entry|
                  entry.signal_connect('activate') { load_typed_uri }
                end
              end

              frame.tap { |f| f.child = web_view }
            end
          end
        end

        web_view.tap do |view|
          # The URL bar mirrors the page currently loaded.
          view.bind_property('uri', url_bar.buffer, 'text', GLib::BindingFlags::DEFAULT)
          view.signal_connect('load-changed') { |_, load_event| report_load(load_event) }
          view.signal_connect('load-failed') { |_, _event, fail_url, error| show_error_page(fail_url, error) }
          view.signal_connect('notify::estimated-load-progress') { update_progress }
          view.load_uri(HOME_URI)
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.webview', :default_flags)
  def clamp = @clamp ||= Adwaita::Clamp.new.tap { |c| c.maximum_size = 700 }
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0)
  def controls = @controls ||= Gtk::Box.new(:horizontal, 6)

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Web View'
      win.set_default_size(800, 800)
    end
  end

  def header_box
    @header_box ||= Gtk::Box.new(:vertical, 6).tap do |box|
      box.margin_top = 12
      box.margin_bottom = 12
    end
  end

  def title_label = @title_label ||= Gtk::Label.new('Web View').tap { |l| l.add_css_class('title-1') }
  def subtitle_label = @subtitle_label ||= Gtk::Label.new('Load and display webpages and HTML')

  def button_back = @button_back ||= icon_button('arrow1-left-symbolic', 'Back')
  def button_forward = @button_forward ||= icon_button('arrow1-right-symbolic', 'Forward')
  def button_reload = @button_reload ||= icon_button('view-refresh-symbolic', 'Reload')
  def button_stop = @button_stop ||= icon_button('process-stop-symbolic', 'Stop')

  def url_bar
    @url_bar ||= Gtk::Entry.new.tap do |entry|
      entry.input_purpose = :url
      entry.hexpand = true
    end
  end

  def frame
    @frame ||= Gtk::Frame.new.tap do |f|
      f.margin_top = 18
      f.margin_bottom = 18
    end
  end

  def web_view
    @web_view ||= WebKit::WebView.new.tap do |view|
      view.zoom_level = 0.8
      view.vexpand = true
      view.hexpand = true
      view.add_css_class('view')
    end
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new(
      'https://webkitgtk.org/reference/webkit2gtk/stable/class.WebView.html'
    ).tap do |btn|
      btn.label = 'API Reference'
      btn.margin_bottom = 12
    end
  end

  private

  def icon_button(icon_name, tooltip)
    Gtk::Button.new.tap do |btn|
      btn.icon_name = icon_name
      btn.tooltip_text = tooltip
    end
  end

  def load_typed_uri
    url_bar.buffer.text.then do |text|
      web_view.load_uri(GLib::Uri.peek_scheme(text) ? text : "http://#{text}")
    end
  end

  def report_load(load_event)
    case load_event
    when WebKit::LoadEvent::STARTED then puts 'Page loading started'
    when WebKit::LoadEvent::FINISHED then puts 'Page loading has finished '
    end
  end

  # A cancelled load is the result of pressing Stop, not a real failure.
  def show_error_page(fail_url, error)
    web_view.load_alternate_html(error_page(fail_url, error.message), fail_url, nil) unless cancelled?(error)
  end

  def cancelled?(error)
    error.is_a?(GLib::Error) && error.code == WebKit::NetworkError::CANCELLED.to_i
  end

  def error_page(fail_url, message)
    <<~HTML
      <div style="text-align:center; margin:24px;">
      <h2>An error occurred while loading #{fail_url}</h2>
      <p>#{message}</p>
      </div>
    HTML
  end

  def update_progress
    url_bar.progress_fraction = web_view.estimated_load_progress

    (url_bar.progress_fraction == 1).then do |complete|
      if complete
        GLib::Timeout.add(500) do
          url_bar.progress_fraction = 0
          false
        end
      end
    end
  end
end

WebViewDemo.new.build.run

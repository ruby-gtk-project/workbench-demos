require 'gtk4'
require 'adwaita'
require 'json'

# libsoup has no Ruby gem; its namespace comes straight from the typelib.
module Soup
  GObjectIntrospection::Loader.load('Soup', self)
end

class HttpRequestDemo
  LANGUAGE = 'en'

  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(article_title)
              b.append(scrolled_window)
              b.append(documentation_link)

              scrolled_window.tap { |sw| sw.child = article_text_view }
            end
          end
        end

        fetch_todays_featured_article

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.httprequest', :default_flags)
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 24)
  def http_session = @http_session ||= Soup::Session.new

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'HTTP Request'
      win.set_default_size(640, 640)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'HTTP Request'
      page.description = 'Make a request to an API'
    end
  end

  def article_title = @article_title ||= Gtk::Label.new.tap { |label| label.add_css_class('title-4') }

  def scrolled_window
    @scrolled_window ||= Gtk::ScrolledWindow.new.tap do |sw|
      sw.set_size_request(400, 200)
      sw.has_frame = true
    end
  end

  def article_text_view
    @article_text_view ||= Gtk::TextView.new.tap do |view|
      view.top_margin = 6
      view.bottom_margin = 6
      view.left_margin = 12
      view.right_margin = 12
      view.wrap_mode = :word
      view.editable = false
    end
  end

  def documentation_link
    @documentation_link ||= Gtk::LinkButton.new('https://libsoup.gnome.org/libsoup-3.0/index.html').tap do |btn|
      btn.label = 'Documentation'
    end
  end

  # https://api.wikimedia.org/wiki/Feed_API/Reference/Featured_content
  # The API rejects requests without a User-Agent.
  def message
    @message ||= Soup::Message.new(
      'GET',
      "https://api.wikimedia.org/feed/v1/wikipedia/#{LANGUAGE}/featured/#{Time.now.strftime('%Y/%m/%d')}"
    ).tap { |msg| msg.request_headers.append('User-Agent', 'workbench-demos-ruby') }
  end

  private

  def fetch_todays_featured_article
    http_session.send_and_read_async(message, GLib::PRIORITY_DEFAULT, nil) do |source, result|
      if message.status == Soup::Status::OK
        show_article(JSON.parse(source.send_and_read_finish(result).to_s))
      else
        warn "HTTP Status #{message.status.nick}"
      end
    end
  end

  def show_article(json)
    article_text_view.buffer.text = json['tfa']['extract']
    article_title.label = json['tfa']['titles']['normalized']
  end
end

HttpRequestDemo.new.build.run

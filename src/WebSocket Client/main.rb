require 'gtk4'
require 'adwaita'

# libsoup has no Ruby gem; its namespace comes straight from the typelib.
module Soup
  GObjectIntrospection::Loader.load('Soup', self)
end

class WebSocketClientDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(entry_url)
              b.append(button_connect)
              b.append(button_disconnect)
              b.append(message_box)
              b.append(gjs_link)
              b.append(reference_link)

              message_box.tap do |box|
                box.append(entry_message)
                box.append(button_send)
              end

              button_connect.tap do |btn|
                btn.signal_connect('clicked') { open_connection }
              end

              button_disconnect.tap do |btn|
                btn.signal_connect('clicked') { connection.close(Soup::WebsocketCloseCode::NORMAL.to_i, nil) }
              end

              button_send.tap do |btn|
                btn.signal_connect('clicked') { send_message(entry_message.text) }
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.websocketclient', :default_flags)
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0).tap { |box| box.halign = :center }
  def session = @session ||= Soup::Session.new
  def connection = @connection

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'WebSocket Client'
      win.set_default_size(640, 640)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'WebSocket Client'
      page.description = 'Connect to a WebSocket server'
    end
  end

  def entry_url
    @entry_url ||= Gtk::Entry.new.tap do |entry|
      entry.placeholder_text = 'url'
      entry.text = 'wss://ws.postman-echo.com/raw'
      entry.margin_bottom = 24
    end
  end

  def button_connect
    @button_connect ||= Gtk::Button.new.tap do |btn|
      btn.label = 'Connect'
      btn.margin_bottom = 24
    end
  end

  def button_disconnect
    @button_disconnect ||= Gtk::Button.new.tap do |btn|
      btn.label = 'Disconnect'
      btn.sensitive = false
      btn.margin_bottom = 24
    end
  end

  def message_box
    @message_box ||= Gtk::Box.new(:horizontal, 0).tap { |box| box.margin_bottom = 30 }
  end

  def entry_message
    @entry_message ||= Gtk::Entry.new.tap do |entry|
      entry.margin_end = 12
      entry.hexpand = true
      entry.placeholder_text = 'Message'
      entry.text = 'Hello'
    end
  end

  def button_send
    @button_send ||= Gtk::Button.new.tap do |btn|
      btn.label = 'Send'
      btn.sensitive = false
    end
  end

  def gjs_link
    @gjs_link ||= Gtk::LinkButton.new(
      'https://gjs.guide/guides/gjs/asynchronous-programming.html#asynchronous-operations'
    ).tap { |btn| btn.label = 'GJS Asynchronous Operations' }
  end

  def reference_link
    @reference_link ||= Gtk::LinkButton.new(
      'https://libsoup.gnome.org/libsoup-3.0/class.WebsocketConnection.html'
    ).tap { |btn| btn.label = 'API Reference' }
  end

  private

  # https://libsoup.gnome.org/libsoup-3.0/method.Session.websocket_connect_async.html
  def open_connection
    session.websocket_connect_async(Soup::Message.new('GET', entry_url.text), nil, [],
                                    GLib::PRIORITY_DEFAULT, nil) do |source, result|
      @connection = source.websocket_connect_finish(result)
      watch_connection
      on_open
    end
  end

  def watch_connection
    connection.signal_connect('closed') { on_closed }
    connection.signal_connect('error') { |_, error| on_error(error) }
    connection.signal_connect('message') { |_, type, message| on_message(type, message) }
  end

  def on_open
    puts 'open'
    button_connect.sensitive = false
    button_disconnect.sensitive = true
    button_send.sensitive = true
  end

  def on_closed
    puts 'closed'
    @connection = nil
    button_connect.sensitive = true
    button_disconnect.sensitive = false
    button_send.sensitive = false
  end

  def on_error(error)
    puts 'error'
    warn error.message
  end

  def on_message(type, message)
    (type == Soup::WebsocketDataType::TEXT).then do |text_frame|
      puts "received: #{message.to_s}" if text_frame
    end
  end

  def send_message(text)
    connection.send_message(Soup::WebsocketDataType::TEXT.to_i, GLib::Bytes.new(text))
    puts "sent: #{text}"
  end
end

WebSocketClientDemo.new.build.run

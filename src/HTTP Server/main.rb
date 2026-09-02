require 'gtk4'
require 'adwaita'

# libsoup has no Ruby gem; its namespace comes straight from the typelib.
module Soup
  GObjectIntrospection::Loader.load('Soup', self)
end

class HttpServerDemo
  FORM_PAGE = <<~HTML
    <html>
    <body>
      <form action="/hello">
        <label for="name">What is your name?</label>
        <input name="name">
        <input type="submit" value="Submit">
      </form>
    </body>
    </html>
  HTML

  THANKS_PAGE = <<~HTML
    <html>
    <body>
      Thank you, please go back to Workbench.
    </body>
    </html>
  HTML

  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(button_server)
              b.append(link_box)
              b.append(label_greetings)

              button_server.tap do |btn|
                btn.bind_property('active', link_box, 'visible', GLib::BindingFlags::SYNC_CREATE)
                btn.signal_connect('clicked') { btn.active? ? start_server : stop_server }
              end

              link_box.tap do |box|
                box.append(visit_label)
                box.append(linkbutton)
              end
            end
          end
        end

        server.tap do |s|
          s.add_handler('/') { |_, message, _path, _query| serve_form(message) }
          s.add_handler('/hello') { |_, message, _path, query| serve_greeting(message, query) }
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.httpserver', :default_flags)
  def server = @server ||= Soup::Server.new
  def visit_label = @visit_label ||= Gtk::Label.new('Visit')
  def label_greetings = @label_greetings ||= Gtk::Label.new.tap { |label| label.justify = :center }
  def port = @port ||= 0

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'HTTP Server'
      win.set_default_size(560, 520)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'HTTP Server'
      page.description = 'Interact with HTTP clients and browsers'
    end
  end

  def content_box
    @content_box ||= Gtk::Box.new(:vertical, 12).tap { |box| box.halign = :center }
  end

  def button_server
    @button_server ||= Gtk::ToggleButton.new.tap do |btn|
      btn.label = 'Start Server'
      btn.halign = :center
      btn.add_css_class('pill')
    end
  end

  def link_box
    @link_box ||= Gtk::Box.new(:vertical, 0).tap { |box| box.margin_top = 12 }
  end

  def linkbutton = @linkbutton ||= Gtk::LinkButton.new('http://localhost')

  private

  def start_server
    server.listen_local(port, Soup::ServerListenOptions.new)
    @port = server.uris.first.port
    linkbutton.uri = "http://localhost:#{port}"
    linkbutton.label = linkbutton.uri
    button_server.label = 'Stop Server'
  end

  def stop_server
    server.disconnect
    button_server.label = 'Start Server'
  end

  def serve_form(message)
    message.set_status(Soup::Status::OK.to_i, nil)
    message.response_headers.set_content_type('text/html', { 'charset' => 'UTF-8' })
    message.response_body.append(FORM_PAGE)
  end

  def serve_greeting(message, query)
    if query.nil?
      message.set_redirect(Soup::Status::FOUND.to_i, '/')
    else
      label_greetings.label =
        "Hello #{query['name']}, your browser is\n#{message.request_headers.get_one('User-Agent')}"

      message.set_status(Soup::Status::OK.to_i, nil)
      message.response_headers.set_content_type('text/html', { 'charset' => 'UTF-8' })
      message.response_body.append(THANKS_PAGE)
    end
  end
end

HttpServerDemo.new.build.run

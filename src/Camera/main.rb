require 'gtk4'
require 'adwaita'
# Requires the `gstreamer` gem plus the gtk4paintablesink and pipewiresrc plugins.
require 'gstreamer'

# libportal has no Ruby bindings, so the camera portal is driven over D-Bus.
class CameraDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        Gst.init

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(output)
              b.append(button)
              b.append(reference_button)

              button.tap do |btn|
                btn.signal_connect('clicked') { access_camera }
              end

              output.tap do |picture|
                picture.signal_connect('destroy') { pipeline.set_state(:null) }
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.camera', :default_flags)
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0).tap { |box| box.halign = :center }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Camera'
      win.set_default_size(560, 640)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Camera'
      page.description = 'Access the camera'
      page.margin_top = 48
    end
  end

  def output
    @output ||= Gtk::Picture.new.tap do |picture|
      picture.margin_bottom = 30
      picture.set_size_request(360, 240)
    end
  end

  def button
    @button ||= Gtk::Button.new.tap do |btn|
      btn.label = 'Access Camera'
      btn.margin_bottom = 42
      btn.halign = :center
      btn.add_css_class('suggested-action')
    end
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new('https://libportal.org/method.Portal.access_camera.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end

  def portal
    @portal ||= Gio::DBusProxy.new(
      Gio::DBusConnection.session,
      Gio::DBusProxyFlags::NONE,
      nil,
      'org.freedesktop.portal.Desktop',
      '/org/freedesktop/portal/desktop',
      'org.freedesktop.portal.Camera'
    )
  end

  def pipeline = @pipeline ||= Gst::Pipeline.new('camera')
  def source = @source ||= Gst::ElementFactory.make('pipewiresrc', 'source')
  def queue = @queue ||= Gst::ElementFactory.make('queue', 'queue')
  def paintable_sink = @paintable_sink ||= Gst::ElementFactory.make('gtk4paintablesink', 'paintable_sink')
  def glsinkbin = @glsinkbin ||= Gst::ElementFactory.make('glsinkbin', 'glsinkbin')

  private

  def access_camera
    if portal.get_cached_property('IsCameraPresent')&.value != true
      puts 'No Camera detected'
    else
      request_access
    end
  end

  def request_access
    portal.call_sync(
      'AccessCamera',
      GLib::Variant.new([{}], '(a{sv})'),
      Gio::DBusCallFlags::NONE,
      -1
    ).then { |reply| await_response(reply.get_child_value(0).string) }
  end

  def await_response(request_path)
    Gio::DBusConnection.session.signal_subscribe(
      'org.freedesktop.portal.Desktop',
      'org.freedesktop.portal.Request',
      'Response',
      request_path,
      nil,
      Gio::DBusSignalFlags::NONE
    ) do |_connection, _sender, _path, _interface, _signal, parameters|
      if parameters.get_child_value(0).get_uint32.zero?
        start_stream
      else
        puts 'Permission denied'
      end
    end
  end

  def start_stream
    build_pipeline(open_pipewire_remote)
    output.paintable = paintable_sink.paintable
    pipeline.set_state(:playing)
    watch_bus
  end

  def open_pipewire_remote
    puts 'Pipewire remote opened for camera'

    portal.call_with_unix_fd_list_sync(
      'OpenPipeWireRemote',
      GLib::Variant.new([{}], '(a{sv})'),
      Gio::DBusCallFlags::NONE,
      -1,
      nil
    ).last.get(0)
  end

  def build_pipeline(fd)
    source.set_property('fd', fd)
    glsinkbin.set_property('sink', paintable_sink)

    pipeline.add(source)
    pipeline.add(queue)
    pipeline.add(glsinkbin)
    source.link(queue)
    queue.link(glsinkbin)
  end

  def watch_bus
    pipeline.bus.tap do |bus|
      bus.add_signal_watch

      bus.signal_connect('message') do |_bus, message|
        case message.type
        when Gst::MessageType::ERROR then warn message.parse_error.first.to_s
        when Gst::MessageType::EOS then puts 'End of stream'
        end
      end
    end
  end
end

CameraDemo.new.build.run

require 'gtk4'
require 'adwaita'
# Requires the gtk4paintablesink and pipewiresrc GStreamer plugins.
require 'gstreamer'

# libportal has no Ruby gem, so the screencast portal session is driven over
# D-Bus directly.
class ScreencastDemo
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
                btn.signal_connect('clicked') { start_screencast_session }
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

  def app = @app ||= Gtk::Application.new('org.example.screencast', :default_flags)
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0).tap { |box| box.halign = :center }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Screencast'
      win.set_default_size(560, 660)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Screencast'
      page.description = 'Capture your desktop'
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
      btn.label = 'Start Screencast Session…'
      btn.margin_bottom = 42
      btn.halign = :center
      btn.add_css_class('suggested-action')
    end
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new('https://libportal.org/class.Session.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end

  def session_bus = @session_bus ||= Gio.bus_get_sync(Gio::BusType::SESSION)

  def portal
    @portal ||= Gio::DBusProxy.new(
      session_bus,
      Gio::DBusProxyFlags::NONE,
      nil,
      'org.freedesktop.portal.Desktop',
      '/org/freedesktop/portal/desktop',
      'org.freedesktop.portal.ScreenCast'
    )
  end

  def pipeline = @pipeline ||= Gst::Pipeline.new('screencast')
  def source = @source ||= Gst::ElementFactory.make('pipewiresrc', 'source')
  def queue = @queue ||= Gst::ElementFactory.make('queue', 'queue')
  def paintable_sink = @paintable_sink ||= Gst::ElementFactory.make('gtk4paintablesink', 'paintable_sink')
  def glsinkbin = @glsinkbin ||= Gst::ElementFactory.make('glsinkbin', 'glsinkbin')
  def session_path = @session_path

  private

  def start_screencast_session
    portal.call_sync('CreateSession', GLib::Variant.new([{}], '(a{sv})'),
                     Gio::DBusCallFlags::NONE, -1).then do |reply|
      await(reply.get_child_value(0).string) { |results| select_sources(results['session_handle'].get_string.first) }
    end
  end

  def select_sources(path)
    @session_path = path

    # 1 = MONITOR output, 1 = EMBEDDED cursor mode, 0 = TRANSIENT persistence.
    portal.call_sync(
      'SelectSources',
      GLib::Variant.new([path, { 'types' => GLib::Variant.new(1, 'u'),
                                 'cursor_mode' => GLib::Variant.new(2, 'u'),
                                 'persist_mode' => GLib::Variant.new(1, 'u') }], '(oa{sv})'),
      Gio::DBusCallFlags::NONE, -1
    ).then { |reply| await(reply.get_child_value(0).string) { start_stream } }
  end

  def start_stream
    portal.call_sync('Start', GLib::Variant.new([session_path, '', {}], '(osa{sv})'),
                     Gio::DBusCallFlags::NONE, -1).then do |reply|
      await(reply.get_child_value(0).string) { |results| play(results['streams']) }
    end
  end

  def play(streams)
    node_id(streams).then do |node|
      if node.nil?
        warn 'No available node id'
      else
        build_pipeline(open_pipewire_remote, node)
        output.paintable = paintable_sink.paintable
        pipeline.set_state(:playing)
      end
    end
  end

  # Assume a single stream for simplicity.
  def node_id(streams)
    streams&.n_children&.positive? ? streams.get_child_value(0).get_child_value(0).get_uint32 : nil
  end

  def open_pipewire_remote
    portal.call_with_unix_fd_list_sync(
      'OpenPipeWireRemote',
      GLib::Variant.new([session_path, {}], '(oa{sv})'),
      Gio::DBusCallFlags::NONE, -1, nil
    ).last.get(0)
  end

  def build_pipeline(fd, node)
    source.set_property('fd', fd)
    source.set_property('path', node.to_s)
    glsinkbin.set_property('sink', paintable_sink)

    pipeline.add(source)
    pipeline.add(queue)
    pipeline.add(glsinkbin)
    source.link(queue)
    queue.link(glsinkbin)
  end

  def await(request_path)
    session_bus.signal_subscribe(
      'org.freedesktop.portal.Desktop', 'org.freedesktop.portal.Request', 'Response',
      request_path, nil, Gio::DBusSignalFlags::NONE
    ) do |_connection, _sender, _path, _interface, _signal, parameters|
      if parameters.get_child_value(0).get_uint32.zero?
        yield parameters.get_child_value(1)
      else
        puts 'Permission denied'
      end
    end
  end
end

ScreencastDemo.new.build.run

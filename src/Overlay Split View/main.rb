require 'gtk4'
require 'adwaita'

class OverlaySplitViewDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = breakpoint_bin

          breakpoint_bin.tap do |bin|
            bin.child = toolbar_view
            bin.add_breakpoint(breakpoint)
          end

          toolbar_view.tap do |view|
            view.top_bar_style = :raised
            view.add_top_bar(header_bar)
            view.content = split_view

            header_bar.tap do |bar|
              bar.pack_start(show_sidebar_button)
              bar.pack_end(show_sidebar_end_button)
            end

            split_view.tap do |sv|
              sv.sidebar = sidebar_status
              sv.content = content_status

              show_sidebar_button.bind_property('active', sv, 'show-sidebar',
                                                GLib::BindingFlags::BIDIRECTIONAL | GLib::BindingFlags::SYNC_CREATE)
              show_sidebar_button.bind_property('active', show_sidebar_end_button, 'active',
                                                GLib::BindingFlags::BIDIRECTIONAL | GLib::BindingFlags::SYNC_CREATE)

              sidebar_status.tap do |page|
                page.child = sidebar_box

                sidebar_box.tap do |box|
                  box.append(start_toggle)
                  box.append(end_toggle)

                  start_toggle.tap do |btn|
                    btn.bind_property('active', show_sidebar_button, 'visible', GLib::BindingFlags::SYNC_CREATE)
                    btn.signal_connect('toggled') { sv.sidebar_position = :start if btn.active? }
                  end

                  end_toggle.tap do |btn|
                    btn.bind_property('active', show_sidebar_end_button, 'visible', GLib::BindingFlags::SYNC_CREATE)
                    btn.signal_connect('toggled') { sv.sidebar_position = :end if btn.active? }
                  end
                end
              end

              content_status.tap do |page|
                page.child = content_box

                content_box.tap { |box| box.append(reference_button) }
              end
            end
          end
        end

        breakpoint.tap do |bp|
          bp.add_setter(split_view, 'collapsed', GLib::Value.new(GLib::Type::BOOLEAN, true))
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.overlaysplitview', :default_flags)
  def toolbar_view = @toolbar_view ||= Adwaita::ToolbarView.new
  def header_bar = @header_bar ||= Adwaita::HeaderBar.new
  def split_view = @split_view ||= Adwaita::OverlaySplitView.new

  # Adwaita::ApplicationWindow does not accept a child through the Ruby
  # bindings, so breakpoints live in an Adwaita::BreakpointBin.
  def breakpoint_bin = @breakpoint_bin ||= Adwaita::BreakpointBin.new.tap { |bin| bin.set_size_request(360, 200) }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Overlay Split View'
      win.set_default_size(640, 480)
    end
  end

  def breakpoint
    @breakpoint ||= Adwaita::Breakpoint.new(Adwaita::BreakpointCondition.parse('max-width: 400sp'))
  end

  def show_sidebar_button = @show_sidebar_button ||= sidebar_toggle('sidebar-show-symbolic')
  def show_sidebar_end_button = @show_sidebar_end_button ||= sidebar_toggle('sidebar-show-right-symbolic')

  def sidebar_status = @sidebar_status ||= Adwaita::StatusPage.new.tap { |page| page.title = 'Sidebar' }
  def content_status = @content_status ||= Adwaita::StatusPage.new.tap { |page| page.title = 'Content' }

  def sidebar_box
    @sidebar_box ||= Gtk::Box.new(:vertical, 18).tap { |box| box.halign = :center }
  end

  def content_box
    @content_box ||= Gtk::Box.new(:vertical, 18).tap { |box| box.valign = :center }
  end

  def start_toggle
    @start_toggle ||= pill_toggle('Start').tap { |btn| btn.active = true }
  end

  def end_toggle
    @end_toggle ||= pill_toggle('End').tap { |btn| btn.group = start_toggle }
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new(
      'https://gnome.pages.gitlab.gnome.org/libadwaita/doc/1.6/class.OverlaySplitView.html'
    ).tap do |btn|
      btn.label = 'API Reference'
      btn.margin_top = 24
    end
  end

  private

  def sidebar_toggle(icon_name)
    Gtk::ToggleButton.new.tap do |btn|
      btn.icon_name = icon_name
      btn.tooltip_text = 'Toggle Sidebar'
    end
  end

  def pill_toggle(label)
    Gtk::ToggleButton.new.tap do |btn|
      btn.label = label
      btn.can_shrink = true
      btn.add_css_class('pill')
    end
  end
end

OverlaySplitViewDemo.new.build.run

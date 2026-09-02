require 'gtk4'
require 'adwaita'

class NavigationSplitViewDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = breakpoint_bin

          breakpoint_bin.tap do |bin|
            bin.child = split_view
            bin.add_breakpoint(breakpoint)
          end

          split_view.tap do |view|
            view.sidebar = sidebar_page
            view.content = content_page

            sidebar_toolbar.tap do |toolbar|
              toolbar.add_top_bar(sidebar_header)
              toolbar.content = sidebar_status

              sidebar_status.tap { |page| page.child = button }
            end

            content_toolbar.tap do |toolbar|
              toolbar.add_top_bar(content_header)
              toolbar.content = content_status

              content_status.tap { |page| page.child = reference_button }
            end
          end
        end

        breakpoint.tap do |bp|
          bp.add_setter(split_view, 'collapsed', GLib::Value.new(GLib::Type::BOOLEAN, true))
          bp.add_setter(button, 'visible', GLib::Value.new(GLib::Type::BOOLEAN, true))
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.navigationsplitview', :default_flags)
  def split_view = @split_view ||= Adwaita::NavigationSplitView.new
  def sidebar_toolbar = @sidebar_toolbar ||= Adwaita::ToolbarView.new
  def content_toolbar = @content_toolbar ||= Adwaita::ToolbarView.new
  def sidebar_page = @sidebar_page ||= Adwaita::NavigationPage.new(sidebar_toolbar, 'Sidebar').tap { |p| p.tag = 'sidebar' }
  def content_page = @content_page ||= Adwaita::NavigationPage.new(content_toolbar, 'Content').tap { |p| p.tag = 'content' }

  # Adwaita::ApplicationWindow rejects gtk_window_set_child in the Ruby
  # bindings, so breakpoints come from an Adwaita::BreakpointBin instead.
  def breakpoint_bin = @breakpoint_bin ||= Adwaita::BreakpointBin.new.tap { |bin| bin.set_size_request(360, 200) }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Navigation Split View'
      win.set_default_size(640, 480)
    end
  end

  def breakpoint
    @breakpoint ||= Adwaita::Breakpoint.new(Adwaita::BreakpointCondition.parse('max-width: 400sp'))
  end

  def sidebar_header = @sidebar_header ||= Adwaita::HeaderBar.new.tap { |bar| bar.show_title = false }
  def content_header = @content_header ||= Adwaita::HeaderBar.new.tap { |bar| bar.show_title = false }

  def sidebar_status = @sidebar_status ||= Adwaita::StatusPage.new.tap { |page| page.title = 'Sidebar' }
  def content_status = @content_status ||= Adwaita::StatusPage.new.tap { |page| page.title = 'Content' }

  def button
    @button ||= Gtk::Button.new.tap do |btn|
      btn.visible = false
      btn.halign = :center
      btn.can_shrink = true
      btn.label = 'Open Content'
      btn.set_detailed_action_name("navigation.push::content")
      btn.add_css_class('pill')
    end
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new(
      'https://gnome.pages.gitlab.gnome.org/libadwaita/doc/1.6/class.NavigationSplitView.html'
    ).tap { |btn| btn.label = 'API Reference' }
  end
end

NavigationSplitViewDemo.new.build.run

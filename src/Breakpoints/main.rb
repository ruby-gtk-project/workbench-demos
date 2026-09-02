require 'gtk4'
require 'adwaita'

class BreakpointsDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = page

          page.tap do |p|
            p.child = content_box

            content_box.tap do |box|
              box.append(image)
              box.append(breakpoint_bin)
              box.append(breakpoint_link)
              box.append(breakpoint_bin_link)

              breakpoint_bin.tap do |bin|
                bin.child = label_wide
                bin.add_breakpoint(breakpoint)
              end
            end
          end
        end

        breakpoint.tap do |bp|
          # adw_breakpoint_add_setter needs a real GValue in the Ruby bindings.
          bp.add_setter(breakpoint_bin, 'child', GLib::Value.new(Gtk::Widget.gtype, label_narrow))
          bp.add_setter(image, 'icon-size', GLib::Value.new(Gtk::IconSize.gtype, Gtk::IconSize::NORMAL))
          bp.signal_connect('apply') { puts 'Breakpoint Applied' }
          bp.signal_connect('unapply') { puts 'Breakpoint Unapplied' }
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.breakpoints', :default_flags)

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Breakpoints'
      win.set_size_request(360, 200)
      win.set_default_size(640, 480)
    end
  end

  def page
    @page ||= Adwaita::StatusPage.new.tap do |status|
      status.title = 'Breakpoints'
      status.description = 'Resize the window to see the breakpoint effect'
    end
  end

  def content_box
    @content_box ||= Gtk::Box.new(:vertical, 12).tap { |box| box.valign = :center }
  end

  def image
    @image ||= Gtk::Image.new.tap do |img|
      img.icon_size = :large
      img.icon_name = 'go-home-symbolic'
    end
  end

  def breakpoint_bin
    @breakpoint_bin ||= Adwaita::BreakpointBin.new.tap { |bin| bin.set_size_request(200, 50) }
  end

  def breakpoint
    @breakpoint ||= Adwaita::Breakpoint.new(Adwaita::BreakpointCondition.parse('max-width: 500sp'))
  end

  def label_narrow = @label_narrow ||= Gtk::Label.new('Narrow').tap { |l| l.add_css_class('title-4') }
  def label_wide = @label_wide ||= Gtk::Label.new('Wide').tap { |l| l.add_css_class('title-1') }

  def breakpoint_link
    @breakpoint_link ||= Gtk::LinkButton.new(
      'https://gnome.pages.gitlab.gnome.org/libadwaita/doc/1.6/class.Breakpoint.html'
    ).tap do |btn|
      btn.label = 'Breakpoint'
      btn.margin_top = 24
    end
  end

  def breakpoint_bin_link
    @breakpoint_bin_link ||= Gtk::LinkButton.new(
      'https://gnome.pages.gitlab.gnome.org/libadwaita/doc/1.6/class.BreakpointBin.html'
    ).tap { |btn| btn.label = 'Breakpoint Bin' }
  end
end

BreakpointsDemo.new.build.run

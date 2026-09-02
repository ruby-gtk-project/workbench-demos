require 'gtk4'
require 'adwaita'

class PopoversDemo
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
            page.child = content_box

            content_box.tap do |b|
              b.append(buttons_box)
              b.append(popover_reference)
              b.append(popover_menu_reference)
              b.append(hig_link)

              buttons_box.tap do |box|
                box.append(plain_button)
                box.append(menu_button)

                plain_button.tap { |btn| btn.popover = plain_popover }
                menu_button.tap { |btn| btn.popover = popover_menu }
              end
            end
          end
        end

        plain_popover.tap do |popover|
          popover.child = plain_popover_box

          plain_popover_box.tap { |box| box.append(plain_popover_label) }
        end

        [plain_popover, popover_menu].each do |popover|
          popover.signal_connect('closed') { puts "#{popover.name} closed." }
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.popovers', :default_flags)
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0)
  def plain_popover_label = @plain_popover_label ||= Gtk::Label.new('Plain Popover')

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Popovers'
      win.set_default_size(640, 620)
    end
  end

  def css_provider
    @css_provider ||= Gtk::CssProvider.new.tap { |provider| provider.load_from_path(File.join(__dir__, 'main.css')) }
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Popovers'
      page.description = 'Display content in a container anchored to another widget'
    end
  end

  def buttons_box
    @buttons_box ||= Gtk::Box.new(:horizontal, 42).tap do |box|
      box.margin_top = 42
      box.margin_bottom = 78
      box.halign = :center
    end
  end

  def plain_button = @plain_button ||= Gtk::MenuButton.new.tap { |btn| btn.label = 'Plain Popover' }
  def menu_button = @menu_button ||= Gtk::MenuButton.new.tap { |btn| btn.label = 'Popover Menu' }

  def plain_popover
    @plain_popover ||= Gtk::Popover.new.tap do |popover|
      popover.has_arrow = true
      popover.name = 'plain_popover'
    end
  end

  def plain_popover_box
    @plain_popover_box ||= Gtk::Box.new(:horizontal, 0).tap { |box| box.name = 'plain-popover-box' }
  end

  def popover_menu
    @popover_menu ||= Gtk::PopoverMenu.new(menu_app).tap { |popover| popover.name = 'popover_menu' }
  end

  def menu_app
    @menu_app ||= Gio::Menu.new.tap do |menu|
      menu.append_section(nil, Gio::Menu.new.tap do |section|
        section.append('Keyboard Shortcuts', 'app.shortcuts')
        section.append('About Workbench', 'app.about')
      end)
    end
  end

  def popover_reference
    @popover_reference ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.Popover.html').tap do |btn|
      btn.label = 'Popover API Reference'
    end
  end

  def popover_menu_reference
    @popover_menu_reference ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.PopoverMenu.html').tap do |btn|
      btn.label = 'Popover Menu API Reference'
    end
  end

  def hig_link
    @hig_link ||= Gtk::LinkButton.new(
      'https://developer.gnome.org/hig/patterns/containers/popovers.html'
    ).tap do |btn|
      btn.label = 'Human Interface Guidelines'
      btn.margin_top = 24
    end
  end
end

PopoversDemo.new.build.run

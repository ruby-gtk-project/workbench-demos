require 'gtk4'
require 'adwaita'

class UsingIconsDemo
  EXPLANATION = <<~MARKUP.freeze
    Several widgets such as <tt>GtkImage</tt> and <tt>GtkButton</tt> accept an <tt>icon-name</tt> property. Icons must be properly registered to be referenced by name.\s

    To includes icons in a project, select “Reveal in Files” in Workbench menu and save them in the icons folder. Make sure to press “Run” to register the new icons.

    You can find icons using the <a href="https://flathub.org/apps/org.gnome.design.IconLibrary">Icon Library app</a> which also explain how to register icons in GNOME applications.

    Learn more about UI icons in the <a href="https://developer.gnome.org/hig/guidelines/ui-icons.html">Human Interface Guidelines</a>.
  MARKUP

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
            page.child = clamp

            clamp.tap do |c|
              c.child = content_box

              content_box.tap do |b|
                b.append(card)

                card.tap { |box| box.append(label) }
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.usingicons', :default_flags)
  def clamp = @clamp ||= Adwaita::Clamp.new
  def card = @card ||= Gtk::Box.new(:horizontal, 0).tap { |box| box.add_css_class('card') }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Using Icons'
      win.set_default_size(720, 660)
    end
  end

  def css_provider
    @css_provider ||= Gtk::CssProvider.new.tap { |provider| provider.load_from_path(File.join(__dir__, 'main.css')) }
  end

  # Try using a custom icon instead of cafe-symbolic.
  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Using Icons'
      page.description = 'Learn how to use icons for UI'
      page.icon_name = 'cafe-symbolic'
    end
  end

  def content_box
    @content_box ||= Gtk::Box.new(:vertical, 0).tap { |box| box.halign = :center }
  end

  def label
    @label ||= Gtk::Label.new(EXPLANATION).tap do |l|
      l.wrap = true
      l.selectable = true
      l.use_markup = true
    end
  end
end

UsingIconsDemo.new.build.run

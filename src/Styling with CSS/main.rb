require 'gtk4'
require 'adwaita'

class StylingWithCssDemo
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
              b.append(id_label)
              b.append(class_label)
              b.append(basic_label)
              b.append(linked_box)
              b.append(documentation_title)
              b.append(documentation_links)

              linked_box.tap do |box|
                box.append(remove_button)
                box.append(add_button)
                box.append(forward_button)
              end

              documentation_links.tap do |links|
                links.append(overview_link)
                links.append(properties_link)
                links.append(style_classes_link)
                links.append(named_colors_link)
              end
            end
          end
        end

        basic_label.add_css_class('my_custom_class')

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.stylingwithcss', :default_flags)

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Styling With CSS'
      win.set_default_size(760, 700)
    end
  end

  def css_provider
    @css_provider ||= Gtk::CssProvider.new.tap { |provider| provider.load_from_path(File.join(__dir__, 'main.css')) }
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Styling With CSS'
      page.description = 'Change the appearence of widgets'
    end
  end

  def content_box
    @content_box ||= Gtk::Box.new(:vertical, 0).tap { |box| box.halign = :center }
  end

  # The name property drives the #css_text id selector.
  def id_label
    @id_label ||= Gtk::Label.new('This widget is styled with an id selector').tap do |label|
      label.name = 'css_text'
      label.margin_bottom = 12
    end
  end

  # A CSS class drives the .css_text class selector.
  def class_label
    @class_label ||= Gtk::Label.new('This widget is styled with a class selector').tap do |label|
      label.add_css_class('css_text')
      label.margin_bottom = 12
    end
  end

  def basic_label
    @basic_label ||= Gtk::Label.new('Classes can be applied programmatically').tap do |label|
      label.margin_bottom = 12
    end
  end

  def linked_box
    @linked_box ||= Gtk::Box.new(:horizontal, 0).tap do |box|
      box.name = 'linked_box'
      box.margin_top = 24
      box.halign = :center
      box.add_css_class('linked')
    end
  end

  def remove_button = @remove_button ||= icon_button('list-remove-symbolic')
  def add_button = @add_button ||= icon_button('list-add-symbolic')
  def forward_button = @forward_button ||= icon_button('mail-forward-symbolic')

  def documentation_title
    @documentation_title ||= Gtk::Label.new('Documentation').tap do |label|
      label.margin_top = 24
      label.add_css_class('title-2')
    end
  end

  def documentation_links
    @documentation_links ||= Gtk::Box.new(:horizontal, 0).tap do |box|
      box.halign = :center
      box.margin_top = 24
    end
  end

  def overview_link
    @overview_link ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/css-overview.html').tap do |btn|
      btn.label = 'Overview'
    end
  end

  def properties_link
    @properties_link ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/css-properties.html').tap do |btn|
      btn.label = 'Properties'
    end
  end

  def style_classes_link
    @style_classes_link ||= Gtk::LinkButton.new(
      'https://gnome.pages.gitlab.gnome.org/libadwaita/doc/1.6/style-classes.html'
    ).tap { |btn| btn.label = 'Style Classes' }
  end

  def named_colors_link
    @named_colors_link ||= Gtk::LinkButton.new(
      'https://gnome.pages.gitlab.gnome.org/libadwaita/doc/1.6/named-colors.html'
    ).tap { |btn| btn.label = 'Named Colors' }
  end

  private

  def icon_button(icon_name)
    Gtk::Button.new.tap { |btn| btn.icon_name = icon_name }
  end
end

StylingWithCssDemo.new.build.run

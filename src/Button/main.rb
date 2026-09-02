require 'gtk4'
require 'adwaita'

class ButtonDemo
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
              b.append(first_row)
              b.append(second_row)
              b.append(third_row)
              b.append(tutorial_link)
              b.append(reference_link)
              b.append(hig_link)

              first_row.tap do |row|
                row.append(regular)
                row.append(flat)
                row.append(suggested)
              end

              second_row.tap do |row|
                row.append(destructive)
                row.append(custom)
                row.append(disabled)
              end

              third_row.tap do |row|
                row.append(circular_plus)
                row.append(circular_minus)
                row.append(pill)
                row.append(osd_left)
                row.append(osd_right)
              end

              buttons.each do |btn|
                btn.signal_connect('clicked') { puts "#{btn.name} clicked" }
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.button', :default_flags)
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0).tap { |box| box.halign = :center }
  def first_row = @first_row ||= Gtk::Box.new(:horizontal, 0).tap { |box| box.margin_bottom = 24 }
  def second_row = @second_row ||= Gtk::Box.new(:horizontal, 0).tap { |box| box.margin_bottom = 24 }
  def third_row = @third_row ||= Gtk::Box.new(:horizontal, 0).tap { |box| box.margin_bottom = 30 }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Button'
      win.set_default_size(800, 620)
    end
  end

  def css_provider
    @css_provider ||= Gtk::CssProvider.new.tap { |provider| provider.load_from_path(File.join(__dir__, 'main.css')) }
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Button'
      page.description = 'Allow people to perform actions by clicking'
    end
  end

  def buttons
    @buttons ||= [regular, flat, suggested, destructive, custom, disabled,
                  circular_plus, circular_minus, pill, osd_left, osd_right]
  end

  def regular
    @regular ||= labelled_button('regular', 'Regular').tap { |btn| btn.margin_end = 40 }
  end

  def flat
    @flat ||= labelled_button('flat', 'Flat').tap do |btn|
      btn.margin_end = 40
      btn.add_css_class('flat')
    end
  end

  def suggested
    @suggested ||= labelled_button('suggested', 'Suggested').tap { |btn| btn.add_css_class('suggested-action') }
  end

  def destructive
    @destructive ||= labelled_button('destructive', 'Destructive').tap do |btn|
      btn.margin_end = 40
      btn.add_css_class('destructive-action')
    end
  end

  def custom
    @custom ||= labelled_button('custom', 'Custom').tap do |btn|
      btn.margin_end = 40
      btn.add_css_class('opaque')
    end
  end

  def disabled
    @disabled ||= labelled_button('disabled', 'Disabled').tap { |btn| btn.sensitive = false }
  end

  def circular_plus
    @circular_plus ||= icon_button('circular-plus', 'list-add-symbolic').tap do |btn|
      btn.margin_start = 13
      btn.margin_end = 20
      btn.add_css_class('circular')
      btn.add_css_class('opaque')
    end
  end

  def circular_minus
    @circular_minus ||= icon_button('circular-minus', 'list-remove-symbolic').tap do |btn|
      btn.margin_end = 70
      btn.add_css_class('circular')
      btn.add_css_class('opaque')
    end
  end

  def pill
    @pill ||= labelled_button('pill', 'Pill').tap do |btn|
      btn.margin_end = 60
      btn.add_css_class('pill')
    end
  end

  def osd_left
    @osd_left ||= icon_button('osd-left', 'go-previous').tap do |btn|
      btn.margin_end = 20
      btn.add_css_class('osd')
    end
  end

  def osd_right
    @osd_right ||= icon_button('osd-right', 'go-next').tap do |btn|
      btn.halign = :center
      btn.add_css_class('osd')
    end
  end

  def tutorial_link
    @tutorial_link ||= Gtk::LinkButton.new(
      'https://developer.gnome.org/documentation/tutorials/beginners/components/button.html'
    ).tap { |btn| btn.label = 'Tutorial' }
  end

  def reference_link
    @reference_link ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.Button.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end

  def hig_link
    @hig_link ||= Gtk::LinkButton.new('https://developer.gnome.org/hig/patterns/controls/buttons.html').tap do |btn|
      btn.label = 'Human Interface Guidelines'
    end
  end

  private

  def labelled_button(name, label)
    Gtk::Button.new.tap do |btn|
      btn.name = name
      btn.label = label
    end
  end

  def icon_button(name, icon_name)
    Gtk::Button.new.tap do |btn|
      btn.name = name
      btn.icon_name = icon_name
      btn.valign = :center
    end
  end
end

ButtonDemo.new.build.run

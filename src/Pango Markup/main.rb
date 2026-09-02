require 'gtk4'
require 'adwaita'

class PangoMarkupDemo
  MARKUP = [
    "<span foreground='blue' size='x-large'>Blue text</span> is <i>cool</i>!",
    '<i>Italic text</i> and <b>Bold text</b>',
    '<s>Strikethrough text</s> and <u>Underlined text</u>',
    "<span font_family='Monospace' weight='bold' size='large'>Monospace Bold Large</span>",
    "<span strikethrough='true' strikethrough_color='red'>Strikethrough Red</span> and " \
    "<span underline='double' underline_color='green'>Double Underline Green</span>",
    "<span background='red' text_transform='uppercase' line_height='1.5'>" \
    'Background Red, Uppercase, Line Height 1.5</span>'
  ].freeze

  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              labels.each { |label| b.append(label) }
              b.append(reference_button)
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.pangomarkup', :default_flags)

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Pango Markup'
      win.set_default_size(720, 560)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Pango Markup'
      page.description = 'Style text using markup'
    end
  end

  def content_box
    @content_box ||= Gtk::Box.new(:vertical, 12).tap { |box| box.halign = :center }
  end

  def labels
    @labels ||= MARKUP.map do |markup|
      Gtk::Label.new(markup).tap { |label| label.use_markup = true }
    end
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new(
      'https://docs.gtk.org/Pango/pango_markup.html#pango-markup'
    ).tap do |btn|
      btn.label = 'Reference'
      btn.margin_top = 12
    end
  end
end

PangoMarkupDemo.new.build.run

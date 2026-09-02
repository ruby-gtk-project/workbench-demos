require 'gtk4'

# Pango is a text layout library; here it styles a label letter by letter.
# https://docs.gtk.org/Pango/method.AttrList.to_string.html
class TextColorsDemo
  RAINBOW_COLORS = ['#D00', '#C50', '#E90', '#090', '#24E', '#55E', '#C3C'].freeze

  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = main_box

          main_box.tap do |box|
            box.append(label)
            box.append(caption)
            box.append(entry)

            entry.tap do |e|
              e.bind_property('text', label, 'label', GLib::BindingFlags::SYNC_CREATE)
            end

            label.tap do |l|
              l.signal_connect('notify::label') { update_attributes }
            end
          end
        end

        update_attributes

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.textcolors', :default_flags)
  def caption = @caption ||= Gtk::Label.new('Colored with Pango attributes')

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Text Colors'
      win.set_default_size(560, 400)
    end
  end

  def main_box
    @main_box ||= Gtk::Box.new(:vertical, 12).tap do |box|
      box.halign = :center
      box.valign = :center
    end
  end

  def label = @label ||= Gtk::Label.new.tap { |l| l.add_css_class('title-1') }

  def entry
    @entry ||= Gtk::Entry.new.tap do |e|
      e.margin_top = 12
      e.text = 'Hello, Rainbow!'
      e.halign = :center
    end
  end

  private

  def update_attributes
    label.attributes = Pango::AttrList.from_string(rainbow_attributes(label.label))
  end

  # Spaces get no color so they do not consume one from the cycle.
  def rainbow_attributes(text)
    colors = RAINBOW_COLORS.cycle

    text.each_char.with_index.filter_map do |character, index|
      "#{index} #{index + 1} foreground #{colors.next}" unless character == ' '
    end.join(',')
  end
end

TextColorsDemo.new.build.run

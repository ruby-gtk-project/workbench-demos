require 'gtk4'
require 'adwaita'

LOREM = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut ' \
        'labore et dolore magna aliqua. Vel elit scelerisque mauris pellentesque pulvinar. Molestie nunc ' \
        'non blandit massa enim nec dui nunc. Turpis in eu mi bibendum neque egestas congue quisque. Sed ' \
        'velit dignissim sodales ut. Massa tempor nec feugiat nisl pretium fusce id velit. Vitae congue eu ' \
        'consequat ac felis donec et. Ultrices sagittis orci a scelerisque purus semper eget duis at. ' \
        'Habitant morbi tristique senectus et netus et malesuada fames ac. Vitae aliquet nec ullamcorper ' \
        'sit amet risus nullam. Tortor at auctor urna nunc. Eget velit aliquet sagittis id consectetur ' \
        'purus. Libero id faucibus nisl tincidunt eget. Nunc consequat interdum varius sit amet mattis.'

class FrameDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = scrolled_page

          scrolled_page.tap do |sw|
            sw.child = status_page

            status_page.tap do |page|
              page.child = content_box

              content_box.tap do |b|
                b.append(pictures_row)
                b.append(pictures_separator)
                b.append(toolbar_plain_label)
                b.append(plain_toolbar)
                b.append(toolbar_framed_label)
                b.append(framed_toolbar)
                b.append(toolbar_separator)
                b.append(textviews_row)
                b.append(reference_button)

                pictures_row.tap do |row|
                  row.append(without_frame_column)
                  row.append(pictures_inner_separator)
                  row.append(with_frame_column)

                  without_frame_column.tap do |column|
                    column.append(without_frame)
                    column.append(without_frame_label)
                  end

                  with_frame_column.tap do |column|
                    column.append(picture_frame)
                    column.append(with_frame_label)

                    picture_frame.tap { |frame| frame.child = with_frame }
                  end
                end

                plain_toolbar.tap { |box| toolbar_buttons.each { |btn| box.append(btn) } }

                framed_toolbar.tap do |frame|
                  frame.child = framed_toolbar_box

                  framed_toolbar_box.tap { |box| framed_toolbar_buttons.each { |btn| box.append(btn) } }
                end

                textviews_row.tap do |row|
                  row.append(textview_plain_column)
                  row.append(textviews_inner_separator)
                  row.append(textview_framed_column)

                  textview_plain_column.tap do |column|
                    column.append(scrolled_without_frame)
                    column.append(textview_without_frame_label)

                    scrolled_without_frame.tap { |sw2| sw2.child = textview_without_frame }
                  end

                  textview_framed_column.tap do |column|
                    column.append(textview_frame)
                    column.append(textview_with_frame_label)

                    textview_frame.tap do |frame|
                      frame.child = scrolled_with_frame

                      scrolled_with_frame.tap { |sw2| sw2.child = textview_with_frame }
                    end
                  end
                end
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.frame', :default_flags)
  def scrolled_page = @scrolled_page ||= Gtk::ScrolledWindow.new
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0).tap { |box| box.halign = :center }
  def picture_frame = @picture_frame ||= Gtk::Frame.new
  def textview_frame = @textview_frame ||= Gtk::Frame.new
  def buffer = @buffer ||= Gtk::TextBuffer.new.tap { |b| b.text = LOREM }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Frame'
      win.set_default_size(800, 900)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Frame'
      page.description = 'A widget that surrounds its child with a decorative frame'
    end
  end

  def pictures_row = @pictures_row ||= comparison_row
  def textviews_row = @textviews_row ||= comparison_row

  def without_frame_column = @without_frame_column ||= comparison_column
  def with_frame_column = @with_frame_column ||= comparison_column
  def textview_plain_column = @textview_plain_column ||= comparison_column
  def textview_framed_column = @textview_framed_column ||= comparison_column

  def without_frame = @without_frame ||= demo_picture
  def with_frame = @with_frame ||= demo_picture

  def without_frame_label = @without_frame_label ||= title('Without Frame')
  def with_frame_label = @with_frame_label ||= title('With Frame')
  def textview_without_frame_label = @textview_without_frame_label ||= title('Without Frame')
  def textview_with_frame_label = @textview_with_frame_label ||= title('With Frame')

  def pictures_inner_separator = @pictures_inner_separator ||= inner_separator
  def textviews_inner_separator = @textviews_inner_separator ||= inner_separator

  def pictures_separator
    @pictures_separator ||= Gtk::Separator.new(:horizontal).tap { |s| s.margin_bottom = 24 }
  end

  def toolbar_separator
    @toolbar_separator ||= Gtk::Separator.new(:horizontal).tap { |s| s.margin_bottom = 24 }
  end

  def toolbar_plain_label
    @toolbar_plain_label ||= title('Without Frame').tap do |label|
      label.margin_bottom = 12
      label.halign = :start
    end
  end

  def toolbar_framed_label
    @toolbar_framed_label ||= title('With Frame').tap do |label|
      label.margin_bottom = 12
      label.halign = :start
    end
  end

  def plain_toolbar = @plain_toolbar ||= toolbar_box.tap { |box| box.margin_bottom = 18 }
  def framed_toolbar_box = @framed_toolbar_box ||= toolbar_box

  def framed_toolbar
    @framed_toolbar ||= Gtk::Frame.new.tap do |frame|
      frame.label = 'Frame can have an optional label'
      frame.margin_bottom = 24
    end
  end

  def toolbar_buttons = @toolbar_buttons ||= build_toolbar_buttons
  def framed_toolbar_buttons = @framed_toolbar_buttons ||= build_toolbar_buttons

  def scrolled_without_frame = @scrolled_without_frame ||= text_scroller
  def scrolled_with_frame = @scrolled_with_frame ||= text_scroller

  def textview_without_frame
    @textview_without_frame ||= demo_textview.tap { |view| view.margin_bottom = 12 }
  end

  def textview_with_frame = @textview_with_frame ||= demo_textview

  def reference_button
    @reference_button ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.Frame.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end

  private

  def comparison_row
    Gtk::Box.new(:horizontal, 18).tap do |box|
      box.halign = :center
      box.margin_bottom = 18
      box.homogeneous = false
    end
  end

  def comparison_column
    Gtk::Box.new(:vertical, 12).tap { |box| box.halign = :center }
  end

  def inner_separator
    Gtk::Separator.new(:vertical).tap do |separator|
      separator.margin_start = 6
      separator.margin_end = 6
    end
  end

  def title(text)
    Gtk::Label.new(text).tap { |label| label.add_css_class('title-4') }
  end

  def demo_picture
    Gtk::Picture.new(Gio::File.new_for_path(File.join(__dir__, 'image.png'))).tap do |picture|
      picture.set_size_request(180, 180)
    end
  end

  def toolbar_box
    Gtk::Box.new(:horizontal, 0).tap do |box|
      box.halign = :center
      box.add_css_class('toolbar')
    end
  end

  def build_toolbar_buttons
    ['list-add-symbolic', 'list-remove-symbolic', 'preferences-system-notifications-symbolic'].map do |icon|
      Gtk::Button.new.tap { |btn| btn.icon_name = icon }
    end
  end

  def text_scroller
    Gtk::ScrolledWindow.new.tap { |sw| sw.set_size_request(240, 240) }
  end

  def demo_textview
    Gtk::TextView.new(buffer).tap do |view|
      view.bottom_margin = 12
      view.left_margin = 12
      view.right_margin = 12
      view.top_margin = 12
      view.editable = false
      view.wrap_mode = :char
    end
  end
end

FrameDemo.new.build.run

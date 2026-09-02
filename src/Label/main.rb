require 'gtk4'
require 'adwaita'

class LabelDemo
  STYLE_CLASSES = ['none', 'title-1', 'title-2', 'title-3', 'title-4', 'monospace', 'accent', 'success',
                   'warning', 'error', 'heading', 'body', 'caption-heading', 'caption'].freeze

  STYLE_NAMES = ['None', 'Title 1', 'Title 2', 'Title 3', 'Title 4', 'Monospace', 'Accent', 'Success',
                 'Warning', 'Error', 'Heading', 'Body', 'Caption Heading', 'Caption'].freeze

  WRAP_MODES = ['None', 'Character', 'Word', 'Word & Character'].freeze
  ELLIPSIZE_MODES = ['None', 'Start', 'Middle', 'End'].freeze
  JUSTIFICATIONS = ['Left', 'Right', 'Center', 'Fill'].freeze

  SHORT_LABEL = '<b>Lorem ipsum</b> dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor ' \
                'incididunt ut labore et dolore disputandum putant.'

  LONG_LABEL = <<~TEXT
         <b>Lorem ipsum</b> dolor sit amet, consectetur adipiscing elit,
      sed do eiusmod tempor incididunt ut labore et dolore magnam aliquam quaerat voluptatem.
      Ut enim mortis metu omnis quietae vitae status perturbatur,
      et ut succumbere doloribus eosque humili animo inbecilloque ferre miserum est,
      ob eamque debilitatem animi multi parentes, multi amicos, non nulli patriam,
      plerique autem se ipsos penitus perdiderunt, sic robustus animus et excelsus omni.
  TEXT

  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(clamp)
              b.append(reference_button)
              b.append(separator)
              b.append(label)

              clamp.tap do |c|
                c.child = list_box

                list_box.tap do |list|
                  list.append(single_line_switch)
                  list.append(markup_switch)
                  list.append(wrap_row)
                  list.append(ellipsize_row)
                  list.append(style_row)
                  list.append(justification_row)
                  list.append(xalign_spin_button)

                  single_line_switch.tap do |row|
                    row.signal_connect('notify::active') do
                      label.label = row.active? ? SHORT_LABEL : LONG_LABEL
                    end
                  end

                  markup_switch.tap do |row|
                    row.bind_property('active', label, 'use-markup', GLib::BindingFlags::SYNC_CREATE)
                  end

                  wrap_row.tap do |row|
                    row.signal_connect('notify::selected') { apply_wrap(row.selected) }
                  end

                  ellipsize_row.tap do |row|
                    row.signal_connect('notify::selected') { label.ellipsize = row.selected }
                  end

                  style_row.tap do |row|
                    row.signal_connect('notify::selected') { apply_style(row.selected) }
                  end

                  justification_row.tap do |row|
                    row.signal_connect('notify::selected') { label.justify = row.selected }
                  end

                  xalign_spin_button.tap do |row|
                    row.signal_connect('notify::value') { label.xalign = row.value }
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

  def app = @app ||= Gtk::Application.new('org.example.label', :default_flags)
  def clamp = @clamp ||= Adwaita::Clamp.new.tap { |c| c.maximum_size = 450 }
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 18)
  def separator = @separator ||= Gtk::Separator.new(:horizontal)
  def label = @label ||= Gtk::Label.new(SHORT_LABEL).tap { |l| l.xalign = 0.5 }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Label'
      win.set_default_size(640, 900)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Label'
      page.description = 'Multipurpose text widget for a small amount of text'
    end
  end

  def list_box
    @list_box ||= Gtk::ListBox.new.tap do |list|
      list.selection_mode = :none
      list.add_css_class('boxed-list')
    end
  end

  def single_line_switch
    @single_line_switch ||= Adwaita::SwitchRow.new.tap do |row|
      row.title = 'Single Line'
      row.active = true
    end
  end

  def markup_switch = @markup_switch ||= Adwaita::SwitchRow.new.tap { |row| row.title = 'Use Markup' }

  def wrap_row = @wrap_row ||= combo_row('Wrap Mode', WRAP_MODES)
  def ellipsize_row = @ellipsize_row ||= combo_row('Ellipsize Mode', ELLIPSIZE_MODES)
  def style_row = @style_row ||= combo_row('Style Class', STYLE_NAMES)
  def justification_row = @justification_row ||= combo_row('Justification', JUSTIFICATIONS)

  def xalign_spin_button
    @xalign_spin_button ||= Adwaita::SpinRow.new(Gtk::Adjustment.new(0.5, 0, 1, 0.1, 0.1, 0), 0.1, 1).tap do |row|
      row.title = 'X Align'
    end
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.Label.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end

  private

  def combo_row(title, strings)
    Adwaita::ComboRow.new.tap do |row|
      row.title = title
      row.model = Gtk::StringList.new(strings)
    end
  end

  def apply_wrap(selected)
    label.wrap = !selected.zero?
    label.wrap_mode = [:word, :char, :word, :word_char][selected]
  end

  def apply_style(selected)
    STYLE_CLASSES.each { |style_class| label.remove_css_class(style_class) }
    label.add_css_class(STYLE_CLASSES[selected]) unless selected.zero?
  end
end

LabelDemo.new.build.run

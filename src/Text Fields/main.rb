require 'gtk4'
require 'adwaita'

class TextFieldsDemo
  COMPLETION_WORDS = %w[a app apple apples applets application].freeze

  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = scrolled_page

          scrolled_page.tap do |sw|
            sw.child = clamp

            clamp.tap do |c|
              c.child = content_box

              content_box.tap do |b|
                b.append(title_label)
                b.append(subtitle_label)
                b.append(hig_link)
                b.append(entry_heading)
                b.append(entry_description)
                b.append(entries_flow_box)
                b.append(entry_links)
                b.append(first_separator)
                b.append(completion_heading)
                b.append(completion_description)
                b.append(entry_completion)
                b.append(completion_reference)
                b.append(second_separator)
                b.append(password_heading)
                b.append(password_description)
                b.append(entry_password)
                b.append(entry_confirm_password)
                b.append(label_password)
                b.append(password_links)
                b.append(third_separator)
                b.append(style_heading)
                b.append(accent_row)
                b.append(status_row)
                b.append(address_row)

                entries_flow_box.tap do |box|
                  box.append(regular_column)
                  box.append(placeholder_column)
                  box.append(icon_column)
                  box.append(progress_column)
                end

                entry_links.tap do |box|
                  box.append(tutorial_link)
                  box.append(entry_reference)
                end

                password_links.tap do |box|
                  box.append(password_tutorial_link)
                  box.append(password_reference)
                end

                accent_row.tap do |box|
                  box.append(accent_entry)
                  box.append(warning_entry)
                end

                status_row.tap do |box|
                  box.append(error_entry)
                  box.append(success_entry)
                end

                address_row.tap do |box|
                  address_entries.each { |e| box.append(e) }
                end
              end
            end
          end
        end

        connect_entries

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.textfields', :default_flags)
  def scrolled_page = @scrolled_page ||= Gtk::ScrolledWindow.new
  def clamp = @clamp ||= Adwaita::Clamp.new
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0)
  def label_password = @label_password ||= Gtk::Label.new

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Text Fields'
      win.set_default_size(760, 900)
    end
  end

  def title_label
    @title_label ||= Gtk::Label.new('Text Fields').tap do |label|
      label.margin_top = 12
      label.margin_bottom = 12
      label.add_css_class('title-1')
    end
  end

  def subtitle_label
    @subtitle_label ||= Gtk::Label.new('Single line widgets to enter text').tap { |l| l.margin_bottom = 12 }
  end

  def hig_link
    @hig_link ||= Gtk::LinkButton.new(
      'https://developer.gnome.org/hig/patterns/controls/text-fields.html'
    ).tap do |btn|
      btn.label = 'Human Interface Guidelines'
      btn.margin_bottom = 6
    end
  end

  def entry_heading = @entry_heading ||= heading('Entry')
  def completion_heading = @completion_heading ||= heading('Completion Entry')
  def password_heading = @password_heading ||= heading('Password Entry')

  def style_heading
    @style_heading ||= heading('Style Classes').tap { |label| label.margin_bottom = 12 }
  end

  def entry_description
    @entry_description ||= description('A simple but versatile widget that allows single line text entry and editing')
  end

  def completion_description
    @completion_description ||= description('An entry widget with support for completion')
  end

  def password_description
    @password_description ||= description('An entry with dedicated control for entering secrets and passwords')
  end

  def entries_flow_box
    @entries_flow_box ||= Gtk::FlowBox.new.tap do |box|
      box.homogeneous = true
      box.row_spacing = 18
      box.selection_mode = :none
    end
  end

  def regular_column = @regular_column ||= labelled_column('Regular', entry)
  def placeholder_column = @placeholder_column ||= labelled_column('Placeholder Text', entry_placeholder)
  def icon_column = @icon_column ||= labelled_column('Icons', entry_icon)
  def progress_column = @progress_column ||= labelled_column('Progress Bar', entry_progress)

  def entry
    @entry ||= Gtk::Entry.new.tap do |e|
      e.input_purpose = :free_form
      e.input_hints = :no_spellcheck
    end
  end

  def entry_placeholder = @entry_placeholder ||= Gtk::Entry.new.tap { |e| e.placeholder_text = 'Text' }

  def entry_icon
    @entry_icon ||= Gtk::Entry.new.tap do |e|
      e.primary_icon_name = 'help-about-symbolic'
      e.primary_icon_activatable = true
      e.primary_icon_tooltip_text = 'Click on Me'
      e.secondary_icon_name = 'preferences-system-notifications-symbolic'
      e.secondary_icon_tooltip_text = 'No Click on Me'
    end
  end

  def entry_progress
    @entry_progress ||= Gtk::Entry.new.tap do |e|
      e.progress_fraction = 0
      e.primary_icon_name = 'media-playback-start-symbolic'
      e.primary_icon_tooltip_text = 'Play Animation'
    end
  end

  def animation
    @animation ||= Adwaita::TimedAnimation.new(
      entry_progress, 0, 1, 2000,
      Adwaita::PropertyAnimationTarget.new(entry_progress, 'progress-fraction')
    ).tap do |a|
      a.easing = Adwaita::Easing::LINEAR
      a.signal_connect('done') { a.reset }
    end
  end

  def entry_completion
    @entry_completion ||= Gtk::Entry.new.tap do |e|
      e.margin_bottom = 12
      e.placeholder_text = 'Try typing “apple”'
      e.completion = completion
    end
  end

  def completion
    @completion ||= Gtk::EntryCompletion.new.tap do |c|
      c.model = completion_model
      c.text_column = 0
      c.inline_completion = true
      c.inline_selection = true
    end
  end

  def completion_model
    @completion_model ||= Gtk::ListStore.new(String).tap do |store|
      COMPLETION_WORDS.each { |word| store.set_value(store.append, 0, word) }
    end
  end

  def entry_password = @entry_password ||= password_entry('Password')
  def entry_confirm_password = @entry_confirm_password ||= password_entry('Confirm password')

  def first_separator = @first_separator ||= Gtk::Separator.new(:horizontal).tap { |s| s.margin_bottom = 18 }
  def second_separator = @second_separator ||= Gtk::Separator.new(:horizontal).tap { |s| s.margin_bottom = 18 }
  def third_separator = @third_separator ||= Gtk::Separator.new(:horizontal).tap { |s| s.margin_bottom = 18 }

  def entry_links
    @entry_links ||= Gtk::Box.new(:horizontal, 0).tap do |box|
      box.halign = :center
      box.margin_top = 18
      box.margin_bottom = 18
    end
  end

  def password_links
    @password_links ||= Gtk::Box.new(:horizontal, 0).tap do |box|
      box.halign = :center
      box.margin_top = 6
      box.margin_bottom = 18
    end
  end

  def tutorial_link
    @tutorial_link ||= Gtk::LinkButton.new(
      'https://developer.gnome.org/documentation/tutorials/beginners/components/entry.html'
    ).tap { |btn| btn.label = 'Tutorial' }
  end

  def entry_reference
    @entry_reference ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.Entry.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end

  def completion_reference
    @completion_reference ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.EntryCompletion.html').tap do |btn|
      btn.label = 'API Reference'
      btn.margin_top = 18
      btn.margin_bottom = 18
    end
  end

  def password_tutorial_link
    @password_tutorial_link ||= Gtk::LinkButton.new(
      'https://developer.gnome.org/documentation/tutorials/beginners/components/password_entry.html'
    ).tap { |btn| btn.label = 'Tutorial' }
  end

  def password_reference
    @password_reference ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.PasswordEntry.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end

  def accent_row = @accent_row ||= styled_row
  def status_row = @status_row ||= styled_row

  def address_row
    @address_row ||= Gtk::Box.new(:horizontal, 0).tap do |box|
      box.margin_bottom = 18
      box.halign = :center
      box.add_css_class('linked')
    end
  end

  def accent_entry = @accent_entry ||= styled_entry('Accent', 'accent')
  def warning_entry = @warning_entry ||= styled_entry('Warning', 'warning')
  def error_entry = @error_entry ||= styled_entry('Error', 'error')
  def success_entry = @success_entry ||= styled_entry('Success', 'success')

  def address_entries
    @address_entries ||= ['Street name and number', 'City', 'Country'].map do |placeholder|
      Gtk::Entry.new.tap { |e| e.placeholder_text = placeholder }
    end
  end

  private

  def heading(text)
    Gtk::Label.new(text).tap do |label|
      label.margin_top = 12
      label.halign = :start
      label.add_css_class('heading')
    end
  end

  def description(text)
    Gtk::Label.new(text).tap do |label|
      label.margin_top = 12
      label.margin_bottom = 12
      label.halign = :start
      label.add_css_class('dim-label')
    end
  end

  def labelled_column(title, field)
    Gtk::Box.new(:vertical, 0).tap do |box|
      box.append(Gtk::Label.new(title).tap { |label| label.margin_bottom = 12 })
      box.append(field)
    end
  end

  def password_entry(placeholder)
    Gtk::PasswordEntry.new.tap do |e|
      e.show_peek_icon = true
      e.placeholder_text = placeholder
      e.margin_bottom = 12
    end
  end

  def styled_row
    Gtk::Box.new(:horizontal, 0).tap do |box|
      box.homogeneous = true
      box.margin_bottom = 18
    end
  end

  def styled_entry(placeholder, style)
    Gtk::Entry.new.tap do |e|
      e.placeholder_text = placeholder
      e.margin_start = 6
      e.margin_end = 6
      e.add_css_class(style)
    end
  end

  def connect_entries
    entry.signal_connect('activate') { puts "Regular Entry: \"#{entry.text}\" entered" }
    entry_placeholder.signal_connect('activate') { puts "Placeholder Entry: \"#{entry_placeholder.text}\" entered" }
    entry_icon.signal_connect('activate') { puts "Icon Entry: \"#{entry_icon.text}\" entered" }
    entry_icon.signal_connect('icon-press') { puts 'Icon Pressed!' }
    entry_icon.signal_connect('icon-release') { puts 'Icon Released!' }

    entry_progress.tap do |e|
      e.signal_connect('activate') { puts "Progress Bar Entry: \"#{e.text}\" entered" }
      e.signal_connect('icon-press') { animation.play }
    end

    [entry_password, entry_confirm_password].each do |e|
      e.signal_connect('activate') { label_password.label = validate_password }
    end
  end

  def validate_password
    if entry_password.text.empty? || entry_confirm_password.text.empty?
      'Both fields are mandatory!'
    elsif entry_password.text == entry_confirm_password.text
      'Password made successfully!'
    else
      'Both fields should be matching!'
    end
  end
end

TextFieldsDemo.new.build.run

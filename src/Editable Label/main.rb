require 'gtk4'
require 'adwaita'

class EditableLabelDemo
  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(edit_label)
              b.append(switch_box)
              b.append(reference_button)

              switch_box.tap do |box|
                box.append(switch_label)
                box.append(spacer)
                box.append(edit_switch)

                edit_switch.tap do |sw|
                  edit_label.bind_property('editing', sw, 'active',
                                           GLib::BindingFlags::BIDIRECTIONAL | GLib::BindingFlags::SYNC_CREATE)
                end
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.editablelabel', :default_flags)
  def switch_label = @switch_label ||= Gtk::Label.new('Editable')
  def spacer = @spacer ||= Gtk::Separator.new(:horizontal).tap { |s| s.add_css_class('spacer') }
  def edit_switch = @edit_switch ||= Gtk::Switch.new.tap { |sw| sw.halign = :center }
  def switch_box = @switch_box ||= Gtk::Box.new(:horizontal, 0).tap { |box| box.halign = :center }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Editable Label'
      win.set_default_size(640, 520)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Editable Label'
      page.description = 'A text widget with an editing mode'
    end
  end

  def content_box
    @content_box ||= Gtk::Box.new(:vertical, 18).tap { |box| box.halign = :center }
  end

  def edit_label
    @edit_label ||= Gtk::EditableLabel.new('Lorem ipsum dolor sit amet, consectetur adipiscing elit')
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.EditableLabel.html').tap do |btn|
      btn.label = 'API Reference'
    end
  end
end

EditableLabelDemo.new.build.run

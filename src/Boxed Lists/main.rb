require 'gtk4'
require 'adwaita'

class BoxedListsDemo
  ANIMALS = %w[Cat Dog Hippo Duck Dodo].freeze

  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = clamp

            clamp.tap do |c|
              c.child = content_box

              content_box.tap do |b|
                b.append(list_box)
                b.append(reference_button)
                b.append(hig_button)

                list_box.tap do |list|
                  list.append(prefix_row)
                  list.append(suffix_row)
                  list.append(activatable_row)
                  list.append(property_row)
                  list.append(entry_row)
                  list.append(switch_row)
                  list.append(spin_row)
                  list.append(drop_down)
                  list.append(expander_row)

                  prefix_row.tap { |row| row.add_prefix(checkbox) }

                  suffix_row.tap do |row|
                    row.add_suffix(spinner)
                    checkbox.bind_property('active', spinner, 'spinning',
                                           GLib::BindingFlags::SYNC_CREATE)
                  end

                  activatable_row.tap do |row|
                    row.add_suffix(activatable_toggle)
                    row.activatable_widget = activatable_toggle
                  end

                  expander_row.tap do |row|
                    row.add_row(first_expanded_row)
                    row.add_row(second_expanded_row)
                  end

                  drop_down.tap do |row|
                    row.signal_connect('notify::selected-item') { puts row.selected_item.string }
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

  def app = @app ||= Gtk::Application.new('org.example.boxedlists', :default_flags)
  def clamp = @clamp ||= Adwaita::Clamp.new.tap { |c| c.maximum_size = 500 }
  def content_box = @content_box ||= Gtk::Box.new(:vertical, 0)
  def checkbox = @checkbox ||= Gtk::CheckButton.new.tap { |check| check.active = true }
  def spinner = @spinner ||= Gtk::Spinner.new
  def entry_row = @entry_row ||= Adwaita::EntryRow.new.tap { |row| row.title = 'A Row Can Be an Entry' }
  def first_expanded_row = @first_expanded_row ||= Adwaita::ActionRow.new.tap { |row| row.title = 'First Row' }
  def second_expanded_row = @second_expanded_row ||= Adwaita::ActionRow.new.tap { |row| row.title = 'Second Row' }

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Boxed Lists'
      win.set_default_size(640, 900)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Boxed Lists'
      page.description = 'List to present both controls and information'
    end
  end

  def list_box
    @list_box ||= Gtk::ListBox.new.tap do |list|
      list.selection_mode = :none
      list.add_css_class('boxed-list')
    end
  end

  def prefix_row
    @prefix_row ||= Adwaita::ActionRow.new.tap { |row| row.title = 'Action Row Can Have a Prefix Child' }
  end

  def suffix_row
    @suffix_row ||= Adwaita::ActionRow.new.tap do |row|
      row.title = 'Action Row Can Have a Suffix Child'
      row.subtitle = 'The checkbox above controls the spinner'
    end
  end

  def activatable_row
    @activatable_row ||= Adwaita::ActionRow.new.tap do |row|
      row.title = 'Action Row Can Have an Activatable Widget'
      row.subtitle = 'Click on the row to activate it'
    end
  end

  def activatable_toggle
    @activatable_toggle ||= Gtk::ToggleButton.new.tap do |btn|
      btn.icon_name = 'list-add-symbolic'
      btn.valign = :center
    end
  end

  def property_row
    @property_row ||= Adwaita::ActionRow.new.tap do |row|
      row.title = 'Property Row'
      row.subtitle = 'Deemphasizes the row title and emphasizes subtitle instead'
      row.add_css_class('property')
    end
  end

  def switch_row
    @switch_row ||= Adwaita::SwitchRow.new.tap do |row|
      row.title = 'Switch Row'
      row.subtitle = 'Simple on/off control'
    end
  end

  def spin_row
    @spin_row ||= Adwaita::SpinRow.new(Gtk::Adjustment.new(50, 0, 100, 1, 0, 0), 0.2, 0).tap do |row|
      row.title = 'Spin Row'
      row.subtitle = 'Increment or decrement a value'
    end
  end

  def drop_down
    @drop_down ||= Adwaita::ComboRow.new.tap do |row|
      row.title = 'Choose an Item'
      row.subtitle = 'List of options from a drop down'
      row.enable_search = true
      row.model = Gtk::StringList.new(ANIMALS)
    end
  end

  def expander_row
    @expander_row ||= Adwaita::ExpanderRow.new.tap do |row|
      row.title = 'Rows Can Be Expandable'
      row.show_enable_switch = true
    end
  end

  def reference_button
    @reference_button ||= Gtk::LinkButton.new(
      'https://gnome.pages.gitlab.gnome.org/libadwaita/doc/1.6/boxed-lists.html'
    ).tap do |btn|
      btn.label = 'API Reference'
      btn.margin_top = 24
    end
  end

  def hig_button
    @hig_button ||= Gtk::LinkButton.new(
      'https://developer.gnome.org/hig/patterns/containers/boxed-lists.html'
    ).tap { |btn| btn.label = 'Human Interface Guidelines' }
  end
end

BoxedListsDemo.new.build.run

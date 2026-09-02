require 'gtk4'
require 'adwaita'

# The advanced drop down is backed by objects rather than plain strings, so the
# displayed text comes from a property expression.
class KeyValuePair < GLib::Object
  type_register

  install_property(GLib::Param::String.new('key', 'key', 'Key', '', GLib::Param::READWRITE))
  install_property(GLib::Param::String.new('value', 'value', 'Value', '', GLib::Param::READWRITE))

  attr_accessor :key, :value
end

class DropDownDemo
  FRUITS = %w[Grapes Apples Bananas Tomatoes].freeze

  ANIMALS = {
    'lion' => 'Lion', 'tiger' => 'Tiger', 'leopard' => 'Leopard', 'elephant' => 'Elephant',
    'giraffe' => 'Giraffe', 'cheetah' => 'Cheetah', 'zebra' => 'Zebra', 'panda' => 'Panda',
    'koala' => 'Koala', 'crocodile' => 'Crocodile', 'hippo' => 'Hippopotamus', 'monkey' => 'Monkey',
    'rhino' => 'Rhinoceros', 'kangaroo' => 'Kangaroo', 'dolphin' => 'Dolphin'
  }.freeze

  def build
    app.tap do
      app.signal_connect('activate') do
        app.add_window(window)

        window.tap do |win|
          win.child = status_page

          status_page.tap do |page|
            page.child = content_box

            content_box.tap do |b|
              b.append(string_list_heading)
              b.append(drop_down)
              b.append(list_store_heading)
              b.append(advanced_drop_down)
              b.append(reference_link)
              b.append(hig_link)

              drop_down.tap do |dd|
                dd.signal_connect('notify::selected-item') { puts dd.selected_item.string }
              end

              advanced_drop_down.tap do |dd|
                dd.model = model
                dd.signal_connect('notify::selected-item') { puts dd.selected_item.key if dd.selected_item }
              end
            end
          end
        end

        window.present
      end
    end
  end

  def app = @app ||= Gtk::Application.new('org.example.dropdown', :default_flags)

  def window
    @window ||= Gtk::ApplicationWindow.new(app).tap do |win|
      win.title = 'Drop Down'
      win.set_default_size(560, 700)
    end
  end

  def status_page
    @status_page ||= Adwaita::StatusPage.new.tap do |page|
      page.title = 'Drop Down'
      page.description = 'A widget to choose an item from a list of options'
    end
  end

  def content_box
    @content_box ||= Gtk::Box.new(:vertical, 0).tap do |box|
      box.halign = :center
      box.valign = :center
    end
  end

  def string_list_heading = @string_list_heading ||= heading('From a StringList Model')
  def list_store_heading = @list_store_heading ||= heading('From a ListStore Model')

  def drop_down
    @drop_down ||= Gtk::DropDown.new.tap do |dd|
      dd.enable_search = true
      dd.model = Gtk::StringList.new(FRUITS)
      dd.expression = Gtk::PropertyExpression.new(Gtk::StringObject, nil, 'string')
    end
  end

  def advanced_drop_down
    @advanced_drop_down ||= Gtk::DropDown.new.tap do |dd|
      dd.enable_search = true
      dd.expression = Gtk::PropertyExpression.new(KeyValuePair, nil, 'value')
    end
  end

  def model
    @model ||= Gio::ListStore.new(KeyValuePair).tap do |store|
      ANIMALS.each do |key, value|
        store.append(KeyValuePair.new.tap do |pair|
          pair.key = key
          pair.value = value
        end)
      end
    end
  end

  def reference_link
    @reference_link ||= Gtk::LinkButton.new('https://docs.gtk.org/gtk4/class.DropDown.html').tap do |btn|
      btn.label = 'API Reference'
      btn.margin_top = 12
    end
  end

  def hig_link
    @hig_link ||= Gtk::LinkButton.new('https://developer.gnome.org/hig/patterns/controls/drop-downs.html').tap do |btn|
      btn.label = 'Human Interface Guidelines'
      btn.margin_top = 12
    end
  end

  private

  def heading(text)
    Gtk::Label.new(text).tap do |label|
      label.margin_top = 24
      label.margin_bottom = 24
      label.add_css_class('heading')
    end
  end
end

DropDownDemo.new.build.run
